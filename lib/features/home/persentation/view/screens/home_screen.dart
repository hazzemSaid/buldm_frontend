import 'package:buldm/features/home/persentation/view/widgets/buildAppBar.dart';
import 'package:buldm/features/home/persentation/view/widgets/buildPostList.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {},
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: scrollController,
            slivers: [
              buildAppBar(),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              buildPostList(),
            ],
          ),
        ),
      ),
    );
  }
}
