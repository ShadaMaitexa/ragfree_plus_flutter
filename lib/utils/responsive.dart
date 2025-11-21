import 'package:flutter/material.dart';

class Responsive {
  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  // Check screen size
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  // Get responsive padding
  static EdgeInsets getPadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 40, vertical: 24);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 20);
    } else {
      return const EdgeInsets.symmetric(horizontal: 20, vertical: 16);
    }
  }

  // Get responsive horizontal padding
  static double getHorizontalPadding(BuildContext context) {
    if (isDesktop(context)) {
      return 40;
    } else if (isTablet(context)) {
      return 32;
    } else {
      return 20;
    }
  }

  // Get responsive grid cross axis count
  static int getGridCrossAxisCount(BuildContext context, {int? mobile, int? tablet, int? desktop}) {
    if (isDesktop(context)) {
      return desktop ?? 4;
    } else if (isTablet(context)) {
      return tablet ?? 3;
    } else {
      return mobile ?? 2;
    }
  }

  // Get responsive child aspect ratio
  static double getGridAspectRatio(BuildContext context, {double? mobile, double? tablet, double? desktop}) {
    if (isDesktop(context)) {
      return desktop ?? 1.0;
    } else if (isTablet(context)) {
      return tablet ?? 1.2;
    } else {
      return mobile ?? 1.3;
    }
  }

  // Get responsive font size
  static double getFontSize(BuildContext context, {required double mobile, double? tablet, double? desktop}) {
    if (isDesktop(context)) {
      return desktop ?? mobile * 1.3;
    } else if (isTablet(context)) {
      return tablet ?? mobile * 1.15;
    } else {
      return mobile;
    }
  }

  // Get responsive width (for cards, containers, etc.)
  static double getCardWidth(BuildContext context, {double? maxWidth}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = getHorizontalPadding(context) * 2;
    final availableWidth = screenWidth - padding;
    
    if (isDesktop(context)) {
      return maxWidth != null ? (availableWidth > maxWidth ? maxWidth : availableWidth) : availableWidth;
    } else {
      return availableWidth;
    }
  }

  // Get responsive column count for forms
  static int getFormColumnCount(BuildContext context) {
    if (isDesktop(context)) {
      return 2;
    } else {
      return 1;
    }
  }
}

