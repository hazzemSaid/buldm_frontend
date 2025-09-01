import 'package:buldm/core/constants/app_constants.dart';
import 'package:buldm/features/auth/presentaion/view/bloc/auth_cubit.dart';
import 'package:buldm/features/auth/presentaion/view/bloc/auth_state.dart';
import 'package:buldm/features/home/domain/entities/postentity.dart';
import 'package:buldm/features/profile/presentation/view/screens/OtherUserProfileScreen.dart';
import 'package:buldm/l10n/app_localizations.dart';
import 'package:buldm/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart' show Shimmer;

class BuildProfileHeader extends StatelessWidget {
  final PostEntity post;

  const BuildProfileHeader({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: _ProfileHeaderContent(post: post),
    );
  }
}

class _ProfileHeaderContent extends StatefulWidget {
  final PostEntity post;

  const _ProfileHeaderContent({required this.post});

  @override
  State<_ProfileHeaderContent> createState() => _ProfileHeaderContentState();
}

class _ProfileHeaderContentState extends State<_ProfileHeaderContent> {
  bool _isImageError = false;
  void _handleProfileNavigation(
      BuildContext context, Authenticated currentUser) {
    if (widget.post.user_id != currentUser.user.user_id) {
      context.push(
        paths[AppRoute.profileOther.name]!,
        extra: ViewerUser(
          avatar: widget.post.user.avatar,
          name: widget.post.user.name,
          id: widget.post.user_id,
          email: "",
        ),
      );
    } else {
      context.push(paths[AppRoute.profile.name]!);
    }
  }

  void _showPostOptions(BuildContext context, Authenticated currentUser,
      AppLocalizations localization) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.post.user_id == currentUser.user.user_id) ...[
                    _buildListTile(
                      context,
                      icon: Icons.edit,
                      title: localization.editPost,
                      onTap: () => _handleEditPost(context),
                    ),
                    _buildListTile(
                      context,
                      icon: Icons.delete,
                      title: localization.deletePost,
                      onTap: () => _handleDeletePost(context),
                    ),
                  ],
                  _buildListTile(
                    context,
                    icon: Icons.report,
                    title: localization.reportPost,
                    onTap: () => _handleReportPost(context),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  void _handleEditPost(BuildContext context) {
    // TODO: Implement edit post functionality
  }

  void _handleDeletePost(BuildContext context) {
    // TODO: Implement delete post functionality
  }

  void _handleReportPost(BuildContext context) {
    // TODO: Implement report post functionality
  }

  String _formatPostDate(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 7) {
      return DateFormat('MMM dd, yyyy').format(createdAt);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthCubit>().state as Authenticated;
    final localization = AppLocalizations.of(context)!;

    return Padding(
      padding: AppConstants.defaultPadding,
      child: Row(
        children: [
          _buildUserInfo(context, currentUser, localization),
          const Spacer(),
          _buildStatusBadge(localization),
          _buildMoreButton(context, currentUser, localization),
        ],
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context, Authenticated currentUser,
      AppLocalizations localization) {
    return GestureDetector(
      onTap: () => _handleProfileNavigation(context, currentUser),
      child: Semantics(
        button: true,
        label: 'View Profile',
        child: Row(
          children: [
            _buildUserAvatar(),
            const SizedBox(width: AppConstants.smallSpacing),
            _buildUserInfoText(localization),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAvatar() {
    if (_isImageError) {
      return CircleAvatar(
        radius: AppConstants.smallAvatarRadius,
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
        child: Icon(
          Icons.person,
          size: AppConstants.mediumIconSize,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }

    return CircleAvatar(
      radius: AppConstants.smallAvatarRadius,
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      child: ClipOval(
        child: Image.network(
          widget.post.user.avatar,
          width: AppConstants.smallAvatarRadius * 2,
          height: AppConstants.smallAvatarRadius * 2,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            if (!_isImageError) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() => _isImageError = true);
              });
            }
            return Icon(
              Icons.person,
              size: AppConstants.mediumIconSize,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            );
          },
        ),
      ),
    );
  }

  Widget _buildUserInfoText(AppLocalizations localization) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.post.user.name,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          _formatPostDate(widget.post.createdAt),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(AppLocalizations localization) {
    final isFound = widget.post.status.toLowerCase() == 'found';
    final statusColor =
        isFound ? AppConstants.foundStatusColor : AppConstants.lostStatusColor;
    final statusText =
        isFound ? localization.status_found : localization.status_lost;

    return Container(
      padding: AppConstants.smallPadding,
      decoration: BoxDecoration(
        color: statusColor.withOpacity(AppConstants.statusOpacity),
        borderRadius: BorderRadius.circular(AppConstants.smallRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isFound ? Icons.check_circle : Icons.error,
            size: AppConstants.smallIconSize,
            color: statusColor,
          ),
          const SizedBox(width: AppConstants.smallSpacing / 2),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreButton(BuildContext context, Authenticated currentUser,
      AppLocalizations localization) {
    return IconButton(
      icon: Icon(
        Icons.more_horiz,
        size: AppConstants.mediumIconSize,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      onPressed: () => _showPostOptions(context, currentUser, localization),
    );
  }
}

Widget _buildShimmer() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    child: Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 16,
                  color: Colors.white,
                ),
                const SizedBox(height: 4),
                Container(
                  width: 120,
                  height: 12,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          Container(
            width: 80,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 24,
            height: 24,
            color: Colors.white,
          ),
        ],
      ),
    ),
  );
}
