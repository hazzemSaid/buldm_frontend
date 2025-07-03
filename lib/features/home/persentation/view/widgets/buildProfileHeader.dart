import 'package:buldm/features/auth/domain/entities/userentities.dart';
import 'package:buldm/features/home/domain/entities/postentity.dart';
import 'package:buldm/features/home/persentation/bloc/user/user_bloc.dart';
import 'package:buldm/features/home/persentation/bloc/user/user_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class buildProfileHeader extends StatelessWidget {
  final String? userId;
  final PostEntity post;

  const buildProfileHeader({
    super.key,
    required this.userId,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ إرسال event فقط لو المستخدم غير موجود بالكاش

    return BlocSelector<UserBloc, UserState, User?>(
      selector: (state) {
        if (state is UserLoaded && state.users.containsKey(userId)) {
          return state.users[userId];
        }
        return null;
      },
      builder: (context, user) {
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;

        if (user == null) {
          return _buildShimmer(); // or error widget if needed
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(user.avatar),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      DateFormat('MMM d, yyyy • hh:mm a').format(
                        post.createdAt,
                      ),
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                    Text(
                      post.status,
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.more_horiz,
                    size: 20, color: colorScheme.onSurface),
                onPressed: () {
                  // Handle more button press like showing options
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return ListView(
                        shrinkWrap: true,
                        children: [
                          ListTile(
                              leading: const Icon(Icons.edit),
                              title: const Text('Edit Post'),
                              onTap: () {
                                // Handle edit post action
                                Navigator.pop(context);
                              }),
                          ListTile(
                            leading: const Icon(Icons.delete),
                            title: const Text('Delete Post'),
                            onTap: () {
                              // Handle delete post action
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.report),
                            title: const Text('Report Post'),
                            onTap: () {
                              // Handle report post action
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
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
}
