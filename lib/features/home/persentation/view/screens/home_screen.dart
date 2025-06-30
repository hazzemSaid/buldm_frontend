import 'package:buldm/core/Dependency_njection/service_locator.dart';
import 'package:buldm/features/home/persentation/bloc/post/post_bloc.dart';
import 'package:buldm/features/home/persentation/view/widgets/buildAppBar.dart';
import 'package:buldm/features/home/persentation/view/widgets/buildPostList.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PostBloc>(
      create: (context) {
        final bloc = sl<PostBloc>();
        bloc.add(
          LoadPostEvent(
            category: null,
            status: null,
            userId: null,
            searchQuery: null,
            limit: 10,
            offset: 0,
          ),
        );
        return bloc;
      },
      child: Scaffold(
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
      ),
    );
  }
}
