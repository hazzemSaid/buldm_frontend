// features/home/persentation/view/widgets/buildPostActions.dart
import 'package:buldm/core/Dependency_njection/service_locator.dart';
import 'package:buldm/features/auth/domain/entities/userentities.dart';
import 'package:buldm/features/auth/presentaion/view/bloc/auth_cubit.dart';
import 'package:buldm/features/auth/presentaion/view/bloc/auth_state.dart';
import 'package:buldm/features/home/domain/entities/postentity.dart';
import 'package:buldm/features/home/persentation/bloc/post/post_bloc.dart';
import 'package:buldm/features/home/persentation/bloc/user/user_bloc.dart';
import 'package:buldm/features/home/persentation/bloc/user/user_event.dart';
import 'package:buldm/features/home/persentation/bloc/user/user_state.dart';
import 'package:buldm/features/home/persentation/view/screens/CommentBottomSheet.dart';
import 'package:buldm/features/map_location/presentation/view/screens/solo_map_location.dart';
import 'package:buldm/features/notifications/integration/notification_integration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BuildPostActions extends StatefulWidget {
  const BuildPostActions(
      {super.key, required this.post, required this.singlePost});
  final PostEntity post;
  final bool singlePost;
  @override
  State<BuildPostActions> createState() => _BuildPostActionsState();
}

class _BuildPostActionsState extends State<BuildPostActions> {
  late bool isLiked;
  late int likeCount;
  DateTime? _lastLikeToggleAt;
  bool isProcessingLike = false;
  @override
  void initState() {
    super.initState();
    // Determine if current user liked the post and initialize counts
    final authState = context.read<AuthCubit>().state;
    final currentUser = (authState is Authenticated) ? authState.user : null;
    isLiked = currentUser != null &&
        widget.post.likes.any((l) => l == currentUser.user_id);
    likeCount = widget.post.likes.length;
    // Ensure we have up-to-date membership (usersIDs) for this post
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (mounted) {
    //     context.read<PostBloc>().add(getlike(postId: widget.post.id));
    //   }
    // });
  }

  @override
  void didUpdateWidget(covariant BuildPostActions oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When parent provides a refreshed PostEntity, merge carefully so we don't
    // drop the user's recent like action due to timing
    final authState = context.read<AuthCubit>().state;
    final currentUser = (authState is Authenticated) ? authState.user : null;
    final bool withinOptimisticWindow = _lastLikeToggleAt != null &&
        DateTime.now().difference(_lastLikeToggleAt!) <
            const Duration(seconds: 3);
    if (currentUser != null && !withinOptimisticWindow) {
      final serverLiked =
          widget.post.likes.any((l) => l == currentUser.user_id);
      setState(() {
        isLiked = serverLiked;
        likeCount = widget.post.likes.length;
      });
    } else if (!withinOptimisticWindow) {
      // No auth or no optimistic state; still sync count from server
      setState(() {
        likeCount = widget.post.likes.length;
      });
    }
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Align(
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              BlocBuilder<PostBloc, PostState>(
                buildWhen: (prev, next) {
                  if (prev is PostLoaded && next is PostLoaded) {
                    try {
                      final prevPost =
                          (prev as PostLoaded).posts[widget.post.id];
                      final nextPost =
                          (next as PostLoaded).posts[widget.post.id];
                      if (prevPost == null || nextPost == null) {
                        return true;
                      }
                      final prevLikes = prevPost.likes.length;
                      final nextLikes = nextPost.likes.length;
                      // Also rebuild if user's own like membership toggled
                      return prevLikes != nextLikes ||
                          (prevPost.likes.length != nextPost.likes.length);
                    } catch (_) {
                      return true;
                    }
                  }
                  return next is PostLoaded || next is PostError;
                },
                builder: (context, state) {
                  // Merge server and local like state to avoid losing the user's action
                  bool liked = isLiked;
                  int count = likeCount;
                  if (state is PostLoaded) {
                    final maybe = state.posts[widget.post.id];

                    try {
                      final int serverCount = maybe!.likes.length;
                      final authState = context.read<AuthCubit>().state;
                      final currentUser =
                          (authState is Authenticated) ? authState.user : null;
                      final bool hasMembershipInfo = maybe.likes.isNotEmpty;
                      bool serverLiked = false;
                      if (currentUser != null && hasMembershipInfo) {
                        serverLiked =
                            maybe.likes.any((l) => l == currentUser.user_id);
                      }

                      // If server provided membership, trust it; otherwise keep local liked
                      liked = hasMembershipInfo ? serverLiked : isLiked;

                      // Count from server is authoritative, but if we're within a short
                      // optimistic window after a toggle, keep local to avoid flicker
                      final bool withinOptimisticWindow =
                          _lastLikeToggleAt != null &&
                              DateTime.now().difference(_lastLikeToggleAt!) <
                                  const Duration(seconds: 3);
                      count = withinOptimisticWindow ? likeCount : serverCount;

                      // If not in optimistic window and server has clear membership info,
                      // sync our local cache to server values
                      if (!withinOptimisticWindow) {
                        isLiked = liked;
                        likeCount = serverCount;
                      }
                    } catch (_) {
                      // Keep local on parsing/shape issues
                    }
                  }
                  return _glassAction(
                    icon: liked ? Icons.favorite : Icons.favorite_border,
                    label: "Like",
                    count: count,
                    isActive: liked,
                    onTap: () async {
                      if (isProcessingLike) return;

                      final wasLiked = isLiked;
                      setState(() {
                        isProcessingLike = true;
                        isLiked = !isLiked;
                        likeCount = likeCount + (isLiked ? 1 : -1);
                        _lastLikeToggleAt = DateTime.now();
                      });

                      context
                          .read<PostBloc>()
                          .add(setlike(postId: widget.post.id));

                      // Send notification only when liking (not unliking)
                      if (!wasLiked && isLiked) {
                        try {
                          await NotificationIntegration.createLikeNotification(
                            postId: widget.post.id,
                            postOwnerId: widget.post.user_id,
                          );
                        } catch (e) {
                          debugPrint('⚠️ Like notification error: $e');
                        }
                      }

                      // ارجع السماح بعد فترة قصيرة أو لما يجي رد من bloc
                      Future.delayed(const Duration(seconds: 1), () {
                        if (mounted) {
                          setState(() => isProcessingLike = false);
                        }
                      });
                    },
                    onLongPress: () {
                      _showLikesBottomSheet(widget.post.likes.toList());
                    },
                    iconColor: Colors.redAccent,
                    surfaceColor: surfaceColor,
                    textColor: textColor,
                  );
                },
              ),
              !widget.singlePost
                  ? _glassAction(
                      icon: Icons.mode_comment_outlined,
                      label: "Comment",
                      count: widget.post.commentsCount,
                      onTap: () async {
                        // Open comments bottom sheet. TODO: connect to real comments list when available.
                        final userbloc = context.read<UserBloc>();
                        final postbloc = context.read<PostBloc>();
                        await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => MultiBlocProvider(
                            providers: [
                              BlocProvider.value(value: postbloc),
                              BlocProvider.value(value: userbloc),
                            ],
                            child: CommentBottomSheet(post: widget.post),
                          ),
                        );
                      },
                      iconColor: Colors.deepPurpleAccent,
                      surfaceColor: surfaceColor,
                      textColor: textColor,
                    )
                  : const SizedBox.shrink(),
              _glassAction(
                icon: Icons.pin_drop_outlined,
                label: "Location",
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
                onTap: () {},
                iconColor: Colors.blueAccent,
                surfaceColor: surfaceColor,
                textColor: textColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showLikesBottomSheet(List<String> userIds) async {
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
          child: Center(
            child: Text(
              'No likes yet',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
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
                child: Icon(
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
