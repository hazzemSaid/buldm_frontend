import 'package:buldm/core/Dependency_njection/service_locator.dart';
import 'package:buldm/features/auth/presentaion/view/bloc/auth_cubit.dart';
import 'package:buldm/features/auth/presentaion/view/bloc/auth_state.dart';
import 'package:buldm/features/auth/presentaion/view/screen/SignInScreen.dart';
import 'package:buldm/features/auth/presentaion/view/screen/SignupScreen.dart';
import 'package:buldm/features/auth/presentaion/view/screen/VerificationEmailScreen.dart';
import 'package:buldm/features/auth/presentaion/view/screen/forgetpasswordscreen.dart';
import 'package:buldm/features/auth/presentaion/view/screen/resetpasswordscreen.dart';
import 'package:buldm/features/auth/presentaion/view/screen/verfiycodescreen.dart';
import 'package:buldm/features/chat/presentation/view/screens/Listofchats.dart';
import 'package:buldm/features/chat/presentation/view/screens/chatdetailsscreen.dart';
import 'package:buldm/features/home/persentation/bloc/user/user_bloc.dart';
import 'package:buldm/features/onboarding/presentation/view/screens/onboarding_screen.dart';
import 'package:buldm/features/profile/presentation/blocs/profile/profile_cubit.dart';
import 'package:buldm/features/profile/presentation/view/screens/OtherUserProfileScreen.dart';
import 'package:buldm/features/profile/presentation/view/screens/profile_screen.dart';
import 'package:buldm/features/splash/splash_screen.dart';
import 'package:buldm/routes/GoRouterRefreshStream.dart';
import 'package:buldm/utils/layout/main_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppRoute {
  splash,
  onboarding,
  home,
  signin,
  navbar,
  signup,
  prfile,
  forgot,
  verify,
  reset,
  verifyEmail,
  profileSelf,
  profileOther,
  chat,
  chatsList,
}

// Exposed navigator key to allow navigation from places without BuildContext
final GlobalKey<NavigatorState> appRouterKey = GlobalKey<NavigatorState>();

final Map<String, String> paths = {
  AppRoute.splash.name: '/',
  AppRoute.onboarding.name: '/onboarding',
  AppRoute.home.name: '/home',
  AppRoute.signin.name: '/signin',
  AppRoute.navbar.name: '/navbar',
  AppRoute.signup.name: '/signup',
  AppRoute.forgot.name: '/forgot',
  AppRoute.verify.name: '/verify',
  AppRoute.reset.name: '/reset-password',
  AppRoute.verifyEmail.name: '/verify-email',
  AppRoute.profileSelf.name: '/profile',
  AppRoute.profileOther.name: '/profile/other',
  AppRoute.chat.name: '/chat',
  AppRoute.chatsList.name: '/chats',
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
  navigatorKey: appRouterKey,
  refreshListenable: GoRouterRefreshStream(
    sl<AuthCubit>().stream,
  ),
  redirect: (context, state) async {
    final authCubit = sl<AuthCubit>();
    final isAuthenticated = authCubit.state is Authenticated;
    final currentPath = state.uri.path;
    final firstLaunch = await isFirstLaunch();

    // Always allow splash to render and handle its own navigation
    if (currentPath == paths[AppRoute.splash.name]) {
      return null;
    }

    // If authenticated, redirect away from auth screens to navbar
    if (isAuthenticated) {
      if (currentPath == paths[AppRoute.onboarding.name] ||
          currentPath == paths[AppRoute.signin.name] ||
          currentPath == paths[AppRoute.signup.name] ||
          currentPath == paths[AppRoute.forgot.name] ||
          currentPath == paths[AppRoute.verify.name] ||
          currentPath == paths[AppRoute.reset.name] ||
          currentPath == paths[AppRoute.verifyEmail.name]) {
        return paths[AppRoute.navbar.name];
      }
      return null; // Stay on current authenticated route
    }

    // If not authenticated
    if (!isAuthenticated) {
      // Allow onboarding route depending on first launch
      if (currentPath == paths[AppRoute.onboarding.name]) {
        if (firstLaunch) return null; // allow staying on onboarding
        return paths[AppRoute.signin.name];
      }

      // Allow access to signin and signup
      if (currentPath == paths[AppRoute.signin.name] ||
          currentPath == paths[AppRoute.signup.name] ||
          currentPath == paths[AppRoute.forgot.name] ||
          currentPath == paths[AppRoute.verify.name] ||
          currentPath == paths[AppRoute.reset.name] ||
          currentPath == paths[AppRoute.verifyEmail.name]) {
        return null;
      }

      // For any other route, redirect based on first launch status
      return firstLaunch
          ? paths[AppRoute.onboarding.name]
          : paths[AppRoute.signin.name];
    }

    return null;
  },
  initialLocation: paths[AppRoute.splash.name]!,
  routes: <RouteBase>[
    GoRoute(
      path: paths[AppRoute.splash.name]!,
      builder: (BuildContext context, GoRouterState state) =>
          const SplashScreen(),
    ),
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
      path: paths[AppRoute.forgot.name]!,
      builder: (BuildContext context, GoRouterState state) =>
          const Forgetpasswordscreen(),
    ),
    GoRoute(
      path: paths[AppRoute.verify.name]!,
      builder: (BuildContext context, GoRouterState state) {
        final email = state.extra as String?;
        return VerifyCodeScreen(email: email ?? '');
      },
    ),
    GoRoute(
      path: paths[AppRoute.reset.name]!,
      builder: (BuildContext context, GoRouterState state) {
        final email = state.extra as String?;
        return Resetpasswordscreen(email: email ?? '');
      },
    ),
    GoRoute(
      path: paths[AppRoute.verifyEmail.name]!,
      builder: (BuildContext context, GoRouterState state) {
        final email = state.extra as String?;
        return VerificationEmailScreen(email: email ?? '');
      },
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
    GoRoute(
      path: paths[AppRoute.profileSelf.name]!,
      builder: (BuildContext context, GoRouterState state) =>
          BlocProvider.value(
        value: sl<ProfileCubit>(),
        child: const ProfileScreen(),
      ),
    ),
    GoRoute(
      path: paths[AppRoute.profileOther.name]!,
      builder: (BuildContext context, GoRouterState state) {
        final user = state.extra as ViewerUser?;
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(
              value: sl<ProfileCubit>(),
            ),
            BlocProvider.value(
              value: sl<UserBloc>(),
            ),
          ],
          child: OtherUserProfileScreen(user: user!),
        );
      },
    ),
    GoRoute(
      path: paths[AppRoute.chat.name]!,
      builder: (BuildContext context, GoRouterState state) {
        final extras = state.extra as Map<String, dynamic>?;
        return ChatDetailsScreen(
          // Ensure extras is not null and contains the required keys

          user: extras!["user"],
          currentUserId: extras["currentUserId"],
          otherUserId: extras["otherUserId"],
          currentViewerUser: extras["currentViewerUser"],
        );
      },
    ),
    GoRoute(
      path: paths[AppRoute.chatsList.name]!,
      builder: (BuildContext context, GoRouterState state) {
        // Provide a fresh UserBloc for this route to avoid ProviderNotFound
        return BlocProvider<UserBloc>(
          create: (_) => sl<UserBloc>(),
          child: const ListOfChats(),
        );
      },
    ),
  ],
);
