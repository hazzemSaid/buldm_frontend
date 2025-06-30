import 'package:buldm/features/home/domain/entities/postentity.dart';
import 'package:flutter/material.dart';

class buildProfileHeader extends StatelessWidget {
  final String? userId;
  final PostEntity post;
  const buildProfileHeader(
      {required this.post, super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage("assets/images/profile.jpg"),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userId!,
                    style: textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                Text("Posted on ${post.createdAt}",
                    style: textTheme.bodySmall
                        ?.copyWith(color: Colors.grey.shade600, fontSize: 12)),
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
                const Icon(Icons.check_circle, size: 16, color: Colors.green),
                const SizedBox(width: 4),
                Text(post.status,
                    style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          IconButton(
            icon:
                Icon(Icons.more_horiz, size: 20, color: colorScheme.onSurface),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
