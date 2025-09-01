// features/home/persentation/view/screens/PostDetailScreen.dart
import 'dart:async';

import 'package:buldm/features/home/data/models/commentsmodel.dart';
import 'package:buldm/features/home/data/models/post_model.dart';
import 'package:buldm/features/home/persentation/bloc/post/post_bloc.dart';
import 'package:buldm/features/home/persentation/bloc/post/post_state.dart';
import 'package:buldm/features/home/persentation/bloc/user/user_bloc.dart';
import 'package:buldm/features/home/persentation/bloc/user/user_event.dart';
import 'package:buldm/features/home/persentation/bloc/user/user_state.dart';
import 'package:buldm/features/home/persentation/view/screens/PostWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PostDetailScreen extends StatefulWidget {
  final PostModel post;
  final String content;
  final String? commentid;
  PostDetailScreen(
      {super.key, required this.post, required this.content, this.commentid}) {
    print("Comment ID: $commentid");
  }

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMoreComments = false;
  int _currentPage = 1;
  final int _limit = 10;
  bool _hasMoreComments = true;
  final Set<String> _expandedParents = <String>{};
  final Map<String, int> _commentLikes = <String, int>{};
  final Set<String> _likedComments = <String>{};
  final TextEditingController _commentController = TextEditingController();
  String? _replyToCommentId;
  String? _replyToUserName;

  Timer? _scrollDebounce;
  final Map<String, String> _timeAgoCache = {};

  @override
  void initState() {
    super.initState();
    _loadInitialComments();
    _scrollController.addListener(_scrollListener);
  }

  void _loadInitialComments() {
    if (widget.post.id.isEmpty) return;

    setState(() {
      _currentPage = 1;
      _hasMoreComments = true;
      _isLoadingMoreComments = true;
    });

    context.read<PostBloc>().add(
          getcomment(
            postId: widget.post.id,
            page: 1,
            limit: _limit,
          ),
        );
  }

  @override
  void dispose() {
    _scrollDebounce?.cancel();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _commentController.dispose();
    _timeAgoCache.clear();
    _expandedParents.clear();
    _commentLikes.clear();
    _likedComments.clear();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      // Debounce scroll events
      _scrollDebounce?.cancel();
      _scrollDebounce =
          Timer(const Duration(milliseconds: 200), _loadMoreComments);
    }
  }

  void _loadMoreComments() {
    if (_isLoadingMoreComments || !_hasMoreComments) return;

    setState(() {
      _isLoadingMoreComments = true;
    });

    final nextPage = _currentPage + 1;
    context.read<PostBloc>().add(
          getcomment(
            postId: widget.post.id,
            page: nextPage,
            limit: _limit,
          ),
        );
  }

  String _relativeTime(DateTime dt) {
    final cacheKey = dt.toIso8601String();
    if (_timeAgoCache.containsKey(cacheKey)) {
      return _timeAgoCache[cacheKey]!;
    }

    final now = DateTime.now();
    final diff = now.difference(dt);

    String result;
    if (diff.inSeconds < 60) {
      result = 'just now';
    } else if (diff.inMinutes < 60) {
      result = '${diff.inMinutes}m';
    } else if (diff.inHours < 24) {
      result = '${diff.inHours}h';
    } else if (diff.inDays < 7) {
      result = '${diff.inDays}d';
    } else {
      final weeks = (diff.inDays / 7).floor();
      if (weeks < 5) {
        result = '${weeks}w';
      } else {
        final months = (diff.inDays / 30).floor();
        if (months < 12) {
          result = '${months}mo';
        } else {
          final years = (diff.inDays / 365).floor();
          result = '${years}y';
        }
      }
    }

    _timeAgoCache[cacheKey] = result;
    return result;
  }

  @override
  Widget build(BuildContext context) {
    // Clear time cache if it grows too large
    if (_timeAgoCache.length > 100) {
      _timeAgoCache.clear();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Post Details'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<PostBloc, PostState>(
              listener: (context, state) {
                if (state.status == PostStatus.commentLoadSuccess) {
                  // Update pagination state
                  final post = state.posts[widget.post.id];
                  if (post != null) {
                    final newComments = state.comments.values
                        .where((c) => c.postId == widget.post.id)
                        .toList();
                    final loadedAll =
                        newComments.length < _limit * _currentPage;

                    setState(() {
                      _hasMoreComments = !loadedAll;
                      if (!loadedAll) {
                        _currentPage++;
                      }
                      _isLoadingMoreComments = false;
                    });

                    // Request user details for all commenters (cached by UserBloc)
                    final uniqueUserIds = newComments
                        .map((c) => c.userId)
                        .where((id) => id.isNotEmpty)
                        .toSet()
                        .toList();
                    if (uniqueUserIds.isNotEmpty) {
                      context.read<UserBloc>().add(
                            LoadMultipleUsersEvent(userIds: uniqueUserIds),
                          );
                    }
                  }
                } else if (state.status == PostStatus.commentLoadError) {
                  setState(() {
                    _isLoadingMoreComments = false;
                  });
                  // Show error message to user
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message ?? 'Failed to load comments'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state.status == PostStatus.postLoadSuccess ||
                    state.status == PostStatus.commentLoadSuccess ||
                    state.status == PostStatus.commentLoadLoading) {
                  final post = state.posts[widget.post.id];
                  List<CommentModel> comments = [];
                  if (post != null) {
                    comments = state.comments.values
                        .where((c) => c.postId == widget.post.id)
                        .toList();
                  }

                  return SingleChildScrollView(
                    controller: _scrollController,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PostWidget(
                            post: widget.post,
                            index: widget.post.id, // Using post ID as index
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Comments',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ..._buildCommentsList(context, comments),
                          if (_isLoadingMoreComments)
                            const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
          _buildCommentInput(context),
        ],
      ),
    );
  }

  Widget _buildCommentInput(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          border: Border(
            top: BorderSide(color: colorScheme.outline.withOpacity(0.08)),
          ),
        ),
        child: Row(
          children: [
            if (_replyToUserName != null)
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4.0, right: 8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          'Replying to $_replyToUserName',
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          setState(() {
                            _replyToCommentId = null;
                            _replyToUserName = null;
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              flex: 3,
              child: TextField(
                controller: _commentController,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                decoration: InputDecoration(
                  hintText: _replyToUserName != null
                      ? 'Write a reply...'
                      : 'Add a comment...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onSubmitted: (_) => _sendComment(context),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              color: colorScheme.primary,
              onPressed: () => _sendComment(context),
              padding: const EdgeInsets.only(left: 4),
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  void _sendComment(BuildContext context) {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    if (_replyToCommentId != null) {
      context.read<PostBloc>().add(
            setreplycomment(
              postId: widget.post.id,
              parentCommentId: _replyToCommentId!,
              content: text,
            ),
          );
    } else {
      context.read<PostBloc>().add(
            setcomment(
              postId: widget.post.id,
              content: text,
            ),
          );
    }
    setState(() {
      _commentController.clear();
      _replyToCommentId = null;
      _replyToUserName = null;
    });
    // Optionally, scroll to bottom or show a snackbar
  }

  List<Widget> _buildCommentsList(
      BuildContext context, List<CommentModel> comments) {
    if (comments.isEmpty) {
      return [
        const Center(
          child: Text('No comments yet'),
        ),
      ];
    }

    // Build maps for recursive rendering
    final Map<String, CommentModel> idToComment = {
      for (final c in comments) c.id: c,
    };
    for (final c in comments) {
      print("Comment ID: ${c.id}, Parent ID: ${c.parentCommentId}");
    }

    final Map<String, List<CommentModel>> childrenMap = {};
    final List<CommentModel> roots = [];
    final Set<String> allIds = idToComment.keys.toSet();

    for (final c in comments) {
      final parentId =
          (c.parentCommentId == null || (c.parentCommentId?.isEmpty ?? true))
              ? null
              : c.parentCommentId;
      if (parentId == null) {
        roots.add(c);
      } else {
        // Only attach if parent exists
        if (allIds.contains(parentId)) {
          childrenMap.putIfAbsent(parentId, () => []).add(c);
        }
      }
    }

    // Sort roots by date (newest first)
    roots.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Sort children by date (oldest first)
    for (final entry in childrenMap.entries) {
      entry.value.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }

    List<Widget> items = [];
    for (final root in roots) {
      items.addAll(
          _buildCommentNode(context, root, childrenMap, idToComment, 0));
    }

    return items;
  }

  List<Widget> _buildCommentNode(
    BuildContext context,
    CommentModel node,
    Map<String, List<CommentModel>> childrenMap,
    Map<String, CommentModel> idToComment,
    int depth,
  ) {
    final List<Widget> widgets = [];
    widgets.add(_commentTile(context, node, depth > 0));
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
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
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
                final wasExpanded = _expandedParents.contains(node.id);
                setState(() {
                  if (wasExpanded) {
                    _expandedParents.remove(node.id);
                  } else {
                    _expandedParents.add(node.id);
                  }
                });
              },
            ),
          ),
        ),
      );
      if (expanded) {
        final double indent = (12.0);
        for (final child in children) {
          widgets.add(Padding(
            padding: EdgeInsets.only(left: indent),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildCommentNode(
                context,
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

  Widget _commentTile(BuildContext context, CommentModel c, bool isChild) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User avatar with BlocBuilder for UserBloc
          BlocBuilder<UserBloc, UserState>(
            builder: (context, userState) {
              if (userState is UserLoaded &&
                  userState.users.containsKey(c.userId)) {
                final user = userState.users[c.userId]!;
                return CircleAvatar(
                  radius: 18,
                  backgroundImage:
                      user.avatar.isNotEmpty && user.avatar.startsWith('http')
                          ? NetworkImage(user.avatar)
                          : null,
                  child: (user.avatar.isEmpty ||
                          !user.avatar.startsWith('http'))
                      ? Text(
                          user.name.isNotEmpty
                              ? user.name.substring(0, 1).toUpperCase()
                              : (c.userId.isNotEmpty
                                  ? c.userId[0].toUpperCase()
                                  : 'U'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )
                      : null,
                );
              } else {
                // Shimmer loading effect for avatar
                return Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.surfaceVariant.withOpacity(0.6),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }
            },
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest
                    .withOpacity(isChild ? 0.35 : 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: BlocBuilder<UserBloc, UserState>(
                          builder: (context, userState) {
                            if (userState is UserLoaded &&
                                userState.users.containsKey(c.userId)) {
                              final user = userState.users[c.userId]!;
                              return Text(
                                user.name.isNotEmpty ? user.name : c.userId,
                                style: textTheme.labelLarge
                                    ?.copyWith(fontWeight: FontWeight.w700),
                                overflow: TextOverflow.ellipsis,
                              );
                            } else {
                              // Shimmer loading effect for name
                              return Container(
                                height: 14,
                                width: 100,
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceVariant
                                      .withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              );
                            }
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
                  Text(
                    c.comment,
                    style: widget.commentid == c.id
                        ? textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          )
                        : textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w400,
                          ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          minimumSize: const Size(0, 32),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
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
                      TextButton(
                        style: TextButton.styleFrom(
                          minimumSize: const Size(0, 32),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        onPressed: () {
                          setState(() {
                            _replyToCommentId = c.id;
                            _replyToUserName =
                                c.userId; // Or fetch user name if available
                          });
                          FocusScope.of(context).requestFocus(FocusNode());
                        },
                        child: Text(
                          'Reply',
                          style: textTheme.labelMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
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
}
