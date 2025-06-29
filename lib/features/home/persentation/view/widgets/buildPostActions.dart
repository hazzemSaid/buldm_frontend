import 'package:buldm/features/home/persentation/view/screens/CommentBottomSheet.dart';
import 'package:flutter/material.dart';

class BuildPostActions extends StatelessWidget {
  const BuildPostActions({super.key});

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
            label: "Comment",
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const CommentBottomSheet(),
              );
            },
            iconColor: Colors.deepPurpleAccent,
            surfaceColor: surfaceColor,
            textColor: textColor,
          ),
          _glassAction(
            icon: Icons.pin_drop_outlined,
            label: "Location",
            onTap: () {},
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
