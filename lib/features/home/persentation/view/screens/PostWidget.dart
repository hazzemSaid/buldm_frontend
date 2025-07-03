import 'package:buldm/features/home/domain/entities/postentity.dart';
import 'package:buldm/features/home/persentation/bloc/user/user_bloc.dart';
import 'package:buldm/features/home/persentation/bloc/user/user_event.dart';
import 'package:buldm/features/home/persentation/bloc/user/user_state.dart';
import 'package:buldm/features/home/persentation/view/widgets/buildDescription.dart';
import 'package:buldm/features/home/persentation/view/widgets/buildImageCarousel.dart';
import 'package:buldm/features/home/persentation/view/widgets/buildPostActions.dart';
import 'package:buldm/features/home/persentation/view/widgets/buildPostList.dart';
import 'package:buldm/features/home/persentation/view/widgets/buildProfileHeader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PostWidget extends StatefulWidget {
  final PostEntity post;
  final int index;
  const PostWidget({super.key, required this.post, required this.index});

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget>
    with AutomaticKeepAliveClientMixin<PostWidget> {
  @override
  bool get wantKeepAlive => keepAliveIndexes.contains(widget.index);

  final PageController _pageController = PageController();
  final ValueNotifier<int> _currentPageNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      _currentPageNotifier.value = _pageController.page!.toInt();
    });
    final userBloc = BlocProvider.of<UserBloc>(context);
    final currentState = userBloc.state;
    if (currentState is UserLoaded &&
        !currentState.users.containsKey(widget.post.user_id)) {
      userBloc
          .add(LoadUserEvent(userId: widget.post.user_id, forceRefresh: false));
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentPageNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // ✅ important for keepAlive
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildProfileHeader(
            userId: widget.post.user_id,
            post: widget.post,
          ),
          buildDescription(
            description: widget.post.description,
          ),
          const SizedBox(height: 8),
          buildImageCarousel(
            pageController: _pageController,
            currentPageNotifier: _currentPageNotifier,
            imagePaths: widget.post.images,
          ),
          const SizedBox(height: 8),
          const BuildPostActions(),
        ],
      ),
    );
  }
}
