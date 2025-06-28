import 'package:buldm/features/onboarding/presentation/view/widgets/OnboardingPage.dart';
import 'package:buldm/features/onboarding/presentation/view/widgets/transition_widget.dart';
import 'package:buldm/l10n/app_localizations.dart';
import 'package:buldm/provider/localization/localization_cubit.dart';
import 'package:buldm/routes/routes.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  void _goToAuth() => GoRouter.of(context).replace(paths[AppRoute.auth.name]!);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
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
                _goToAuth();
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
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              context
                                  .read<LocalizationCubit>()
                                  .switchLanguage();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              color: Colors.transparent,
                              child: Icon(
                                Icons.language_outlined,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _goToAuth,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              color: Colors.transparent,
                              child: Text(
                                localizations.skip,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                            ),
                          ),
                        ]))),
          ),
        ],
      ),
    );
  }
}
