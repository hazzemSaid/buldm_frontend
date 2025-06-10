import 'package:buldm/features/auth/data/repositery/AuthRepositoryImpl%20.dart';
import 'package:buldm/features/auth/presentaion/view/screen/auth_screen.dart';
import 'package:buldm/features/auth/presentaion/view/viewmodel/auth/auth_cubit.dart';
import 'package:buldm/features/auth/presentaion/view/viewmodel/auth/auth_state.dart';
import 'package:buldm/features/onboarding/presentation/view/screens/onboarding_screen.dart';
import 'package:buldm/routes/GoRouterRefreshStream.dart';
import 'package:buldm/utils/layout/main_layout.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum AppRoute { onboarding, home, auth, navbar }

final Map<String, String> paths = {
  AppRoute.onboarding.name: '/',
  AppRoute.home.name: '/home',
  AppRoute.auth.name: '/signin',
  AppRoute.navbar.name: '/navbar',
};
final GoRouter router = GoRouter(
  refreshListenable: GoRouterRefreshStream(
    AuthCubit(Authrepositoryimpl()).stream,
  ),
  redirect: (context, state) {
    final authCubit = AuthCubit(Authrepositoryimpl());
    final isAuthenticated = authCubit.state is Authenticated;

    if (state.uri.path == paths[AppRoute.onboarding.name] && isAuthenticated) {
      return paths[AppRoute.navbar.name];
    }

    if (state.uri.path == paths[AppRoute.auth.name] && isAuthenticated) {
      return paths[AppRoute.navbar.name];
    }

    if (state.uri.path == paths[AppRoute.navbar.name] && !isAuthenticated) {
      return paths[AppRoute.auth.name];
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
      path: paths[AppRoute.auth.name]!,
      builder: (BuildContext context, GoRouterState state) =>
          const AuthScreen(),
    ),
  ],
);
