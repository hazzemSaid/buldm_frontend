import 'package:buldm/features/home/persentation/view/screens/PostWidget.dart';
import 'package:flutter/material.dart';

class buildPostList extends StatelessWidget {
  const buildPostList({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => const PostWidget(),
        childCount: 10,
      ),
    );
  }
}
