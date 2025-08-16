import 'package:buldm/features/auth/presentaion/view/bloc/auth_cubit.dart';
import 'package:buldm/features/auth/presentaion/view/bloc/auth_state.dart';
import 'package:buldm/features/chat/presentation/view/screens/chatdetailsscreen.dart';
import 'package:buldm/features/home/domain/entities/postentity.dart';
import 'package:buldm/features/home/persentation/bloc/user/user_bloc.dart';
import 'package:buldm/features/map_location/presentation/view/screens/solo_map_location.dart';
import 'package:buldm/features/profile/presentation/view/screens/OtherUserProfileScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BuildPostActions extends StatelessWidget {
  const BuildPostActions({super.key, required this.post});
  final PostEntity post;

  @override
  Widget build(BuildContext context) {
    final Color surfaceColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withOpacity(0.05)
        : Colors.grey.shade100;

    final textColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _glassAction(
            icon: Icons.favorite_border,
            label: "Like",
            onTap: () {},
            iconColor: Colors.redAccent,
            surfaceColor: surfaceColor,
            textColor: textColor,
          ),
          _glassAction(
            icon: Icons.mode_comment_outlined,
            label: "Contact",
            onTap: () async {
              final authState = context.read<AuthCubit>().state;
              final currentUser =
                  (authState is Authenticated) ? authState.user : null;
              final otheruser =
                  await context.read<UserBloc>().getuserbyid(post.user_id);
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return ChatDetailsScreen(
                    currentUserId: currentUser!.user_id,
                    currentViewerUser: ViewerUser(
                        avatar: currentUser.avatar,
                        id: currentUser.user_id,
                        name: currentUser.name,
                        email: currentUser.email),
                    user: ViewerUser(
                        avatar: otheruser.avatar,
                        id: otheruser.user_id,
                        name: otheruser.name,
                        email: otheruser.email),
                    otherUserId: otheruser.user_id);
              }));
            },
            iconColor: Colors.deepPurpleAccent,
            surfaceColor: surfaceColor,
            textColor: textColor,
          ),
          _glassAction(
            icon: Icons.pin_drop_outlined,
            label: "Location",
            onTap: () {
              final route = MaterialPageRoute(
                builder: (context) => SoloPostLocation(post: post),
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
    );
  }

  Widget _glassAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color iconColor,
    required Color surfaceColor,
    required Color textColor,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      splashColor: iconColor.withOpacity(0.2),
      child: Container(
        width: 64,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: iconColor.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                )),
          ],
        ),
      ),
    );
  }
}
