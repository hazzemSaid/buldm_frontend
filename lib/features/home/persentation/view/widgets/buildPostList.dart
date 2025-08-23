// features/home/persentation/view/widgets/buildPostList.dart
import 'package:buldm/features/home/persentation/bloc/post/post_bloc.dart';
import 'package:buldm/features/home/persentation/view/screens/PostWidget.dart';
import 'package:buldm/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

final Set<String> keepAliveIndexes = {}; // ✅ cache by post.id for stability
const int maxAliveCount = 10;

class BuildPostList extends StatelessWidget {
  const BuildPostList({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return BlocSelector<PostBloc, PostState, PostLoaded?>(
      // ✅ Switched to BlocSelector
      selector: (state) => state is PostLoaded ? state : null,
      builder: (context, loaded) {
        if (loaded == null) {
          // Loading or other non-post states
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => const PostShimmerWidget(),
              childCount: 5,
              addAutomaticKeepAlives: true, // ✅ Added delegate optimizations
              addRepaintBoundaries: true,
              addSemanticIndexes: false,
            ),
          );
        }

        final postsMap = loaded.posts; // Expecting a map keyed by postId
        final isLoadingMore = loaded.isLoadingMore;
        if (postsMap.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    localization.noPostsAvailable,
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

        // Use keys list to avoid allocating a new list of PostModel on every build
        final postIds = postsMap.keys.toList(growable: false);
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index < postIds.length) {
                // ✅ إدارة الكاش
                final postId = postIds[index];
                final post = postsMap[postId]!;
                if (!keepAliveIndexes.contains(post.id)) {
                  if (keepAliveIndexes.length >= maxAliveCount) {
                    keepAliveIndexes.remove(keepAliveIndexes.first);
                  }
                  keepAliveIndexes.add(post.id);
                }

                return Padding(
                  key: ValueKey<String>(post.id), // ✅ Added stable keys
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: PostWidget(
                    singlePost: false,
                    post: post,
                    index: post.id,
                  ),
                );
              } else {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
            },
            childCount: postIds.length + (isLoadingMore ? 1 : 0),
            addAutomaticKeepAlives: true, // ✅ Added delegate optimizations
            addRepaintBoundaries: true,
            addSemanticIndexes: false,
            findChildIndexCallback: (Key key) {
              // ✅ Added findChildIndexCallback
              if (key is ValueKey<String>) {
                final id = key.value;
                for (int i = 0; i < postIds.length; i++) {
                  if (postIds[i] == id) return i;
                }
              }
              return null;
            },
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
          color: theme.colorScheme.surface,
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
