import 'package:buldm/features/home/persentation/view/widgets/buildDescription.dart';
import 'package:buldm/features/home/persentation/view/widgets/buildImageCarousel.dart';
import 'package:buldm/features/home/persentation/view/widgets/buildPostActions.dart';
import 'package:buldm/features/home/persentation/view/widgets/buildProfileHeader.dart';
import 'package:flutter/material.dart';

class PostWidget extends StatefulWidget {
  const PostWidget({super.key});

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  final PageController _pageController = PageController();
  final ValueNotifier<int> _currentPageNotifier = ValueNotifier<int>(0);

  final List<String> _imagePaths = List.generate(
      5, (index) => "assets/images/profile.jpg"); // Example images

  @override
  void dispose() {
    _pageController.dispose();
    _currentPageNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const buildProfileHeader(),
          const buildDescription(),
          const SizedBox(height: 8),
          buildImageCarousel(
            pageController: _pageController,
            currentPageNotifier: _currentPageNotifier,
            imagePaths: _imagePaths,
          ),
          const SizedBox(height: 20),
          buildPostActions(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
