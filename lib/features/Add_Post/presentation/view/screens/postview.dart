import 'package:buldm/features/home/domain/entities/postentity.dart';
import 'package:buldm/features/home/persentation/view/widgets/buildAppBar.dart';
import 'package:flutter/material.dart';

class Postview extends StatelessWidget {
  final PostEntity post;
  final Widget child;
  const Postview({super.key, required this.post, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            buildAppBar(),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            child,
          ],
        ),
      ),
    );
  }
}
