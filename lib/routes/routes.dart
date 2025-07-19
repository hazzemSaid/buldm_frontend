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

enum AppRoute { onboarding, home, signin, navbar, signup }

final Map<String, String> paths = {
  AppRoute.onboarding.name: '/',
  AppRoute.home.name: '/home',
  AppRoute.signin.name: '/signin',
  AppRoute.navbar.name: '/navbar',
  AppRoute.signup.name: '/signup',
};
final GoRouter router = GoRouter(
  refreshListenable: GoRouterRefreshStream(
    sl<AuthCubit>().stream,
  ),
  redirect: (context, state) {
    final authCubit = sl<AuthCubit>();
    final isAuthenticated = authCubit.state is Authenticated;
    final currentPath = state.uri.path;

    // If authenticated, redirect away from auth screens to navbar
    if (isAuthenticated) {
      if (currentPath == paths[AppRoute.onboarding.name] ||
          currentPath == paths[AppRoute.signin.name]) {
        return paths[AppRoute.navbar.name];
      }
      return null; // Stay on current authenticated route
    }

    // If not authenticated, only allow onboarding and signin
    if (!isAuthenticated) {
      if (currentPath == paths[AppRoute.onboarding.name] ||
          currentPath == paths[AppRoute.signin.name]) {
        return null; // Allow access to these routes
      }
      return paths[AppRoute
          .onboarding.name]; // Redirect to onboarding for any other route
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
