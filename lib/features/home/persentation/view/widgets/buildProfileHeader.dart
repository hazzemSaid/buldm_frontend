import 'package:flutter/material.dart';

class buildProfileHeader extends StatelessWidget {
  const buildProfileHeader({super.key});

  @override
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
                Text("Hazem",
                    style: textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                Text("2h • Cairo",
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
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, size: 16, color: Colors.green),
                SizedBox(width: 4),
                Text("Found",
                    style: TextStyle(
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
