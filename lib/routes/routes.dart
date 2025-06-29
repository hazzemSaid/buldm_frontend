import 'package:buldm/core/Dependency_njection/service_locator.dart';
import 'package:buldm/features/auth/presentaion/view/bloc/auth_cubit.dart';
import 'package:buldm/features/auth/presentaion/view/bloc/auth_state.dart';
import 'package:buldm/features/auth/presentaion/view/screen/SignInScreen.dart';
import 'package:buldm/features/onboarding/presentation/view/screens/onboarding_screen.dart';
import 'package:buldm/routes/GoRouterRefreshStream.dart';
import 'package:buldm/utils/layout/main_layout.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum AppRoute { onboarding, home, signin, navbar }

final Map<String, String> paths = {
  AppRoute.onboarding.name: '/',
  AppRoute.home.name: '/home',
  AppRoute.signin.name: '/signin',
  AppRoute.navbar.name: '/navbar',
};
final GoRouter router = GoRouter(
  refreshListenable: GoRouterRefreshStream(
    sl<AuthCubit>().stream,
  ),
  redirect: (context, state) {
    final authCubit = sl<AuthCubit>();
    final isAuthenticated = authCubit.state is Authenticated;

    if (state.uri.path == paths[AppRoute.onboarding.name] && isAuthenticated) {
      return paths[AppRoute.navbar.name];
    }

    if (state.uri.path == paths[AppRoute.signin.name] && isAuthenticated) {
      return paths[AppRoute.navbar.name];
    }

    if (!isAuthenticated) {
      return paths[AppRoute.signin.name];
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
