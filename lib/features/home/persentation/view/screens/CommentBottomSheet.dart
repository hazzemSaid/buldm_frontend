import 'dart:math' as math;

import 'package:buldm/core/notifications/notification_service.dart';
import 'package:buldm/features/auth/presentaion/view/bloc/auth_cubit.dart';
import 'package:buldm/features/auth/presentaion/view/bloc/auth_state.dart';
import 'package:buldm/features/home/data/models/commentsmodel.dart';
import 'package:buldm/features/home/data/models/post_model.dart';
import 'package:buldm/features/home/persentation/bloc/post/post_bloc.dart';
import 'package:buldm/features/home/persentation/bloc/post/post_state.dart';
import 'package:buldm/features/home/persentation/bloc/user/user_bloc.dart';
import 'package:buldm/features/home/persentation/bloc/user/user_event.dart';
import 'package:buldm/features/home/persentation/bloc/user/user_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as services;
import 'package:flutter_bloc/flutter_bloc.dart';

// Feature flag to control sending push notifications for comments
const bool kEnableCommentNotification = true;

// Local UI state for optimistic comment sending status
enum CommentSendStatus { sending, success, error }

class CommentBottomSheet extends StatefulWidget {
  const CommentBottomSheet({super.key, required this.post});
  final PostModel post;

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet>
    with TickerProviderStateMixin {
  final TextEditingController commentController = TextEditingController();
  bool _isSending = false;
  String? _errorMessage;
  // Throttle to prevent double submissions within a short window
  DateTime? _lastSubmitAt;
  final FocusNode _inputFocusNode = FocusNode();
  final ScrollController _listController = ScrollController();
  String? _replyingToCommentId;
  CommentModel? _replyingTo;
  final Set<String> _expandedParents = <String>{};
  final Map<String, int> _commentLikes = <String, int>{};
  final Set<String> _likedComments = <String>{};
  // No local pending list; rely on PostBloc optimistic updates
  // We keep a small pending list to reflect immediate UI updates before server response
  final List<CommentModel> _pendingComments = <CommentModel>[];
  // Track pending send status for optimistic comments
  final Map<String, CommentSendStatus> _pendingStatus =
      <String, CommentSendStatus>{};
  String? _lastPendingId;
  bool _autoExpanded = false;
  CommentSort _sort = CommentSort.newest;
  bool _orphanFetchTriggered = false;
  int page = 2;
  int limit = 10;
  late int count;
  bool _isLoadingMoreComments = false;
  bool _initialRequested = false;
  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _stateController = AnimationController(
      vsync: this, // Use 'this' as the TickerProvider
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _stateController,
        curve: Curves.easeInOut,
      ),
    );
    _stateController.forward();

    // Initialize comment-related state
    count = widget.post.commentsCount;

    // Optimized post loading check
    _loadPostIfNeeded();

    // Optimize scroll listener for pagination
    _setupScrollListener();

    // Safety: after first frame, ensure we requested the first page only once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final postBloc = context.read<PostBloc>();
      if (_initialRequested) return;
      _initialRequested = true;
      // Reset pagination for this sheet session
      page = 2;
      postBloc.add(getcomment(postId: widget.post.id, page: 1, limit: limit));
    });
  }

  void _loadPostIfNeeded() {
    final postBloc = context.read<PostBloc>();
    final state = postBloc.state;

    if (!_initialRequested) {
      // Request the first page of comments for this post
      _initialRequested = true;
      page = 2;
      postBloc.add(getcomment(postId: widget.post.id, page: 1, limit: limit));
    }
  }

  void _setupScrollListener() {
    _listController.addListener(() {
      if (!_listController.hasClients) return;
      if (_isLoadingMoreComments) return;
      final blocState = context.read<PostBloc>().state;
      if (blocState.status == PostStatus.commentLoadLoading) return;

      // Improved scroll threshold detection (20% from bottom)
      final scrollThreshold = 0.8 * _listController.position.maxScrollExtent;
      if (_listController.position.pixels < scrollThreshold) return;

      // More robust comment count check
      final state = blocState;
      int currentCount = 0;

      if (state.status == PostStatus.postLoadSuccess &&
          state.posts[widget.post.id] != null) {
        currentCount = state.comments.values
            .where((c) => c.postId == widget.post.id)
            .length;
      } else if (state.status == PostStatus.commentLoadSuccess) {
        currentCount = state.comments.values
            .where((c) => c.postId == widget.post.id)
            .length;
      }

      if (currentCount >= count) return;

      setState(() => _isLoadingMoreComments = true);
      context
          .read<PostBloc>()
          .add(getcomment(postId: widget.post.id, page: page, limit: limit));
      page++;
    });
  }

  void _addComment(String text) {
    final content = text.trim();
    if (content.isEmpty) return;
    // Throttle rapid submissions (e.g., enter + tap)
    final now = DateTime.now();
    if (_lastSubmitAt != null &&
        now.difference(_lastSubmitAt!) < const Duration(milliseconds: 700)) {
      return;
    }
    _lastSubmitAt = now;
    if (_isSending) return; // prevent double-submit

    setState(() => _isSending = true);
    final pid = widget.post.id;
    final parent = _replyingToCommentId;

    // Create optimistic comment for immediate UI update
    final authState = context.read<AuthCubit>().state;
    final meId = authState is Authenticated ? authState.user.user_id : 'you';
    final optimistic = CommentModel(
      comment: content,
      userId: meId,
      postId: pid,
      createdAt: DateTime.now(),
      id: 'pending-${DateTime.now().microsecondsSinceEpoch}',
      parentCommentId: parent?.isEmpty ?? true ? null : parent,
    );

    setState(() {
      _pendingComments.add(optimistic);
      _pendingStatus[optimistic.id] = CommentSendStatus.sending;
      _lastPendingId = optimistic.id;

      // Auto-expand parent when replying
      if (_replyingToCommentId != null) {
        _expandedParents.add(_replyingToCommentId!);
      }

      // Clear input immediately for better UX
      commentController.clear();
    });

    // Send to backend with appropriate event
    if (parent != null && parent.isNotEmpty) {
      context.read<PostBloc>().add(setreplycomment(
            postId: pid,
            parentCommentId: parent,
            content: content,
          ));
      _notifyAfterComment(content: content, isReply: true);
    } else {
      context.read<PostBloc>().add(setcomment(
            postId: pid,
            content: content,
          ));
      _notifyAfterComment(content: content, isReply: false);
    }

    // No need for autoscroll - modern UX keeps your position
    _replyingToCommentId = null;
    _replyingTo = null;

    // We'll let the BlocListener handle setting _isSending = false
  }

  Future<void> _notifyAfterComment({
    required String content,
    required bool isReply,
  }) async {
    if (!kEnableCommentNotification) {
      debugPrint('🔕 Comment push disabled by feature flag');
      return;
    }
    try {
      // Get current user (sender)
      final authState = context.read<AuthCubit>().state;
      if (authState is! Authenticated) return;
      final me = authState.user;

      // Determine recipient user id
      String? toUid;
      if (isReply) {
        toUid = _replyingTo?.userId;
      } else {
        toUid = widget.post.user_id;
      }
      if (toUid == null || toUid.isEmpty) return;
      if (toUid == me.user_id) return; // don't notify self

      // Fetch recipient's OneSignal player id from Firestore
      final toDoc =
          await FirebaseFirestore.instance.collection('users').doc(toUid).get();
      final toData = toDoc.data() ?? {};
      String? playerId = toData['onesignal_player_id'] as String?;
      playerId ??= toData['oneSignalPlayerId'] as String?;
      playerId ??= toData['playerId'] as String?;
      if (playerId == null || playerId.isEmpty) {
        debugPrint('⚠️ No OneSignal playerId for user $toUid. Skip push.');
        return;
      }

      final title = isReply
          ? '${me.name} replied to your comment'
          : '${me.name} commented on your post';
      final message = content;
      final data = {
        'type': 'post_comment',
        'postId': widget.post.id,
        'deeplink': '/post/${widget.post.id}',
        'senderId': me.user_id,
        'senderName': me.name,
        'senderAvatar': me.avatar,
        'isReply': isReply,
      };

      // Use dedicated post notification helper to enforce post deeplink
      debugPrint('Comment notify -> playerId=$playerId data=$data');
      await NotificationService.instance.sendPostNotification(
        toPlayerId: playerId,
        title: title,
        message: message,
        sender: {
          'id': me.user_id,
          'name': me.name,
          'avatar': me.avatar,
        },
        postId: widget.post.id,
        isReply: isReply,
      );
    } catch (e) {
      debugPrint('⚠️ Comment push flow error: $e');
    }
  }

  String _relativeTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    final weeks = (diff.inDays / 7).floor();
    if (weeks < 5) return '${weeks}w';
    final months = (diff.inDays / 30).floor();
    if (months < 12) return '${months}mo';
    final years = (diff.inDays / 365).floor();
    return '${years}y';
  }

  // Animation controllers for state transitions
  late final AnimationController _stateController;
  late final Animation<double> _fadeAnimation;

  @override
  void dispose() {
    _stateController.dispose();
    super.dispose();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Loading comments...',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String? error) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            error ?? 'Failed to load comments',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<PostBloc>().add(getcomment(
                    postId: widget.post.id,
                    page: 1,
                    limit: limit,
                  ));
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
        top: false,
        bottom: false,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: Container(
            height: math.min(
              MediaQuery.of(context).size.height * 0.96,
              MediaQuery.of(context).size.height -
                  MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              // Subtle surface tint for depth
              gradient: LinearGradient(
                colors: [
                  colorScheme.surface,
                  colorScheme.surface.withOpacity(0.98),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: BlocListener<PostBloc, PostState>(
              listener: (context, state) {
                // Handle state changes with animations
                if (!mounted) return;

                // Handle loading state
                if (state.status == PostStatus.commentLoadLoading) {
                  _stateController.forward();
                }

                // Handle success state
                if (state.status == PostStatus.commentLoadSuccess) {
                  setState(() {
                    _isSending = false;
                    _isLoadingMoreComments = false;
                    // Clear pending comments once real data arrives
                    _pendingComments
                        .removeWhere((c) => c.postId == widget.post.id);
                  });
                  _stateController.forward();
                }

                // Handle error states
                if (state.status == PostStatus.commentLoadError ||
                    state.status == PostStatus.commentCreateError) {
                  setState(() {
                    _isLoadingMoreComments = false;
                    _isSending = false;
                  });
                  _stateController.forward();
                }

                // Handle create success
                if (state.status == PostStatus.commentCreateSuccess) {
                  setState(() {
                    _isSending = false;
                    _replyingTo = null;
                    _replyingToCommentId = null;
                    if (state.status == PostStatus.commentCreateSuccess) {
                      // _expandedParents.add(state.comments[]);
                    }
                  });
                  // Animate the new comment
                  _stateController.forward();
                }

                // Stop sending indicator after create
                if (state.status == PostStatus.commentCreateSuccess ||
                    state.status == PostStatus.commentCreateError) {
                  if (mounted) {
                    setState(() {
                      _isSending = false;
                      // Update last pending status
                      if (_lastPendingId != null) {
                        if (state.status == PostStatus.commentCreateSuccess) {
                          _pendingStatus[_lastPendingId!] =
                              CommentSendStatus.success;
                          // Remove the pending bubble shortly after success
                          final toRemove = _lastPendingId!;
                          Future.delayed(const Duration(milliseconds: 600), () {
                            if (!mounted) return;
                            setState(() {
                              _pendingComments
                                  .removeWhere((c) => c.id == toRemove);
                              _pendingStatus.remove(toRemove);
                              if (_lastPendingId == toRemove)
                                _lastPendingId = null;
                            });
                          });
                        } else {
                          _pendingStatus[_lastPendingId!] =
                              CommentSendStatus.error;
                        }
                      }
                    });
                  }
                }
              },
              child: BlocBuilder<PostBloc, PostState>(
                builder: (context, state) {
                  // Show loading state
                  if (state.status == PostStatus.commentLoadLoading &&
                      !_initialRequested) {
                    return _buildLoadingState();
                  }

                  // Show error state
                  if (state.status == PostStatus.commentLoadError) {
                    return _buildErrorState(state.message);
                  }

                  // Main content with fade animation
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Text('Comments', style: textTheme.titleMedium),
                              const Spacer(),
                              // Sort selector
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                child: PopupMenuButton<CommentSort>(
                                  tooltip: 'Sort comments',
                                  onSelected: (v) => setState(() => _sort = v),
                                  itemBuilder: (context) => const [
                                    PopupMenuItem(
                                      value: CommentSort.newest,
                                      child: Text('Newest'),
                                    ),
                                    PopupMenuItem(
                                      value: CommentSort.oldest,
                                      child: Text('Oldest'),
                                    ),
                                  ],
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: colorScheme.surfaceContainerHighest
                                          .withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.sort,
                                            size: 16,
                                            color:
                                                colorScheme.onSurfaceVariant),
                                        const SizedBox(width: 6),
                                        Text(
                                          _sort == CommentSort.newest
                                              ? 'Newest'
                                              : 'Oldest',
                                          style: textTheme.labelSmall?.copyWith(
                                              color:
                                                  colorScheme.onSurfaceVariant),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              BlocBuilder<PostBloc, PostState>(
                                // Rebuild badge only if comments count for this post changes
                                buildWhen: (prev, next) {
                                  int prevCount;
                                  int nextCount;
                                  if (prev.status ==
                                      PostStatus.postLoadSuccess) {
                                    prevCount = prev.comments.length;
                                  } else if (prev.status ==
                                          PostStatus.commentLoadSuccess &&
                                      prev.posts[widget.post.id] != null) {
                                    prevCount = prev.comments.length;
                                  } else {
                                    prevCount = prev.comments.length;
                                  }

                                  if (next.status ==
                                      PostStatus.postLoadSuccess) {
                                    nextCount = next.comments.length;
                                  } else if (next.status ==
                                          PostStatus.commentLoadSuccess &&
                                      next.posts[widget.post.id] != null) {
                                    nextCount = next.comments.length;
                                  } else {
                                    nextCount = prevCount;
                                  }
                                  return prevCount != nextCount;
                                },
                                builder: (context, state) {
                                  int count;
                                  // Always show count for this post only
                                  count = state
                                      .posts[widget.post.id]!.commentsCount;
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color:
                                          colorScheme.primary.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '$count',
                                      style: textTheme.labelSmall?.copyWith(
                                          color: colorScheme.primary),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Divider(height: 1),

                        // BlocBuilder for comment state
                        Expanded(
                          child: BlocBuilder<PostBloc, PostState>(
                            // Only rebuild the list when the comment set for this post changes
                            buildWhen: (prev, next) {
                              List<CommentModel> getCommentsFromState(
                                  PostState s) {
                                if (s.status == PostStatus.postLoadSuccess) {
                                  return s.comments.values
                                      .where((c) => c.postId == widget.post.id)
                                      .toList();
                                } else if (s.status ==
                                        PostStatus.commentLoadSuccess &&
                                    s.posts[widget.post.id] != null) {
                                  return s.comments.values
                                      .where((c) => c.postId == widget.post.id)
                                      .toList();
                                }
                                return [];
                              }

                              final prevComments = getCommentsFromState(prev);
                              final nextComments = getCommentsFromState(next);
                              if (prevComments.length != nextComments.length) {
                                return true;
                              }
                              if (prevComments.isEmpty &&
                                  nextComments.isEmpty) {
                                return false;
                              }
                              // Shallow identity check on last comment id to detect append
                              return prevComments.isEmpty ||
                                  nextComments.isEmpty ||
                                  prevComments.last.id != nextComments.last.id;
                            },
                            builder: (context, state) {
                              // Compute per-post comments first to decide initial vs pagination loading UI
                              final comments = _getCommentsFromState(state);

                              // Full-screen loader only for initial load (no comments yet)
                              final isInitialLoading = state.status ==
                                      PostStatus.commentLoadLoading &&
                                  comments.isEmpty;

                              if (isInitialLoading) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else if (state.status ==
                                      PostStatus.commentLoadError &&
                                  comments.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.error_outline,
                                          size: 42, color: colorScheme.error),
                                      const SizedBox(height: 8),
                                      Text('Failed to load comments',
                                          style: textTheme.bodyMedium?.copyWith(
                                              color: colorScheme.error)),
                                      const SizedBox(height: 4),
                                      Text(state.message ?? 'An error occurred',
                                          style: textTheme.bodySmall?.copyWith(
                                              color: colorScheme.error)),
                                      TextButton(
                                        onPressed: () => _loadPostIfNeeded(),
                                        child: const Text('Try Again'),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              // Get comments and merge with pending

                              // Initialize like counts
                              for (final c in comments) {
                                _commentLikes[c.id] = _commentLikes[c.id] ?? 0;
                              }

                              final pendingForPost = _pendingComments
                                  .where((c) => c.postId == widget.post.id)
                                  .toList();

                              // Deduplicate: remove pending items that already exist in state
                              final loadedIds =
                                  comments.map((c) => c.id).toSet();
                              String _sig(CommentModel c) =>
                                  '${c.userId}|${c.parentCommentId ?? ''}|${c.comment.trim()}';
                              final loadedSigs = comments.map(_sig).toSet();

                              final pendingFiltered = pendingForPost.where((c) {
                                if (loadedIds.contains(c.id)) return false;
                                // If server returned same logical comment, hide pending duplicate
                                if (loadedSigs.contains(_sig(c))) return false;
                                return true;
                              }).toList();

                              final displayComments = [
                                ...comments,
                                ...pendingFiltered,
                              ];

                              // Request user details for all commenters
                              _fetchUserDetails(displayComments);

                              // Auto-expand parents with replies
                              _autoExpandParentsIfNeeded(displayComments);

                              return displayComments.isEmpty
                                  ? _buildEmptyCommentsView(
                                      colorScheme, textTheme)
                                  : _buildCommentsListView(context, colorScheme,
                                      textTheme, displayComments);
                            },
                          ),
                        ),

                        // Reply context chip (shown only when replying)
                        if (_replyingTo != null)
                          _buildReplyingToChip(colorScheme, textTheme),

                        // Bottom comment input
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Divider(height: 1),
                            _buildCommentInput(colorScheme, textTheme),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ));
  }

  // Safely extract comments from any state
  List<CommentModel> _getCommentsFromState(PostState state) {
    // Post is already available; just filter comments for this post
    return List<CommentModel>.from(
      state.comments.values.where((c) => c.postId == widget.post.id),
    );
  }

  // Helper method to fetch user details
  void _fetchUserDetails(List<CommentModel> displayComments) {
    final uniqueUserIds = displayComments
        .map((c) => c.userId)
        .where((id) => id.isNotEmpty && id != 'you')
        .toSet()
        .toList();

    if (uniqueUserIds.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<UserBloc>().add(
                LoadMultipleUsersEvent(userIds: uniqueUserIds),
              );
        }
      });
    }
  }

  // Helper method for auto-expanding parents
  void _autoExpandParentsIfNeeded(List<CommentModel> displayComments) {
    if (!_autoExpanded && displayComments.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final parentIds = displayComments
            .where((c) => (c.parentCommentId == null ||
                (c.parentCommentId?.isEmpty ?? true)))
            .map((p) => p.id)
            .toSet();

        final replyParentIds = displayComments
            .where((c) => (c.parentCommentId != null &&
                (c.parentCommentId?.isNotEmpty ?? false)))
            .map((c) => c.parentCommentId!)
            .toSet();

        final toExpand = parentIds.intersection(replyParentIds);

        if (toExpand.isNotEmpty && mounted) {
          setState(() {
            _expandedParents.addAll(toExpand);
            _autoExpanded = true;
          });
        } else {
          _autoExpanded = true;
        }
      });
    }
  }

  Widget _buildEmptyCommentsView(ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mode_comment_outlined,
              size: 42, color: colorScheme.outline),
          const SizedBox(height: 8),
          Text('No comments yet',
              style:
                  textTheme.bodyMedium?.copyWith(color: colorScheme.outline)),
          const SizedBox(height: 4),
          Text('Be the first to share your thoughts',
              style: textTheme.bodySmall?.copyWith(color: colorScheme.outline)),
        ],
      ),
    );
  }

  Widget _buildCommentsListView(BuildContext context, ColorScheme colorScheme,
      TextTheme textTheme, List<CommentModel> displayComments) {
    return RepaintBoundary(
      child: Scrollbar(
        controller: _listController,
        interactive: true,
        child: ListView(
          controller: _listController,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          children: [
            ..._buildThreadedComments(
                context, colorScheme, textTheme, displayComments),
            AnimatedOpacity(
              opacity: _isLoadingMoreComments ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: _isLoadingMoreComments
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildThreadedComments(
      BuildContext context,
      ColorScheme colorScheme,
      TextTheme textTheme,
      List<CommentModel> comments) {
    // Build maps for recursive rendering
    final Map<String, CommentModel> idToComment = {
      for (final c in comments) c.id: c,
    };
    final Map<String, List<CommentModel>> childrenMap = {};
    final List<CommentModel> roots = [];
    final Set<String> allIds = idToComment.keys.toSet();
    final Set<String> orphanParentIds = <String>{};
    for (final c in comments) {
      final parentId =
          (c.parentCommentId == null || (c.parentCommentId?.isEmpty ?? true))
              ? null
              : c.parentCommentId;
      if (parentId == null) {
        roots.add(c);
      } else {
        // Only attach if parent exists; otherwise mark as orphan (hidden)
        if (!allIds.contains(parentId)) {
          orphanParentIds.add(parentId);
          continue;
        }
        childrenMap.putIfAbsent(parentId, () => []).add(c);
      }
    }
    // Apply sort (Facebook-like: allow Newest/Oldest)
    int cmp(DateTime a, DateTime b) => _sort == CommentSort.newest
        ? b.compareTo(a) // newest first
        : a.compareTo(b); // oldest first
    roots.sort((a, b) => cmp(a.createdAt, b.createdAt));
    for (final entry in childrenMap.entries) {
      entry.value.sort((a, b) => cmp(a.createdAt, b.createdAt));
    }

    // If we detected orphans, trigger a refresh to try to fetch their parents
    if (orphanParentIds.isNotEmpty && !_orphanFetchTriggered) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _orphanFetchTriggered = true;
      });
    }

    List<Widget> items = [];
    for (final root in roots) {
      items.addAll(_buildCommentNode(
          context, colorScheme, textTheme, root, childrenMap, idToComment, 0));
    }
    return items;
  }

  List<Widget> _buildCommentNode(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    CommentModel node,
    Map<String, List<CommentModel>> childrenMap,
    Map<String, CommentModel> idToComment,
    int depth,
  ) {
    final List<Widget> widgets = [];
    widgets.add(_commentTile(context, node, colorScheme, textTheme,
        idToComment: idToComment, isChild: depth > 0));
    final children = childrenMap[node.id] ?? const <CommentModel>[];
    if (children.isNotEmpty) {
      final expanded = _expandedParents.contains(node.id);
      widgets.add(
        Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width - 24,
            ),
            child: OutlinedButton.icon(
              icon: Icon(
                expanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              label: Text(
                expanded ? 'Hide replies' : 'View replies (${children.length})',
                style: textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.35)),
                shape: const StadiumBorder(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                visualDensity: VisualDensity.compact,
                backgroundColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.06),
              ),
              onPressed: () {
                services.HapticFeedback.selectionClick();
                final wasExpanded = _expandedParents.contains(node.id);
                setState(() {
                  if (wasExpanded) {
                    _expandedParents.remove(node.id);
                  } else {
                    _expandedParents.add(node.id);
                  }
                });
                // Smoothly scroll down a bit to reveal replies when expanding
                if (!wasExpanded) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_listController.hasClients) {
                      final current = _listController.position.pixels;
                      final target = (current + (children.length * 72))
                          .clamp(0.0, _listController.position.maxScrollExtent);
                      _listController.animateTo(
                        target,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  });
                }
              },
            ),
          ),
        ),
      );
      if (expanded) {
        // Cap indent by both screen width and a sane max (e.g., 96px)

        final double indent = (12.0);
        for (final child in children) {
          widgets.add(Padding(
            padding: EdgeInsets.only(left: indent),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildCommentNode(
                context,
                colorScheme,
                textTheme,
                child,
                childrenMap,
                idToComment,
                depth + 1,
              ),
            ),
          ));
        }
      }
    }
    return widgets;
  }

  Widget _commentTile(
    BuildContext context,
    CommentModel c,
    ColorScheme colorScheme,
    TextTheme textTheme, {
    required Map<String, CommentModel> idToComment,
    bool isChild = false,
  }) {
    final bool isPending = c.id.startsWith('pending_');
    final CommentSendStatus? sendStatus = _pendingStatus[c.id];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlocBuilder<UserBloc, UserState>(
            buildWhen: (prev, next) => true,
            builder: (context, state) {
              String? name;
              String? avatar;
              bool hasData = false;
              if (state is UserLoaded) {
                final u = state.users[c.userId];
                if (u != null) {
                  name = u.name;
                  avatar = u.avatar;
                  hasData = true;
                }
              }
              if (!hasData) {
                return const _ShimmerCircle(size: 36);
              }
              return CircleAvatar(
                radius: 18,
                backgroundImage: (avatar != null &&
                        avatar.isNotEmpty &&
                        avatar.startsWith('http'))
                    ? NetworkImage(avatar) as ImageProvider
                    : null,
                child: (avatar == null ||
                        avatar.isEmpty ||
                        !avatar.startsWith('http'))
                    ? Text(
                        (name?.isNotEmpty == true
                                ? name!.substring(0, 1)
                                : (c.userId.isEmpty ? 'U' : c.userId[0]))
                            .toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )
                    : null,
              );
            },
          ),
          const SizedBox(width: 10),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: () {
                  final base = colorScheme.surfaceContainerHighest
                      .withOpacity(isChild ? 0.35 : 0.5);
                  switch (sendStatus) {
                    case CommentSendStatus.sending:
                      return colorScheme.primary.withOpacity(0.06);
                    case CommentSendStatus.success:
                      return Colors.green.withOpacity(0.10);
                    case CommentSendStatus.error:
                      return colorScheme.error.withOpacity(0.10);
                    default:
                      return base;
                  }
                }(),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: BlocBuilder<UserBloc, UserState>(
                          buildWhen: (prev, next) => true,
                          builder: (context, state) {
                            if (state is! UserLoaded ||
                                state.users[c.userId] == null) {
                              return _ShimmerLine(
                                width: 100,
                                height: 14,
                                borderRadius: 6,
                              );
                            }
                            final u = state.users[c.userId]!;
                            final displayName =
                                u.name.isNotEmpty ? u.name : (c.userId);
                            return Text(
                              displayName,
                              style: textTheme.labelLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                              overflow: TextOverflow.ellipsis,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _relativeTime(c.createdAt),
                        style: textTheme.labelSmall
                            ?.copyWith(color: colorScheme.outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (isChild && (c.parentCommentId?.isNotEmpty ?? false))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2.0),
                      child: BlocBuilder<UserBloc, UserState>(
                        buildWhen: (p, n) => true,
                        builder: (context, state) {
                          final parent = idToComment[c.parentCommentId];
                          if (parent == null) {
                            return const SizedBox.shrink();
                          }
                          if (state is! UserLoaded ||
                              state.users[parent.userId] == null) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _ShimmerLine(
                                    width: 80, height: 12, borderRadius: 6),
                              ],
                            );
                          }
                          final u = state.users[parent.userId]!;
                          final parentName = u.name.isNotEmpty
                              ? u.name
                              : (parent.userId.isNotEmpty
                                  ? parent.userId
                                  : 'Parent');
                          return Text(
                            'Replying to $parentName',
                            style: textTheme.labelSmall
                                ?.copyWith(color: colorScheme.outline),
                          );
                        },
                      ),
                    ),
                  Opacity(
                    opacity: sendStatus == CommentSendStatus.sending ? 0.6 : 1,
                    child: _ExpandableText(
                      c.comment,
                      style: textTheme.bodyMedium,
                      trimLines: 3,
                      seeMoreText: 'See more',
                      seeLessText: 'See less',
                    ),
                  ),
                  if (isPending)
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      child: () {
                        if (sendStatus == CommentSendStatus.error) {
                          return Padding(
                            key: const ValueKey('error'),
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline,
                                    size: 16, color: Colors.red),
                                const SizedBox(width: 6),
                                Text(
                                  'Failed',
                                  style: textTheme.labelSmall
                                      ?.copyWith(color: colorScheme.error),
                                ),
                                const SizedBox(width: 8),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _pendingStatus[c.id] =
                                          CommentSendStatus.sending;
                                      _lastPendingId = c.id;
                                    });
                                    final parent = c.parentCommentId;
                                    if (parent != null && parent.isNotEmpty) {
                                      context
                                          .read<PostBloc>()
                                          .add(setreplycomment(
                                            postId: c.postId,
                                            parentCommentId: parent,
                                            content: c.comment,
                                          ));
                                    } else {
                                      context.read<PostBloc>().add(setcomment(
                                            postId: c.postId,
                                            content: c.comment,
                                          ));
                                    }
                                  },
                                  child: const Text('Retry'),
                                )
                              ],
                            ),
                          );
                        }
                        if (sendStatus == CommentSendStatus.success) {
                          return Padding(
                            key: const ValueKey('success'),
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Row(
                              children: const [
                                Icon(Icons.check_circle,
                                    size: 16, color: Colors.green),
                                SizedBox(width: 6),
                                Text('Sent')
                              ],
                            ),
                          );
                        }
                        // sending default
                        return Padding(
                          key: const ValueKey('sending'),
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      colorScheme.outline),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text('Sending...',
                                  style: textTheme.labelSmall
                                      ?.copyWith(color: colorScheme.outline)),
                            ],
                          ),
                        );
                      }(),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                            minimumSize: const Size(0, 32),
                            padding: const EdgeInsets.symmetric(horizontal: 8)),
                        onPressed: () {
                          setState(() {
                            _replyingTo = c;
                            _replyingToCommentId = c.id;
                          });
                          debugPrint('[UI][ReplyTap] selectedParentId=${c.id}');
                          _inputFocusNode.requestFocus();
                        },
                        child: const Text('Reply'),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                            minimumSize: const Size(0, 32),
                            padding: const EdgeInsets.symmetric(horizontal: 8)),
                        onPressed: () {
                          setState(() {
                            final liked = _likedComments.contains(c.id);
                            if (liked) {
                              _likedComments.remove(c.id);
                              _commentLikes[c.id] =
                                  (_commentLikes[c.id] ?? 1) - 1;
                            } else {
                              _likedComments.add(c.id);
                              _commentLikes[c.id] =
                                  (_commentLikes[c.id] ?? 0) + 1;
                            }
                          });
                        },
                        child: Text(
                          (_commentLikes[c.id] ?? 0) > 0
                              ? 'Like (${_commentLikes[c.id]})'
                              : 'Like',
                          style: textTheme.labelMedium?.copyWith(
                            color: _likedComments.contains(c.id)
                                ? Colors.blue
                                : colorScheme.onSurface,
                            fontWeight: _likedComments.contains(c.id)
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyingToChip(ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Text('Replying to: ',
                    style: textTheme.labelSmall
                        ?.copyWith(color: colorScheme.primary)),
                BlocBuilder<UserBloc, UserState>(
                  buildWhen: (p, n) => true,
                  builder: (context, state) {
                    String displayName = 'User';
                    final uid = _replyingTo!.userId;
                    if (uid.isNotEmpty && state is UserLoaded) {
                      final u = state.users[uid];
                      if (u != null && u.name.isNotEmpty) {
                        displayName = u.name;
                      } else {
                        displayName = uid; // fallback
                      }
                    } else if (uid.isNotEmpty) {
                      displayName = uid; // fallback while loading
                    }
                    return Text(
                      displayName,
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() {
                _replyingTo = null;
                _replyingToCommentId = null;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput(ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: commentController,
        builder: (context, value, _) {
          final canSend = value.text.trim().isNotEmpty && !_isSending;
          return Row(
            children: [
              Expanded(
                child: TextField(
                  controller: commentController,
                  focusNode: _inputFocusNode,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (v) => _addComment(v.trim()),
                  enabled: !_isSending,
                  decoration: InputDecoration(
                    hintText: 'Write a comment...',
                    hintStyle: TextStyle(color: colorScheme.outline),
                    filled: true,
                    fillColor: colorScheme.surface,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(
                          color: colorScheme.outline.withOpacity(0.3)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: canSend
                    ? () => _addComment(commentController.text.trim())
                    : null,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: canSend
                        ? colorScheme.primary
                        : colorScheme.outline.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: _isSending
                      ? SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                colorScheme.onPrimary),
                          ),
                        )
                      : Icon(Icons.send, color: colorScheme.onPrimary),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

class _ExpandableText extends StatefulWidget {
  const _ExpandableText(
    this.text, {
    this.style,
    this.trimLines = 3,
    this.seeMoreText = 'See more',
    this.seeLessText = 'See less',
  });

  final String text;
  final TextStyle? style;
  final int trimLines;
  final String seeMoreText;
  final String seeLessText;

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final linkColor = Theme.of(context).colorScheme.primary;
    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: widget.text, style: widget.style),
          maxLines: widget.trimLines,
          textDirection: Directionality.of(context),
        )..layout(maxWidth: constraints.maxWidth);

        final bool overflow = painter.didExceedMaxLines;

        if (!overflow) {
          return Text(widget.text, style: widget.style);
        }

        final text = Text(
          widget.text,
          style: widget.style,
          maxLines: _expanded ? null : widget.trimLines,
          overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
        );

        final toggle = InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              _expanded ? widget.seeLessText : widget.seeMoreText,
              style: (widget.style ?? const TextStyle())
                  .copyWith(color: linkColor, fontWeight: FontWeight.w600),
            ),
          ),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [text, toggle],
        );
      },
    );
  }
}

enum CommentSort { newest, oldest }

// -------- Shimmer widgets (top-level) --------
class _ShimmerBox extends StatefulWidget {
  const _ShimmerBox({
    required this.width,
    required this.height,
    this.borderRadius = 8,
    this.shape = BoxShape.rectangle,
  });

  final double width;
  final double height;
  final double borderRadius;
  final BoxShape shape;

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _curve;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _curve = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.surfaceVariant;
    final highlight = Colors.white.withOpacity(0.35);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final percent = _curve.value;
        return ShaderMask(
          shaderCallback: (rect) {
            final width = rect.width;
            final gradientWidth = width * 0.8;
            final dx = (width + gradientWidth) * percent - gradientWidth;
            return LinearGradient(
              colors: [
                baseColor,
                baseColor,
                highlight,
                baseColor,
                baseColor,
              ],
              stops: const [0.10, 0.30, 0.50, 0.70, 0.90],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              transform: GradientTranslation(dx, 0),
            ).createShader(rect);
          },
          child: child,
          blendMode: BlendMode.srcATop,
        );
      },
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withOpacity(0.6),
          shape: widget.shape,
          borderRadius: widget.shape == BoxShape.circle
              ? null
              : BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}

class GradientTranslation extends GradientTransform {
  const GradientTranslation(this.dx, this.dy);
  final double dx;
  final double dy;
  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.identity()..translate(dx, dy);
  }
}

class _ShimmerLine extends StatelessWidget {
  const _ShimmerLine({
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return _ShimmerBox(
      width: width,
      height: height,
      borderRadius: borderRadius,
      shape: BoxShape.rectangle,
    );
  }
}

class _ShimmerCircle extends StatelessWidget {
  const _ShimmerCircle({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return _ShimmerBox(
      width: size,
      height: size,
      shape: BoxShape.circle,
    );
  }
}
