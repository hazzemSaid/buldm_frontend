import 'package:buldm/core/Dependency_njection/service_locator.dart';
import 'package:buldm/features/home/persentation/bloc/post/post_bloc.dart';
import 'package:buldm/features/home/persentation/bloc/user/user_bloc.dart';
import 'package:buldm/features/home/persentation/view/widgets/buildAppBar.dart';
import 'package:buldm/features/home/persentation/view/widgets/buildPostList.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PostBloc _postBloc;

  @override
  void initState() {
    super.initState();

    _postBloc = sl<PostBloc>();

    _postBloc.add(
      LoadPostEvent(
          category: null,
          status: null,
          userId: null,
          searchQuery: null,
          limit: 5,
          page: 1),
    );

    widget.scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final position = widget.scrollController.position;
    final currentState = _postBloc.state;

    if (position.pixels >= position.maxScrollExtent - 200 &&
        !_postBloc.isFetchingMore &&
        currentState is PostLoaded &&
        currentState.hasMore) {
      _postBloc.add(LoadMorePostsEvent());
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PostBloc>(
          create: (context) => _postBloc,
        ),
        BlocProvider<UserBloc>(
          create: (context) => sl<UserBloc>(),
        ),
      ],
      child: Scaffold(
        extendBody: true,
        backgroundColor: Theme.of(context).colorScheme.background,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              _postBloc.add(
                LoadPostEvent(
                  category: null,
                  status: null,
                  userId: null,
                  searchQuery: null,
                  limit: 5,
                  page: 1,
                ),
              );
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: widget.scrollController,
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
