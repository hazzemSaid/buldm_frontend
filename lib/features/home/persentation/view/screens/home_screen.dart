// features/home/persentation/view/screens/home_screen.dart
import 'package:buldm/features/home/persentation/bloc/post/post_bloc.dart';
import 'package:buldm/features/home/persentation/bloc/user/user_bloc.dart';
import 'package:buldm/features/home/persentation/bloc/user/user_event.dart';
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
  late final PostBloc _postBloc;
  int _currentPage = 1;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _postBloc = context.read<PostBloc>();
    _loadInitialPosts();
    widget.scrollController.addListener(_onScroll);
  }

  Future<void> _loadInitialPosts() async {
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
  }

  void _onScroll() {
    final position = widget.scrollController.position;
    final currentState = _postBloc.state;
    final hasReachedEnd = position.pixels >= position.maxScrollExtent - 200;
    final canLoadMore = currentState.hasMoreposts;

    if (hasReachedEnd && canLoadMore) {
      _loadMorePosts();
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    _postBloc.add(
      LoadPostEvent(
        category: null,
        status: null,
        userId: null,
        searchQuery: null,
        limit: 5,
        page: _currentPage + 1,
      ),
    );

    // Reset loading state after a short delay
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _isLoadingMore = false;
        _currentPage++;
      });
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    // No need to dispose the bloc as it's managed by BlocProvider
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // delete the cache for the users
            context.read<UserBloc>().add(ClearUserCacheEvent());

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
            cacheExtent:
                1000.0, // prebuild ~1k px ahead for smoother fast scrolls
            physics: const AlwaysScrollableScrollPhysics(),
            controller: widget.scrollController,
            slivers: <Widget>[
              const buildAppBar(),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              const BuildPostList(),
              if (_isLoadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
