// features/home/persentation/view/widgets/buildPostActions.dart
import 'dart:async';

import 'package:buldm/core/Dependency_njection/service_locator.dart';
import 'package:buldm/features/auth/domain/entities/userentities.dart';
import 'package:buldm/features/auth/presentaion/view/bloc/auth_cubit.dart';
import 'package:buldm/features/auth/presentaion/view/bloc/auth_state.dart';
import 'package:buldm/features/home/data/models/post_model.dart';
import 'package:buldm/features/home/persentation/bloc/post/post_bloc.dart';
import 'package:buldm/features/home/persentation/bloc/post/post_state.dart';
import 'package:buldm/features/home/persentation/bloc/user/user_bloc.dart';
import 'package:buldm/features/home/persentation/bloc/user/user_event.dart';
import 'package:buldm/features/home/persentation/bloc/user/user_state.dart';
import 'package:buldm/features/home/persentation/view/screens/CommentBottomSheet.dart';
import 'package:buldm/features/map_location/presentation/view/screens/solo_map_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BuildPostActions extends StatefulWidget {
  const BuildPostActions({super.key, required this.post});
  final PostModel post;
  @override
  State<BuildPostActions> createState() => _BuildPostActionsState();
}

class _BuildPostActionsState extends State<BuildPostActions> {
  bool progress = false;
  // Debounce timers keyed by action+postId
  final Map<String, Timer?> debounces = {};
  // Optimistic like state per postId to toggle icon immediately
  final Map<String, bool> _optimisticLiked = {};

  @override
  void dispose() {
    for (final t in debounces.values) {
      t?.cancel();
    }
    debounces.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color surfaceColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withOpacity(0.05)
        : Colors.grey.shade100;

    final textColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: SizedBox(
        height: 44,
        child: ListView(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          children: [
            BlocListener<PostBloc, PostState>(
              listenWhen: (prev, next) => prev.status != next.status,
              listener: (context, state) {
                if (state.status == PostStatus.likeToggleSuccess ||
                    state.status == PostStatus.likeToggleError) {
                  final postId = widget.post.id;
                  if (_optimisticLiked.containsKey(postId)) {
                    setState(() {
                      _optimisticLiked.remove(postId);
                    });
                  }
                }
              },
              child: BlocBuilder<PostBloc, PostState>(
                buildWhen: (prev, next) {
                  // Rebuild when the likesCount of this post changes or when like toggle status changes
                  final prevPost = prev.posts[widget.post.id];
                  final nextPost = next.posts[widget.post.id];
                  final countChanged =
                      (prevPost?.likesCount != nextPost?.likesCount);
                  final statusChanged = prev.status != next.status &&
                      (next.status == PostStatus.likeToggleLoading ||
                          next.status == PostStatus.likeToggleSuccess ||
                          next.status == PostStatus.likeToggleError);
                  return countChanged || statusChanged;
                },
                builder: (context, state) {
                  // Get current post data from bloc state
                  final postId = widget.post.id;
                  final postFromState = state.posts[postId];
                  final currentPost = postFromState ?? widget.post;

                  // Since bloc does not provide per-post isLiked, reflect count and loading state only
                  final likeCount = currentPost.likesCount;

                  // Show loading spinner while like toggle is in progress
                  final isProcessingLike =
                      state.status == PostStatus.likeToggleLoading;
                  // Determine immediate liked state (optimistic first, fallback to bloc)
                  final originalLiked = state.posts[postId]?.isliked ?? false;
                  final isActiveLike =
                      _optimisticLiked[postId] ?? originalLiked;
                  // Compute optimistic like count to match the icon
                  int displayedLikeCount = likeCount +
                      (isActiveLike && !originalLiked ? 1 : 0) -
                      (!isActiveLike && originalLiked ? 1 : 0);
                  if (displayedLikeCount < 0) displayedLikeCount = 0;

                  return _glassAction(
                    icon: isActiveLike ? Icons.favorite : Icons.favorite_border,
                    label: "Like",
                    count: displayedLikeCount,
                    isActive: isActiveLike,
                    isLoading: isProcessingLike,
                    onTap: () async {
                      final debounceKey = 'like_${widget.post.id}';
                      // Optimistic toggle: change icon immediately
                      setState(() {
                        _optimisticLiked[postId] = !isActiveLike;
                      });
                      if (mounted) {
                        // Cancel previous debounce if still pending
                        debounces[debounceKey]?.cancel();

                        // Set up new debounce
                        debounces[debounceKey] = Timer(
                          const Duration(milliseconds: 500),
                          () async {
                            final authState = context.read<AuthCubit>().state;
                            final currentUser = (authState is Authenticated)
                                ? authState.user
                                : null;

                            if (currentUser == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please login to like posts'),
                                ),
                              );
                              // Revert optimistic toggle if not logged in
                              if (mounted) {
                                setState(() {
                                  _optimisticLiked.remove(postId);
                                });
                              }
                              return;
                            }

                            // Send backend request
                            context
                                .read<PostBloc>()
                                .add(setlike(postId: widget.post.id));

                            // Clear debounce after operation is complete
                            debounces[debounceKey] = null;
                          },
                        );
                      }
                    },
                    onLongPress: isProcessingLike
                        ? null
                        : () {
                            // Trigger the get likes event and show loading bottom sheet
                            context
                                .read<PostBloc>()
                                .add(Getlike(postId: widget.post.id));
                            _showLikesBottomSheet([]);
                          },
                    iconColor:
                        isProcessingLike ? Colors.blue : Colors.redAccent,
                    surfaceColor: isProcessingLike
                        ? surfaceColor.withOpacity(0.5)
                        : surfaceColor,
                    textColor: isProcessingLike
                        ? textColor.withOpacity(0.5)
                        : textColor,
                    showLabel: true,
                  );
                },
              ),
            ),
            _glassAction(
              icon: Icons.mode_comment_outlined,
              label: "Comment",
              count: widget.post.commentsCount,
              isLoading: false,
              onTap: () async {
                // Open comments bottom sheet. TODO: connect to real comments list when available.
                final postBloc = context.read<PostBloc>();
                final userBloc = context.read<UserBloc>();
                await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => MultiBlocProvider(
                    providers: [
                      BlocProvider.value(value: postBloc),
                      BlocProvider.value(value: userBloc),
                    ],
                    child: CommentBottomSheet(post: widget.post),
                  ),
                );
              },
              iconColor: Colors.deepPurpleAccent,
              surfaceColor: surfaceColor,
              textColor: textColor,
            ),
            _glassAction(
              icon: Icons.pin_drop_outlined,
              label: "Location",
              isLoading: false,
              onTap: () {
                final route = MaterialPageRoute(
                  builder: (context) => SoloPostLocation(post: widget.post),
                );
                Navigator.push(context, route);
              },
              iconColor: Colors.teal,
              surfaceColor: surfaceColor,
              textColor: textColor,
            ),
            _glassAction(
              icon: Icons.repeat,
              label: "share",
              isLoading: false,
              onTap: () {},
              iconColor: Colors.blueAccent,
              surfaceColor: surfaceColor,
              textColor: textColor,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLikesBottomSheet(List<String> userIds) async {
    // Show loading bottom sheet first
    final postBloc = context.read<PostBloc>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      isScrollControlled: true,
      builder: (context) => BlocProvider.value(
        value: postBloc,
        child: BlocListener<PostBloc, PostState>(
          listenWhen: (prev, next) {
            return prev.status != next.status &&
                (next.status == PostStatus.likeLoadSuccess ||
                    next.status == PostStatus.likeLoadError);
          },
          listener: (context, state) {
            // Close the loading sheet
            Navigator.of(context).pop();

            if (state.status == PostStatus.likeLoadSuccess) {
              // Show success bottom sheet with users
              final likesSet = state.likes[widget.post.id];
              final likesList =
                  likesSet != null ? List<String>.from(likesSet) : <String>[];
              _showSuccessLikesBottomSheet(likesList);
            } else if (state.status == PostStatus.likeLoadError) {
              // Show error bottom sheet
              _showErrorLikesBottomSheet(
                  state.message ?? 'Failed to load likes');
            }
          },
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height * 0.3,
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(
                  MediaQuery.of(context).size.width > 600 ? 24.0 : 16.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).dividerColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    SizedBox(
                        height:
                            MediaQuery.of(context).size.height > 700 ? 32 : 24),
                    SizedBox(
                      width: MediaQuery.of(context).size.width > 600 ? 48 : 40,
                      height: MediaQuery.of(context).size.width > 600 ? 48 : 40,
                      child: CircularProgressIndicator(
                        strokeWidth:
                            MediaQuery.of(context).size.width > 600 ? 4 : 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    SizedBox(
                        height:
                            MediaQuery.of(context).size.height > 700 ? 24 : 16),
                    Text(
                      'Loading likes...',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: MediaQuery.of(context).size.width > 600
                                ? 18
                                : 16,
                            fontWeight: FontWeight.w500,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                        height:
                            MediaQuery.of(context).size.height > 700 ? 32 : 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showSuccessLikesBottomSheet(List<String> userIds) async {
    if (userIds.isEmpty) {
      await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 16),
              Icon(
                Icons.favorite_border,
                size: 48,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 8),
              Text(
                'No likes yet',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (context) => sl<UserBloc>()
                ..add(LoadMultipleUsersEvent(userIds: userIds))),
        ],
        child: _LikesBottomSheet(userIds: userIds),
      ),
    );
  }

  Future<void> _showErrorLikesBottomSheet(String errorMessage) async {
    final postBloc = context.read<PostBloc>();
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => BlocProvider.value(
        value: postBloc,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(modalContext).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(modalContext).dividerColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 16),
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(modalContext).colorScheme.error,
              ),
              const SizedBox(height: 8),
              Text(
                'Error loading likes',
                style: Theme.of(modalContext).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                errorMessage,
                style: Theme.of(modalContext).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(modalContext).colorScheme.outline,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(modalContext).pop();
                  // Retry the request
                  modalContext
                      .read<PostBloc>()
                      .add(Getlike(postId: widget.post.id));
                  _showLikesBottomSheet([]);
                },
                child: const Text('Retry'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCount(int n) {
    if (n >= 1000000) {
      return "${(n / 1000000).toStringAsFixed(n % 1000000 == 0 ? 0 : 1)}M";
    }
    if (n >= 1000) {
      return "${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}K";
    }
    return n.toString();
  }

  Widget _glassAction({
    required IconData icon,
    required String label,
    int? count,
    bool isActive = false,
    bool showLabel = false,
    bool isLoading = false,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
    required Color iconColor,
    required Color surfaceColor,
    required Color textColor,
  }) {
    final Color activeColor = iconColor;
    final Color inactiveIconColor = iconColor.withOpacity(0.75);
    final Color chipBg = surfaceColor;
    final Color badgeTextColor =
        (Theme.of(context).brightness == Brightness.dark)
            ? Colors.white
            : Colors.black;

    return Tooltip(
      message: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        onLongPress: onLongPress,
        splashColor: activeColor.withOpacity(0.12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: chipBg,
            borderRadius: BorderRadius.circular(999),
            border: isActive
                ? Border.all(color: activeColor.withOpacity(0.25), width: 1)
                : null,
            boxShadow: [
              BoxShadow(
                color: activeColor.withOpacity(isActive ? 0.08 : 0.03),
                blurRadius: isActive ? 8 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 140),
                transitionBuilder: (c, a) =>
                    ScaleTransition(scale: a, child: c),
                child: isLoading
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isActive ? activeColor : inactiveIconColor,
                          ),
                        ),
                      )
                    : Icon(
                        icon,
                        key: ValueKey(icon.codePoint ^ (isActive ? 1 : 0)),
                        color: isActive ? activeColor : inactiveIconColor,
                        size: 22,
                      ),
              ),
              if (count != null && count > 0) ...[
                const SizedBox(width: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 140),
                  transitionBuilder: (c, a) =>
                      FadeTransition(opacity: a, child: c),
                  child: Text(
                    _formatCount(count),
                    key: ValueKey("${label}_$count"),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: badgeTextColor,
                    ),
                  ),
                ),
              ] else if (showLabel) ...[
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LikesBottomSheet extends StatelessWidget {
  final List<String> userIds;
  const _LikesBottomSheet({required this.userIds});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, -4)),
        ],
      ),
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                  Text('Liked by',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: BlocBuilder<UserBloc, UserState>(
                builder: (context, state) {
                  Map<String, User> users = {};
                  if (state is UserLoaded) users = state.users;

                  return ListView.separated(
                    shrinkWrap: true,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    itemCount: userIds.length,
                    separatorBuilder: (_, __) => Divider(
                        height: 1, color: theme.dividerColor.withOpacity(0.3)),
                    itemBuilder: (context, index) {
                      final id = userIds[index];
                      final user = users[id];
                      if (user == null) {
                        return ListTile(
                          leading: const CircleAvatar(
                              child: Icon(Icons.person_outline)),
                          title: const SizedBox(
                              height: 16,
                              child: LinearProgressIndicator(minHeight: 4)),
                          subtitle: const Text('Loading...'),
                        );
                      }
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(user.avatar),
                        ),
                        title: Text(user.name,
                            style: theme.textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w600)),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
