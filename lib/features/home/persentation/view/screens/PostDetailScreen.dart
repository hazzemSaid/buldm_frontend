// features/home/persentation/view/screens/PostDetailScreen.dart
import 'package:buldm/features/home/domain/entities/postentity.dart';
import 'package:buldm/features/home/persentation/bloc/post/post_bloc.dart';
import 'package:buldm/features/home/persentation/view/screens/PostWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PostDetailScreen extends StatefulWidget {
  final PostEntity post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  bool _isInitialized = false;
  @override
  void initState() {
    super.initState();
    //get all comments
    context
        .read<PostBloc>()
        .add(getcomment(postId: widget.post.id, page: 1, limit: 1000));
  }

  @override
  Widget build(BuildContext context) {
    // Use blocs provided by ancestors (e.g., MainLayout or caller via BlocProvider.value)
    // Initialize only once after providers are available
    if (!_isInitialized) {
      _isInitialized = true;
      // Optionally trigger loads here using context.read<PostBloc>() / UserBloc
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Post Details'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: BlocBuilder<PostBloc, PostState>(
        builder: (context, state) {
          if (state is PostLoaded) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: PostWidget(
                  post: widget.post,
                  index: widget.post.id, // Using post ID as index
                ),
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
