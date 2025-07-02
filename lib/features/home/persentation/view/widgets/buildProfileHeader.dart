import 'package:buldm/features/home/domain/entities/postentity.dart';
import 'package:buldm/features/home/persentation/bloc/user/user_bloc.dart';
import 'package:buldm/features/home/persentation/bloc/user/user_event.dart';
import 'package:buldm/features/home/persentation/bloc/user/user_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

class buildProfileHeader extends StatelessWidget {
  final String? userId;
  final PostEntity post;

  const buildProfileHeader({
    required this.post,
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // ❗️Don't call add inside build directly
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        // ✅ Trigger only if not loaded
        if (state is UserInitial ||
            (state is UserLoaded && !state.users.containsKey(userId))) {
          context
              .read<UserBloc>()
              .add(LoadUserEvent(userId: userId!, forceRefresh: false));
        }

        if (state is UserLoaded && state.users.containsKey(userId)) {
          final user = state.users[userId]!;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                CircleAvatar(
                    radius: 20, backgroundImage: NetworkImage(user.avatar)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name,
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          )),
                      Text("Posted on ${post.createdAt}",
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          )),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle,
                          size: 16, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(post.status,
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          )),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.more_horiz,
                      size: 20, color: colorScheme.onSurface),
                  onPressed: () {},
                ),
              ],
            ),
          );
        }

        if (state is UserError && state.userId == userId) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '❌ ${state.message}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        // Default shimmer
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
      },
    );
  }
}
