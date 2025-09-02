import 'package:buldm/features/auth/domain/entities/userentities.dart';
import 'package:buldm/features/home/persentation/bloc/post/post_bloc.dart';
import 'package:buldm/features/home/persentation/bloc/post/post_state.dart';
import 'package:buldm/features/home/persentation/bloc/user/user_bloc.dart';
import 'package:buldm/features/home/persentation/bloc/user/user_event.dart';
import 'package:buldm/features/home/persentation/bloc/user/user_state.dart';
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
            height: MediaQuery.of(context).size.height, // Full screen height
            width: MediaQuery.of(context).size.width, // Full screen width
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20)), // Slightly larger radius
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3), // Stronger shadow
                  blurRadius: 16,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            padding:
                const EdgeInsets.only(top: 16, bottom: 0), // Adjusted padding
            child: SafeArea(
              top: true, // Include top safe area for full screen
              bottom: true, // Include bottom safe area
              child: Column(
                mainAxisSize: MainAxisSize.max, // Take maximum available space
                children: [
                  // Close button for full screen
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0, top: 8.0),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.close,
                          color: theme.colorScheme.onSurface,
                          size: 24,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: theme.colorScheme.surface,
                          elevation: 2,
                        ),
                      ),
                    ),
                  ),

                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.dividerColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Icon(Icons.favorite, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Liked by',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        // Show loading indicator in header when paginating
                        if (_isLoadingMore) ...[
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          '$displayCount',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.outline,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_allUserIds.length != displayCount) ...[
                          const SizedBox(width: 4),
                          Text(
                            '(${_allUserIds.length} loaded)',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline.withOpacity(0.7),
                              fontSize: 10,
                            ),
                          ),
                        ],
                        // Show pagination status
                        if (_currentPage > 1) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Page $_currentPage',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

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
                            onRefresh: () async {
                              _refreshLikes();
                              await Future.delayed(
                                  const Duration(milliseconds: 400));
                            },
                            child: ListView.separated(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              itemCount: _allUserIds.length +
                                  (_isLoadingMore ? 1 : 0) +
                                  (!_hasMoreData &&
                                          _allUserIds.isNotEmpty &&
                                          _currentPage > 1
                                      ? 1
                                      : 0),
                              separatorBuilder: (_, index) {
                                // Skip separator for loader/footer rows
                                if (index >= _allUserIds.length - 1) {
                                  return const SizedBox.shrink();
                                }
                                return Divider(
                                    height: 1,
                                    color: theme.dividerColor.withOpacity(0.3));
                              },
                              itemBuilder: (context, index) {
                                // bottom loader
                                if (index == _allUserIds.length &&
                                    _isLoadingMore) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20),
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 28, // Slightly larger loader
                                          width: 28,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 3,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              theme.colorScheme.primary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Loading more likes...',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            color: theme.colorScheme.outline,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                // "All loaded" footer
                                if (index == _allUserIds.length &&
                                    !_hasMoreData &&
                                    _currentPage > 1) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.check_circle_outline,
                                            size: 18,
                                            color: theme.colorScheme.outline),
                                        const SizedBox(width: 8),
                                        Text(
                                          'All likes loaded',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            color: theme.colorScheme.outline,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                // normal item
                                final id = _allUserIds[index];
                                final user = users[id];
                                if (user == null) {
                                  return const ListTile(
                                    leading: CircleAvatar(
                                        child: Icon(Icons.person_outline)),
                                    title: SizedBox(
                                      height: 16,
                                      child:
                                          LinearProgressIndicator(minHeight: 4),
                                    ),
                                    subtitle: Text('Loading...'),
                                  );
                                }

                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 4), // Better spacing
                                  leading: CircleAvatar(
                                    radius: 22, // Slightly larger avatar
                                    backgroundImage: user.avatar.isNotEmpty
                                        ? NetworkImage(user.avatar)
                                        : null,
                                    child: user.avatar.isEmpty
                                        ? Text(
                                            user.name.isNotEmpty
                                                ? user.name[0].toUpperCase()
                                                : '?',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          )
                                        : null,
                                  ),
                                  title: Text(
                                    user.name,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  onTap: () {
                                    // Optional: Add user profile navigation
                                    print('👤 Tapped on user: ${user.name}');
                                  },
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
