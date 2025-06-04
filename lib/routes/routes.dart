import 'package:buldm/features/auth/presentaion/view/screen/signin_screen.dart';
import 'package:buldm/features/auth/presentaion/view/screen/singup_screen.dart'
    show SingupScreen;
import 'package:buldm/features/home/persentation/view/screens/home_screen.dart';
import 'package:buldm/features/onboarding/presentation/view/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum AppRoute { onboarding, home, signin, signup }

final Map<String, String> paths = {
  AppRoute.onboarding.name: '/',
  AppRoute.home.name: '/home',
  AppRoute.signin.name: '/signin',
  AppRoute.signup.name: '/signup',
};
final GoRouter router = GoRouter(
  initialLocation: paths[AppRoute.onboarding.name]!,
  routes: <RouteBase>[
    GoRoute(
      path: paths[AppRoute.onboarding.name]!,
      builder:
          (BuildContext context, GoRouterState state) =>
              const OnboardingScreen(),
    ),
    GoRoute(
      path: paths[AppRoute.home.name]!,
      builder:
          (BuildContext context, GoRouterState state) => const HomeScreen(),
    ),
    GoRoute(
      path: paths[AppRoute.signin.name]!,
      builder:
          (BuildContext context, GoRouterState state) => const SigninScreen(),
    ),
    GoRoute(
      path: paths[AppRoute.signup.name]!,
      builder:
          (BuildContext context, GoRouterState state) => const SingupScreen(),
    ),
  ],
);
