import 'package:flutter/material.dart';

class Responsive {
  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;

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

  static bool isTabletOrDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= mobileBreakpoint;
  }

  // Get responsive padding
  static EdgeInsets getPadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 64, vertical: 32);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 40, vertical: 24);
    } else {
      return const EdgeInsets.symmetric(horizontal: 20, vertical: 16);
    }
  }

  // Get responsive horizontal padding
  static double getHorizontalPadding(BuildContext context) {
    if (isDesktop(context)) {
      return 64;
    } else if (isTablet(context)) {
      return 40;
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
      return mobile ?? 1;
    }
  }

  // Get responsive child aspect ratio
  static double getGridAspectRatio(BuildContext context, {double? mobile, double? tablet, double? desktop}) {
    if (isDesktop(context)) {
      return desktop ?? 1.2;
    } else if (isTablet(context)) {
      return tablet ?? 1.1;
    } else {
      return mobile ?? 1.4;
    }
  }

  // Get responsive font size
  static double getFontSize(BuildContext context, {required double mobile, double? tablet, double? desktop}) {
    if (isDesktop(context)) {
      return desktop ?? mobile * 1.35;
    } else if (isTablet(context)) {
      return tablet ?? mobile * 1.15;
    } else {
      return mobile;
    }
  }

  // Get responsive width
  static double getResponsiveWidth(BuildContext context, {double? maxWidth}) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (maxWidth != null && screenWidth > maxWidth) {
      return maxWidth;
    }
    return screenWidth;
  }
}

