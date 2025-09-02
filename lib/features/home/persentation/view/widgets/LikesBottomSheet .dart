import 'package:buldm/core/Dependency_njection/service_locator.dart';
import 'package:buldm/features/auth/domain/entities/userentities.dart';
import 'package:buldm/features/auth/presentaion/view/bloc/auth_cubit.dart';
import 'package:buldm/features/auth/presentaion/view/bloc/auth_state.dart';
import 'package:buldm/features/home/persentation/bloc/post/post_bloc.dart';
import 'package:buldm/features/home/persentation/bloc/post/post_state.dart';
import 'package:buldm/features/home/persentation/bloc/user/user_bloc.dart';
import 'package:buldm/features/home/persentation/bloc/user/user_event.dart';
import 'package:buldm/features/home/persentation/bloc/user/user_state.dart';
import 'package:buldm/features/profile/presentation/blocs/profile/profile_cubit.dart';
import 'package:buldm/features/profile/presentation/blocs/profilechanges/profilechanges_cubit.dart';
import 'package:buldm/features/profile/presentation/view/screens/OtherUserProfileScreen.dart';
import 'package:buldm/features/profile/presentation/view/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LikesBottomSheet extends StatefulWidget {
  final List<String> userIds; // initial page (already loaded outside)
  final String postId;

  const LikesBottomSheet({
    required this.userIds,
    required this.postId,
  });

  @override
  State<LikesBottomSheet> createState() => _LikesBottomSheetState();
}

class _LikesBottomSheetState extends State<LikesBottomSheet> {
  final ScrollController _scrollController = ScrollController();

  // pagination state
  int _currentPage = 1;
  final int _limit = 20;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  DateTime? _lastPaginationTime;

  // data
  List<String> _allUserIds = [];

  @override
  void initState() {
    super.initState();

    _allUserIds = List<String>.from(widget.userIds);

    // Better initialization - determine if we have more data based on initial batch size
    // If initial batch is less than limit, we likely don't have more data
    if (widget.userIds.length < _limit) {
      _hasMoreData = false;
      print(
          '🔄 Initial batch (${widget.userIds.length}) < limit ($_limit) - Setting hasMoreData = false');
    } else {
      _hasMoreData = true;
      print(
          '🔄 Initial batch (${widget.userIds.length}) >= limit ($_limit) - Setting hasMoreData = true');
    }

    print(
        '📊 LikesBottomSheet initialized - Users: ${widget.userIds.length}, Limit: $_limit, HasMore: $_hasMoreData');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupScrollListener();
      _maybeAutoLoadIfNotScrollable();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // Enhanced scroll listener method with improved triggering for end-of-scroll pagination
  void _onScroll() {
    if (!_scrollController.hasClients || !mounted) return;

    final position = _scrollController.position;

    // Skip if there's no scrollable content yet
    if (position.maxScrollExtent <= 0) return;

    // More aggressive end-of-scroll detection
    final threshold =
        position.maxScrollExtent - 50; // Reduced from 150px to 50px
    final isNearBottom = position.pixels >= threshold;

    // Check if we're exactly at the end
    final isAtEnd = position.pixels >= position.maxScrollExtent;

    // Check scroll percentage for earlier triggering
    final scrollPercentage = position.pixels / position.maxScrollExtent;
    final isPastThreshold =
        scrollPercentage >= 0.85; // Increased from 75% to 85%

    print(
        '📍 Scroll Debug - pixels: ${position.pixels.toStringAsFixed(2)}, max: ${position.maxScrollExtent.toStringAsFixed(2)}, percentage: ${(scrollPercentage * 100).toStringAsFixed(1)}%, hasMore: $_hasMoreData, loading: $_isLoadingMore');

    // Trigger load more if any condition is met
    if ((isAtEnd || isNearBottom || isPastThreshold) &&
        _hasMoreData &&
        !_isLoadingMore) {
      print(
          '🚀 Pagination triggered - isAtEnd: $isAtEnd, isNearBottom: $isNearBottom, isPastThreshold: $isPastThreshold');
      _loadMoreLikes();
    }
  }

  void _setupScrollListener() {
    // Remove any existing listener first
    _scrollController.removeListener(_onScroll);
    // Add the enhanced scroll listener
    _scrollController.addListener(_onScroll);

    // Also add NotificationListener for ScrollEndNotification as backup
    print('📋 Scroll listener setup complete with enhanced end-detection');
  }

  // If the initial batch is too small to create scroll boundaries, auto-fetch next page once.
  void _maybeAutoLoadIfNotScrollable() {
    if (!_scrollController.hasClients) {
      // Try again next frame if not mounted/laid out yet
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _maybeAutoLoadIfNotScrollable());
      return;
    }

    final pos = _scrollController.position;
    final notScrollable = pos.maxScrollExtent <= 0;

    if (notScrollable && _hasMoreData && !_isLoadingMore) {
      // Add a small delay to ensure UI is settled
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted && _hasMoreData && !_isLoadingMore) {
          _loadMoreLikes();
        }
      });
    }
  }

  void _loadMoreLikes() {
    if (_isLoadingMore || !_hasMoreData || !mounted) return;

    // Reduced debounce interval for more responsive pagination
    final now = DateTime.now();
    if (_lastPaginationTime != null &&
        now.difference(_lastPaginationTime!).inMilliseconds < 300) {
      print('⏱️ Pagination debounced - too soon since last call');
      return;
    }
    _lastPaginationTime = now;

    print(
        '🔄 Loading more likes - Page: ${_currentPage + 1}, Current users: ${_allUserIds.length}');

    setState(() {
      _isLoadingMore = true;
      _currentPage += 1;
    });

    context.read<PostBloc>().add(
          Getlike(
            postId: widget.postId,
            page: _currentPage,
            limit: _limit,
          ),
        );
  }

  void _refreshLikes() {
    setState(() {
      _currentPage = 1;
      _isLoadingMore = false;
      _hasMoreData = true;
      _allUserIds.clear();
      _lastPaginationTime = null; // Reset debounce timer
    });

    context
        .read<PostBloc>()
        .add(Getlike(postId: widget.postId, page: 1, limit: _limit));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<PostBloc, PostState>(
      listenWhen: (prev, next) =>
          prev.status != next.status &&
          (next.status == PostStatus.likeLoadSuccess ||
              next.status == PostStatus.likeLoadError),
      listener: (context, state) {
        if (state.status == PostStatus.likeLoadSuccess) {
          final likesSet = state.likes[widget.postId];
          final newUserIds =
              likesSet != null ? List<String>.from(likesSet) : <String>[];

          print(
              '✅ Pagination success - Page: $_currentPage, Received: ${newUserIds.length} users');

          setState(() {
            // Merge pages (deduplicate)
            if (_currentPage == 1) {
              _allUserIds = newUserIds;
              print('📝 First page - Total users: ${_allUserIds.length}');
            } else {
              final existing = Set<String>.from(_allUserIds);
              final uniqueNew =
                  newUserIds.where((id) => !existing.contains(id));
              _allUserIds.addAll(uniqueNew);
              print(
                  '📝 Page $_currentPage merged - Added: ${uniqueNew.length}, Total: ${_allUserIds.length}');
            }

            // Enhanced pagination logic using both total count and page size
            final postFromState = state.posts[widget.postId];
            final totalCount = postFromState?.likesCount;

            if (totalCount != null) {
              // Use authoritative total count from post
              _hasMoreData = _allUserIds.length < totalCount;
              print(
                  '📊 Using total count: $_hasMoreData (${_allUserIds.length}/$totalCount)');
            } else {
              // Fallback: if received fewer items than limit, no more data
              _hasMoreData = newUserIds.length >= _limit;
              print(
                  '📊 Using page size logic: $_hasMoreData (received: ${newUserIds.length}, limit: $_limit)');
            }

            _isLoadingMore = false;
            print(
                '🏁 Pagination state - HasMore: $_hasMoreData, Loading: $_isLoadingMore');
          });

          // Load user objects for the IDs just received
          if (newUserIds.isNotEmpty) {
            context
                .read<UserBloc>()
                .add(LoadMultipleUsersEvent(userIds: newUserIds));
          }

          // If still not scrollable after append (rare), try one more auto-load
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _maybeAutoLoadIfNotScrollable();
          });
        } else if (state.status == PostStatus.likeLoadError) {
          print(
              '❌ Pagination error - Page: $_currentPage, Error: ${state.message}');

          setState(() {
            _isLoadingMore = false; // allow retry
            // Don't increment page on error, so retry will use same page
            if (_currentPage > 1) {
              _currentPage -= 1;
              print('⬅️ Reverted to page $_currentPage for retry');
            }
          });

          // Show error snackbar for pagination errors (not initial load)
          if (_currentPage >= 1) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Failed to load more likes: ${state.message ?? 'Unknown error'}'),
                action:
                    SnackBarAction(label: 'Retry', onPressed: _loadMoreLikes),
                duration: const Duration(seconds: 4),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        }
      },
      child: BlocBuilder<PostBloc, PostState>(
        buildWhen: (prev, next) {
          final prevPost = prev.posts[widget.postId];
          final nextPost = next.posts[widget.postId];
          final countChanged = prevPost?.likesCount != nextPost?.likesCount;
          final statusChanged = prev.status != next.status &&
              (next.status == PostStatus.likeLoadSuccess ||
                  next.status == PostStatus.likeLoadError ||
                  next.status == PostStatus.likeToggleSuccess);
          return countChanged || statusChanged;
        },
        builder: (context, postState) {
          final postFromState = postState.posts[widget.postId];
          final authoritativeLikeCount =
              postFromState?.likesCount ?? _allUserIds.length;
          final displayCount = postFromState != null
              ? authoritativeLikeCount
              : _allUserIds.length;

          return Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.surface,
                  theme.colorScheme.surface.withOpacity(0.98),
                ],
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(25)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 25,
                  offset: const Offset(0, -10),
                ),
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  blurRadius: 40,
                  offset: const Offset(0, -20),
                ),
              ],
            ),
            child: SafeArea(
              top: true,
              bottom: true,
              child: Column(
                children: [
                  // Modern glassmorphic header
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withOpacity(0.9),
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(25)),
                      border: Border(
                        bottom: BorderSide(
                          color: theme.colorScheme.outline.withOpacity(0.08),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Animated handle bar
                        Container(
                          width: 60,
                          height: 6,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary.withOpacity(0.4),
                                theme.colorScheme.primary,
                                theme.colorScheme.primary.withOpacity(0.4),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    theme.colorScheme.primary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Enhanced header content
                        Row(
                          children: [
                            // Gradient heart container
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    theme.colorScheme.primary,
                                    theme.colorScheme.primary.withOpacity(0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.favorite_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 20),

                            // Title section
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Liked by',
                                    style: theme.textTheme.headlineMedium
                                        ?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.8,
                                      height: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'People who loved this post ✨',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: theme.colorScheme.outline,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Stats container with animation
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.primaryContainer
                                        .withOpacity(0.4),
                                    theme.colorScheme.primaryContainer
                                        .withOpacity(0.2),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: theme.colorScheme.primary
                                      .withOpacity(0.3),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  if (_isLoadingMore) ...[
                                    SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          theme.colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                  ],
                                  Text(
                                    '$displayCount',
                                    style:
                                        theme.textTheme.headlineSmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 24,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  if (_allUserIds.length != displayCount) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      '${_allUserIds.length} loaded',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.outline,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            const SizedBox(width: 16),

                            // Premium close button
                            GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: theme.colorScheme.outline
                                        .withOpacity(0.15),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 12,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                  size: 22,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Page indicator with better styling
                        if (_currentPage > 1) ...[
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primary.withOpacity(0.15),
                                  theme.colorScheme.primary.withOpacity(0.08),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color:
                                    theme.colorScheme.primary.withOpacity(0.25),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.layers_rounded,
                                  size: 16,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Page $_currentPage',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // list - Now takes most of the screen
                  Expanded(
                    child: BlocBuilder<UserBloc, UserState>(
                      builder: (context, userState) {
                        Map<String, User> users = {};
                        if (userState is UserLoaded) users = userState.users;

                        return NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification scrollInfo) {
                            // Additional scroll end detection as backup
                            if (scrollInfo is ScrollEndNotification) {
                              final metrics = scrollInfo.metrics;
                              final isAtEnd =
                                  metrics.pixels >= metrics.maxScrollExtent;
                              final isNearEnd = metrics.pixels >=
                                  (metrics.maxScrollExtent - 30);

                              print(
                                  '📱 ScrollEndNotification - pixels: ${metrics.pixels.toStringAsFixed(2)}, max: ${metrics.maxScrollExtent.toStringAsFixed(2)}, isAtEnd: $isAtEnd');

                              if ((isAtEnd || isNearEnd) &&
                                  _hasMoreData &&
                                  !_isLoadingMore) {
                                print(
                                    '🚀 Backup pagination triggered by ScrollEndNotification');
                                Future.delayed(
                                    Duration.zero, () => _loadMoreLikes());
                              }
                            }
                            return false;
                          },
                          child: RefreshIndicator(
                            color: theme.colorScheme.primary,
                            backgroundColor: theme.colorScheme.surface,
                            strokeWidth: 3,
                            displacement: 60,
                            onRefresh: () async {
                              _refreshLikes();
                              await Future.delayed(
                                  const Duration(milliseconds: 400));
                            },
                            child: ListView.separated(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding:
                                  const EdgeInsets.fromLTRB(16, 12, 16, 24),
                              itemCount: _allUserIds.length +
                                  (_isLoadingMore ? 1 : 0) +
                                  (!_hasMoreData &&
                                          _allUserIds.isNotEmpty &&
                                          _currentPage > 1
                                      ? 1
                                      : 0),
                              separatorBuilder: (_, index) {
                                if (index >= _allUserIds.length - 1) {
                                  return const SizedBox.shrink();
                                }
                                return Container(
                                  height: 12,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        theme.dividerColor.withOpacity(0.05),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                );
                              },
                              itemBuilder: (context, index) {
                                // Enhanced loading indicator
                                if (index == _allUserIds.length &&
                                    _isLoadingMore) {
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 24),
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          theme.colorScheme.primary
                                              .withOpacity(0.05),
                                          theme.colorScheme.primary
                                              .withOpacity(0.02),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: theme.colorScheme.primary
                                            .withOpacity(0.1),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                theme.colorScheme.primary
                                                    .withOpacity(0.1),
                                                theme.colorScheme.primary
                                                    .withOpacity(0.05),
                                              ],
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: SizedBox(
                                            height: 32,
                                            width: 32,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 3.5,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                theme.colorScheme.primary,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Loading more amazing people...',
                                          style: theme.textTheme.bodyLarge
                                              ?.copyWith(
                                            color: theme.colorScheme.primary,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Please wait ✨',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: theme.colorScheme.outline,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                // Enhanced "All loaded" footer
                                if (index == _allUserIds.length &&
                                    !_hasMoreData &&
                                    _currentPage > 1) {
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 24),
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          theme.colorScheme.secondary
                                              .withOpacity(0.08),
                                          theme.colorScheme.secondary
                                              .withOpacity(0.03),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: theme.colorScheme.secondary
                                            .withOpacity(0.2),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.secondary
                                                .withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.check_circle_rounded,
                                            size: 20,
                                            color: theme.colorScheme.secondary,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'All hearts collected! 💝',
                                              style: theme.textTheme.bodyLarge
                                                  ?.copyWith(
                                                color:
                                                    theme.colorScheme.secondary,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            Text(
                                              'You\'ve seen everyone who liked this',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                color:
                                                    theme.colorScheme.outline,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                // Enhanced user list item with modern card design
                                final id = _allUserIds[index];
                                final user = users[id];
                                if (user == null) {
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 6),
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surface
                                          .withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: theme.colorScheme.outline
                                            .withOpacity(0.05),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: LinearGradient(
                                              colors: [
                                                theme.colorScheme.primary
                                                    .withOpacity(0.1),
                                                theme.colorScheme.primary
                                                    .withOpacity(0.05),
                                              ],
                                            ),
                                          ),
                                          padding: const EdgeInsets.all(3),
                                          child: CircleAvatar(
                                            radius: 28,
                                            backgroundColor: theme
                                                .colorScheme.outline
                                                .withOpacity(0.1),
                                            child: SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(
                                                  theme.colorScheme.primary
                                                      .withOpacity(0.7),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 20),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                height: 20,
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      theme.colorScheme.outline
                                                          .withOpacity(0.1),
                                                      theme.colorScheme.outline
                                                          .withOpacity(0.05),
                                                      theme.colorScheme.outline
                                                          .withOpacity(0.1),
                                                    ],
                                                    stops: const [
                                                      0.0,
                                                      0.5,
                                                      1.0
                                                    ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Container(
                                                height: 16,
                                                width: 120,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      theme.colorScheme.outline
                                                          .withOpacity(0.08),
                                                      theme.colorScheme.outline
                                                          .withOpacity(0.04),
                                                      theme.colorScheme.outline
                                                          .withOpacity(0.08),
                                                    ],
                                                    stops: const [
                                                      0.0,
                                                      0.5,
                                                      1.0
                                                    ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeOutCubic,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 6),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        theme.colorScheme.surface,
                                        theme.colorScheme.surface
                                            .withOpacity(0.7),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: theme.colorScheme.outline
                                          .withOpacity(0.08),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.colorScheme.shadow
                                            .withOpacity(0.08),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                        spreadRadius: 0,
                                      ),
                                      BoxShadow(
                                        color: theme.colorScheme.primary
                                            .withOpacity(0.04),
                                        blurRadius: 40,
                                        offset: const Offset(0, 20),
                                        spreadRadius: -8,
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(24),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(24),
                                      onTap: () {
                                        // Check if this is the current user
                                        final authState =
                                            context.read<AuthCubit>().state;
                                        if (authState is Authenticated) {
                                          final currentUserId =
                                              authState.user.user_id;

                                          if (user.user_id == currentUserId) {
                                            // Navigate to own profile with BlocProviders
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    MultiBlocProvider(
                                                  providers: [
                                                    BlocProvider<ProfileCubit>(
                                                      create: (context) =>
                                                          sl<ProfileCubit>(),
                                                    ),
                                                    BlocProvider<
                                                        ProfilechangesCubit>(
                                                      create: (context) => sl<
                                                          ProfilechangesCubit>(),
                                                    ),
                                                  ],
                                                  child: const ProfileScreen(),
                                                ),
                                              ),
                                            );
                                          } else {
                                            // Navigate to other user's profile with BlocProviders
                                            final viewerUser = ViewerUser(
                                              id: user.user_id,
                                              name: user.name,
                                              email: user.email,
                                              avatar: user.avatar,
                                            );

                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    MultiBlocProvider(
                                                  providers: [
                                                    BlocProvider<ProfileCubit>(
                                                      create: (context) =>
                                                          sl<ProfileCubit>(),
                                                    ),
                                                    BlocProvider<
                                                        ProfilechangesCubit>(
                                                      create: (context) => sl<
                                                          ProfilechangesCubit>(),
                                                    ),
                                                  ],
                                                  child: OtherUserProfileScreen(
                                                      user: viewerUser),
                                                ),
                                              ),
                                            );
                                          }
                                        } else {
                                          // User not authenticated, show error
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Please log in to view profiles'),
                                            ),
                                          );
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(20),
                                        child: Row(
                                          children: [
                                            // Enhanced avatar container
                                            Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: LinearGradient(
                                                  colors: [
                                                    theme.colorScheme.primary
                                                        .withOpacity(0.15),
                                                    theme.colorScheme.primary
                                                        .withOpacity(0.05),
                                                  ],
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: theme
                                                        .colorScheme.primary
                                                        .withOpacity(0.3),
                                                    blurRadius: 15,
                                                    offset: const Offset(0, 6),
                                                    spreadRadius: -2,
                                                  ),
                                                ],
                                              ),
                                              padding: const EdgeInsets.all(3),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: theme
                                                        .colorScheme.surface,
                                                    width: 2,
                                                  ),
                                                ),
                                                child: CircleAvatar(
                                                  radius: 28,
                                                  backgroundColor: theme
                                                      .colorScheme.primary
                                                      .withOpacity(0.1),
                                                  backgroundImage:
                                                      user.avatar.isNotEmpty
                                                          ? NetworkImage(
                                                              user.avatar)
                                                          : null,
                                                  child: user.avatar.isEmpty
                                                      ? Text(
                                                          user.name.isNotEmpty
                                                              ? user.name[0]
                                                                  .toUpperCase()
                                                              : '?',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w900,
                                                            fontSize: 20,
                                                            color: theme
                                                                .colorScheme
                                                                .primary,
                                                            letterSpacing: -0.5,
                                                          ),
                                                        )
                                                      : null,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 20),
                                            // Enhanced user info section
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    user.name,
                                                    style: theme
                                                        .textTheme.titleMedium
                                                        ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      letterSpacing: -0.3,
                                                      height: 1.2,
                                                      color: theme.colorScheme
                                                          .onSurface,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 12,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          theme.colorScheme
                                                              .primary
                                                              .withOpacity(
                                                                  0.08),
                                                          theme.colorScheme
                                                              .primary
                                                              .withOpacity(
                                                                  0.04),
                                                        ],
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      border: Border.all(
                                                        color: theme
                                                            .colorScheme.primary
                                                            .withOpacity(0.1),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      'Liked this post ✨',
                                                      style: theme
                                                          .textTheme.bodySmall
                                                          ?.copyWith(
                                                        color: theme.colorScheme
                                                            .primary,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        letterSpacing: 0.2,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Enhanced heart icon
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.red
                                                        .withOpacity(0.15),
                                                    Colors.red
                                                        .withOpacity(0.08),
                                                  ],
                                                ),
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.red
                                                        .withOpacity(0.3),
                                                    blurRadius: 12,
                                                    offset: const Offset(0, 4),
                                                    spreadRadius: -2,
                                                  ),
                                                ],
                                              ),
                                              child: const Icon(
                                                Icons.favorite,
                                                color: Colors.red,
                                                size: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
