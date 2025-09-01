import 'package:flutter/material.dart';

class AppConstants {
  // Spacing
  static const double smallSpacing = 8.0;
  static const double mediumSpacing = 16.0;
  static const double largeSpacing = 24.0;
  
  // Border radius
  static const double smallRadius = 4.0;
  static const double mediumRadius = 8.0;
  static const double largeRadius = 12.0;
  
  // Icons
  static const double smallIconSize = 16.0;
  static const double mediumIconSize = 20.0;
  static const double largeIconSize = 24.0;
  
  // Avatar
  static const double smallAvatarRadius = 20.0;
  static const double mediumAvatarRadius = 30.0;
  static const double largeAvatarRadius = 40.0;
  
  // Status colors
  static const Color foundStatusColor = Colors.green;
  static const Color lostStatusColor = Colors.red;
  static const double statusOpacity = 0.1;
  
  // Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(seconds: 1);
  
  // Padding
  static const EdgeInsets defaultPadding = EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0);
  static const EdgeInsets smallPadding = EdgeInsets.all(4.0);
  static const EdgeInsets mediumPadding = EdgeInsets.all(8.0);
}
