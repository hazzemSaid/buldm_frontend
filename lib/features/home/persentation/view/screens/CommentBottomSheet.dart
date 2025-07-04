import 'package:flutter/material.dart';

class CommentBottomSheet extends StatefulWidget {
  const CommentBottomSheet({super.key});

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  final List<Map<String, dynamic>> comments = [
    {
      'user': 'Hazem',
      'comment': 'This is a great post!',
      'replies': [
        {'user': 'Ali', 'reply': 'Totally agree!'},
      ],
      'showReplyField': false,
    },
    {
      'user': 'Sara',
      'comment': 'Where exactly was it found?',
      'replies': [],
      'showReplyField': false,
    },
    {
      'user': 'Ahmed',
      'comment': 'Thanks for sharing!',
      'replies': [],
      'showReplyField': false,
    },
  ];

  final TextEditingController replyController = TextEditingController();
  final TextEditingController commentController = TextEditingController();

  void _toggleReplyField(int index) {
    setState(() {
      comments[index]['showReplyField'] = !comments[index]['showReplyField'];
    });
  }

  void _addReply(int index, String replyText) {
    if (replyText.trim().isEmpty) return;
    setState(() {
      comments[index]['replies'].add({'user': 'You', 'reply': replyText});
      comments[index]['showReplyField'] = false;
      replyController.clear();
    });
  }

  void _addComment(String commentText) {
    if (commentText.trim().isEmpty) return;
    setState(() {
      comments.add({
        'user': 'You',
        'comment': commentText,
        'replies': [],
        'showReplyField': false,
      });
      commentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.98,
      decoration: BoxDecoration(
        color: colorScheme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),

          // Comments List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: 100,
              itemBuilder: (context, index) {
                final comment = comments[index % comments.length];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Main Comment
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CircleAvatar(radius: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(comment['user'],
                                    style: textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.bold)),
                                Text(comment['comment'],
                                    style: textTheme.bodyMedium),
                                TextButton(
                                  onPressed: () => _toggleReplyField(index),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    "Reply",
                                    style: TextStyle(
                                        color: colorScheme.primary
                                            .withOpacity(0.7)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Replies
                      if (comment['replies'].isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 48.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(
                              comment['replies'].length,
                              (i) => Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Row(
                                  children: [
                                    const CircleAvatar(radius: 12),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text:
                                                  "${comment['replies'][i]['user']}: ",
                                              style: textTheme.bodyMedium
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                            TextSpan(
                                              text: comment['replies'][i]
                                                  ['reply'],
                                              style: textTheme.bodyMedium,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                      // Reply Input Field
                      if (comment['showReplyField'])
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 8.0, left: 48.0, right: 12.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: replyController,
                                  decoration: InputDecoration(
                                    hintText: 'Write a reply...',
                                    hintStyle:
                                        TextStyle(color: colorScheme.outline),
                                    filled: true,
                                    fillColor: colorScheme.surface,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 12),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.send,
                                    color: colorScheme.primary),
                                onPressed: () => _addReply(
                                    index, replyController.text.trim()),
                              )
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Bottom Comment Input
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    decoration: InputDecoration(
                      hintText: 'Write a comment...',
                      hintStyle: TextStyle(color: colorScheme.outline),
                      filled: true,
                      fillColor: colorScheme.surface,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: colorScheme.primary),
                  onPressed: () => _addComment(commentController.text.trim()),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
