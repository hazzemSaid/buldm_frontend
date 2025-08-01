import 'package:buldm/core/Dependency_njection/service_locator.dart';
import 'package:buldm/features/auth/presentaion/view/bloc/auth_cubit.dart';
import 'package:buldm/features/auth/presentaion/view/bloc/auth_state.dart';
import 'package:buldm/features/auth/presentaion/view/screen/SignInScreen.dart';
import 'package:buldm/features/auth/presentaion/view/screen/SignupScreen.dart';
import 'package:buldm/features/onboarding/presentation/view/screens/onboarding_screen.dart';
import 'package:buldm/routes/GoRouterRefreshStream.dart';
import 'package:buldm/utils/layout/main_layout.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppRoute { onboarding, home, signin, navbar, signup, prfile }

final Map<String, String> paths = {
  AppRoute.onboarding.name: '/',
  AppRoute.home.name: '/home',
  AppRoute.signin.name: '/signin',
  AppRoute.navbar.name: '/navbar',
  AppRoute.signup.name: '/signup',
};

// Function to check if it's first launch
Future<bool> isFirstLaunch() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isFirstLaunch') ?? true;
}

// Function to mark that user has seen onboarding
Future<void> setFirstLaunchComplete() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isFirstLaunch', false);
}

final GoRouter router = GoRouter(
  refreshListenable: GoRouterRefreshStream(
    sl<AuthCubit>().stream,
  ),
  redirect: (context, state) async {
    final authCubit = sl<AuthCubit>();
    final isAuthenticated = authCubit.state is Authenticated;
    final currentPath = state.uri.path;
    final firstLaunch = await isFirstLaunch();

    // If authenticated, redirect away from auth screens to navbar
    if (isAuthenticated) {
      if (currentPath == paths[AppRoute.onboarding.name] ||
          currentPath == paths[AppRoute.signin.name]) {
        return paths[AppRoute.navbar.name];
      }
      return null; // Stay on current authenticated route
    }

    // If not authenticated
    if (!isAuthenticated) {
      // If it's first launch and user is on root, stay on onboarding
      if (firstLaunch && currentPath == paths[AppRoute.onboarding.name]) {
        return null;
      }

      // If it's not first launch and user is on onboarding, redirect to signin
      if (!firstLaunch && currentPath == paths[AppRoute.onboarding.name]) {
        return paths[AppRoute.signin.name];
      }

      // Allow access to signin and signup
      if (currentPath == paths[AppRoute.signin.name] ||
          currentPath == paths[AppRoute.signup.name]) {
        return null;
      }

      // For any other route, redirect based on first launch status
      if (firstLaunch) {
        return paths[AppRoute.onboarding.name];
      } else {
        return paths[AppRoute.signin.name];
      }
    }

    return null;
  },
  initialLocation: paths[AppRoute.onboarding.name]!,
  routes: <RouteBase>[
    GoRoute(
      path: paths[AppRoute.navbar.name]!,
      builder: (BuildContext context, GoRouterState state) =>
          const MainLayout(),
    ),
    GoRoute(
      path: paths[AppRoute.signup.name]!,
      builder: (BuildContext context, GoRouterState state) =>
          const SignupScreen(),
    ),
    GoRoute(
      path: paths[AppRoute.onboarding.name]!,
      builder: (BuildContext context, GoRouterState state) =>
          const OnboardingScreen(),
    ),
    GoRoute(
      path: paths[AppRoute.signin.name]!,
      builder: (BuildContext context, GoRouterState state) =>
          const SignInScreen(),
    ),
  ],
);
