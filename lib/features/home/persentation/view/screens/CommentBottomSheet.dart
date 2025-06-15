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
      'user': 'ahmed',
      'comment': 'Where exactly was it found?',
      'replies': [],
      'showReplyField': false,
    },
  ];

  final TextEditingController replyController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView.builder(
            controller: scrollController,
            itemCount: comments.length,
            itemBuilder: (context, index) {
              final comment = comments[index];

              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Main Comment
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
                                  style: textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.bold)),
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
                                      color:
                                          colorScheme.primary.withOpacity(0.7)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    /// Replies
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

                    /// Reply Input Field
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
                              icon:
                                  Icon(Icons.send, color: colorScheme.primary),
                              onPressed: () =>
                                  _addReply(index, replyController.text.trim()),
                            )
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
