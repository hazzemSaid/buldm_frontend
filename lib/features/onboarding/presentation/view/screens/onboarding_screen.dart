import 'package:buldm/utils/app_theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late final PageController controller;
  late final AnimationController _animationController;

  final int pages = 3;

  @override
  void initState() {
    super.initState();
    controller = PageController();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _goToHome() => GoRouter.of(context).replace('/signin');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background animation
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 200,
            child: transition_widget(animationController: _animationController),
          ),

          PageView(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            dragStartBehavior: DragStartBehavior.down,
            controller: controller,
            onPageChanged: (index) {
              if (index == pages) {
                _goToHome();
              }
            },
            children: [
              for (int i = 0; i < pages; i++) OnboardingPage(index: i),
              Container(),
            ],
          ),

          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: controller,
                count: pages,
                effect: CustomizableEffect(
                  activeDotDecoration: DotDecoration(
                    width: 32,
                    height: 12,
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    verticalOffset: -10,
                  ),
                  dotDecoration: DotDecoration(
                    width: 24,
                    height: 12,
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  spacing: 6.0,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0, right: 16.0),
                child: GestureDetector(
                  onTap: _goToHome,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.transparent,
                    child: const Text(
                      "Skip",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class transition_widget extends StatelessWidget {
  const transition_widget({
    super.key,
    required AnimationController animationController,
  }) : _animationController = animationController;

  final AnimationController _animationController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.transparent,
                AppTheme.primaryColor.withOpacity(
                  0.1 * _animationController.value,
                ),
                AppTheme.primaryColor.withOpacity(
                  0.3 * _animationController.value,
                ),
                AppTheme.primaryColor.withOpacity(
                  0.6 * _animationController.value,
                ),
                AppTheme.primaryColor.withOpacity(
                  0.8 * _animationController.value,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final int index;

  const OnboardingPage({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final titles = [
      'Welcome to Buildm!',
      'Discover amazing tools!',
      'Get started easily!',
    ];
    final subtitles = [
      'Your one-stop solution for all your building needs.',
      'Tools and resources at your fingertips.',
      'Let\'s build something great together.',
    ];

    return Stack(
      children: [
        // Background image
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/darkbuldm.png'),
              fit: BoxFit.fitWidth,
            ),
          ),
        ),

        // Text content
        Positioned(
          bottom: 100,
          left: 24,
          right: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titles[index],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitles[index],
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
