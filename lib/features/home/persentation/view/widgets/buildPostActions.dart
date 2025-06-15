import 'package:buldm/features/home/persentation/view/screens/CommentBottomSheet.dart';
import 'package:flutter/material.dart';

class buildPostActions extends StatelessWidget {
  const buildPostActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            tooltip: "Location",
            onPressed: () {},
            icon: Icon(Icons.location_on, color: Colors.red.shade400, size: 22),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                IconButton(
                  tooltip: "Upvote",
                  onPressed: () {},
                  icon: const Icon(Icons.arrow_upward, color: Colors.orange),
                ),
                const Text("23", style: TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  tooltip: "Downvote",
                  onPressed: () {},
                  icon: const Icon(Icons.arrow_downward, color: Colors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: "Comment",
            onPressed: () {
              showBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (context) {
                    return CommentBottomSheet();
                  });
            },
            icon: const Icon(Icons.comment_outlined),
          ),
          IconButton(
            tooltip: "Share",
            onPressed: () {},
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
    );
  }
}
