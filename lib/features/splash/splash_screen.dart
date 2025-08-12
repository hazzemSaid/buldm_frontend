import 'dart:async';

import 'package:buldm/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:buldm/core/Dependency_njection/service_locator.dart';
import 'package:buldm/features/auth/presentaion/view/bloc/auth_cubit.dart';
import 'package:buldm/features/auth/presentaion/view/bloc/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    // Navigate after short delay
    Timer(const Duration(milliseconds: 1400), _navigateNext);
  }

  Future<void> _navigateNext() async {
    if (!mounted) return;
    final authCubit = sl<AuthCubit>();
    final isAuthenticated = authCubit.state is Authenticated;

    final prefs = await SharedPreferences.getInstance();
    final firstLaunch = prefs.getBool('isFirstLaunch') ?? true;

    if (isAuthenticated) {
      if (!mounted) return;
      context.go(paths[AppRoute.navbar.name]!);
      return;
    }

    // Not authenticated
    if (firstLaunch) {
      if (!mounted) return;
      context.go(paths[AppRoute.onboarding.name]!);
    } else {
      if (!mounted) return;
      context.go(paths[AppRoute.signin.name]!);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: Image.asset(
            'assets/images/darkbuldm.png',
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
