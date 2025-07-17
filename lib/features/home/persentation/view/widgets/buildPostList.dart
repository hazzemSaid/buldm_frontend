// ✅ في buildPostList.dart
import 'package:buldm/features/home/persentation/bloc/post/post_bloc.dart';
import 'package:buldm/features/home/persentation/view/screens/PostWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

final Set<int> keepAliveIndexes = {}; // ✅ خارج أي كلاس
const int maxAliveCount = 10;

class buildPostList extends StatelessWidget {
  const buildPostList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostBloc, PostState>(
      builder: (context, state) {
        if (state is PostLoaded) {
          final posts = state.posts;
          final isLoadingMore = state.isLoadingMore;
          if (posts.isEmpty) {
            return SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'No posts have been in app , post your first post now! ',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Icon(
                      Icons.sentiment_dissatisfied,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
            );
          }
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index < posts.length) {
                  // ✅ إدارة الكاش
                  if (!keepAliveIndexes.contains(index)) {
                    if (keepAliveIndexes.length >= maxAliveCount) {
                      keepAliveIndexes.remove(keepAliveIndexes.first);
                    }
                    keepAliveIndexes.add(index);
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    child: PostWidget(post: posts[index], index: index),
                  );
                } else {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
              },
              childCount: posts.length + (isLoadingMore ? 1 : 0),
            ),
          );
        }

        if (state is PostError) {
          return SliverToBoxAdapter(
            child: Center(
              child: Text(state.message,
                  style: const TextStyle(color: Colors.red)),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => const PostShimmerWidget(),
            childCount: 5,
          ),
        );
      },
    );
  }
}

class PostShimmerWidget extends StatelessWidget {
  const PostShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = theme.brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.grey.shade300;
    final highlightColor = theme.brightness == Brightness.dark
        ? Colors.grey.shade700
        : Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header shimmer (avatar + name)
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 10, width: 80, color: Colors.white),
                      const SizedBox(height: 6),
                      Container(height: 8, width: 120, color: Colors.white),
                    ],
                  ),
                ),
                Container(height: 20, width: 20, color: Colors.white),
              ],
            ),
            const SizedBox(height: 12),

            // Description shimmer
            Container(height: 12, width: double.infinity, color: Colors.white),
            const SizedBox(height: 8),
            Container(height: 12, width: double.infinity, color: Colors.white),
            const SizedBox(height: 12),

            // Image carousel shimmer
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 160,
                width: double.infinity,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),

            // Actions shimmer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                4,
                (index) => Container(
                  width: 64,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
