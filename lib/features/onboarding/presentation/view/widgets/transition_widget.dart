import 'package:buldm/utils/app_theme.dart';
import 'package:flutter/material.dart';

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
