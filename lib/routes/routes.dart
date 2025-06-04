import 'package:buldm/features/home/persentation/view/screens/home_screen.dart';
import 'package:buldm/features/onboarding/presentation/view/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum AppRoute { onboarding, home }

final Map<String, String> paths = {
  AppRoute.onboarding.name: '/',
  AppRoute.home.name: '/home',
};

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: paths[AppRoute.onboarding.name]!,
      builder: (BuildContext context, GoRouterState state) {
        return const OnboardingScreen();
      },
      routes: <RouteBase>[
        GoRoute(
          path: paths[AppRoute.home.name]!,
          builder: (BuildContext context, GoRouterState state) {
            return const HomeScreen();
          },
        ),
      ],
    ),
  ],
);
