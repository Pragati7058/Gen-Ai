import 'package:flutter/material.dart';

/// Professional responsive helpers with 8px grid system and device detection.
class AppResponsive {
  AppResponsive._();

  // Device Type Detection
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return DeviceType.desktop;
    if (width >= 768) return DeviceType.tablet;
    if (width >= 360) return DeviceType.phone;
    return DeviceType.smallPhone;
  }

  static bool isSmallPhone(BuildContext context) =>
      getDeviceType(context) == DeviceType.smallPhone;

  static bool isPhone(BuildContext context) =>
      getDeviceType(context) == DeviceType.phone;

  static bool isTablet(BuildContext context) =>
      getDeviceType(context) == DeviceType.tablet;

  static bool isDesktop(BuildContext context) =>
      getDeviceType(context) == DeviceType.desktop;

  // Screen Dimensions
  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  // 8px Grid System
  static double spacing(BuildContext context, {double multiplier = 1.0}) {
    final baseSpacing = _getBaseSpacing(context);
    return baseSpacing * multiplier;
  }

  static double _getBaseSpacing(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.smallPhone:
        return 4.0;
      case DeviceType.phone:
        return 8.0;
      case DeviceType.tablet:
        return 12.0;
      case DeviceType.desktop:
        return 16.0;
    }
  }

  // Professional Padding System
  static EdgeInsets screenPadding(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.smallPhone:
        return const EdgeInsets.symmetric(horizontal: 12);
      case DeviceType.phone:
        return const EdgeInsets.symmetric(horizontal: 16);
      case DeviceType.tablet:
        return const EdgeInsets.symmetric(horizontal: 24);
      case DeviceType.desktop:
        return const EdgeInsets.symmetric(horizontal: 32);
    }
  }

  static EdgeInsets contentPadding(BuildContext context, {double top = 8, double bottom = 40}) {
    final deviceType = getDeviceType(context);
    final horizontal = deviceType == DeviceType.smallPhone ? 12.0 :
                      deviceType == DeviceType.phone ? 16.0 :
                      deviceType == DeviceType.tablet ? 24.0 : 32.0;
    return EdgeInsets.fromLTRB(horizontal, top, horizontal, bottom);
  }

  static EdgeInsets cardPadding(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.smallPhone:
        return const EdgeInsets.all(12);
      case DeviceType.phone:
        return const EdgeInsets.all(16);
      case DeviceType.tablet:
        return const EdgeInsets.all(20);
      case DeviceType.desktop:
        return const EdgeInsets.all(24);
    }
  }

  static EdgeInsets headerPadding(BuildContext context) {
    final deviceType = getDeviceType(context);
    final horizontal = deviceType == DeviceType.smallPhone ? 12.0 :
                      deviceType == DeviceType.phone ? 16.0 :
                      deviceType == DeviceType.tablet ? 24.0 : 32.0;
    return EdgeInsets.fromLTRB(horizontal, 16, horizontal, 8);
  }

  // Legacy compatibility
  static EdgeInsets horizontalPadding(BuildContext context, {double factor = 0.05}) {
    return screenPadding(context);
  }

  // Spacing Components
  static SizedBox verticalSpace(BuildContext context, {double multiplier = 1.0, double factor = 0.0}) {
    if (factor > 0) {
      final value = (screenHeight(context) * factor).clamp(8.0, 40.0);
      return SizedBox(height: value);
    }
    return SizedBox(height: spacing(context, multiplier: multiplier));
  }

  static SizedBox horizontalSpace(BuildContext context, {double multiplier = 1.0}) {
    return SizedBox(width: spacing(context, multiplier: multiplier));
  }

  static SizedBox smallGap(BuildContext context) {
    final value = spacing(context, multiplier: 0.5);
    return SizedBox(
      width: value,
      height: value,
    );
  }

  // Typography
  static double responsiveFontSize(BuildContext context, {
    double forWidth = 400,
    double min = 12,
    double max = 32,
  }) {
    final deviceType = getDeviceType(context);
    
    // Professional font scaling based on device type
    double baseSize;
    switch (deviceType) {
      case DeviceType.smallPhone:
        baseSize = min;
        break;
      case DeviceType.phone:
        baseSize = min + (max - min) * 0.3;
        break;
      case DeviceType.tablet:
        baseSize = min + (max - min) * 0.6;
        break;
      case DeviceType.desktop:
        baseSize = max;
        break;
    }
    
    return baseSize.clamp(min, max);
  }

  // Touch Targets (Accessibility: minimum 48px)
  static double minTouchTarget(BuildContext context) {
    final deviceType = getDeviceType(context);
    return deviceType == DeviceType.smallPhone ? 44.0 : 48.0;
  }

  static double buttonHeight(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.smallPhone:
        return 44.0;
      case DeviceType.phone:
        return 48.0;
      case DeviceType.tablet:
        return 52.0;
      case DeviceType.desktop:
        return 56.0;
    }
  }

  // Icons
  static double iconSize(BuildContext context, {AppIconSize size = AppIconSize.medium, double base = 24}) {
    final deviceType = getDeviceType(context);
    final baseSize = switch (size) {
      AppIconSize.small => 16.0,
      AppIconSize.medium => base,
      AppIconSize.large => 32.0,
      AppIconSize.extraLarge => 48.0,
    };
    
    final multiplier = switch (deviceType) {
      DeviceType.smallPhone => 0.85,
      DeviceType.phone => 1.0,
      DeviceType.tablet => 1.2,
      DeviceType.desktop => 1.4,
    };
    
    return baseSize * multiplier;
  }

  // Border Radius
  static double responsiveRadius(BuildContext context, {AppRadiusSize size = AppRadiusSize.medium, double forWidth = 400, double min = 16, double max = 28}) {
    final deviceType = getDeviceType(context);
    
    // Check if legacy parameters are being used
    if (min != 16 || max != 28) {
      // Legacy mode: use the old calculation
      final w = screenWidth(context);
      final ratio = (w / forWidth).clamp(0.8, 1.3);
      return (min + (max - min) * ratio).clamp(min, max);
    }
    
    // New mode: use device type based sizing
    final base = switch (size) {
      AppRadiusSize.small => 8.0,
      AppRadiusSize.medium => 12.0,
      AppRadiusSize.large => 16.0,
      AppRadiusSize.extraLarge => 24.0,
    };
    
    final multiplier = switch (deviceType) {
      DeviceType.smallPhone => 0.9,
      DeviceType.phone => 1.0,
      DeviceType.tablet => 1.1,
      DeviceType.desktop => 1.2,
    };
    
    return base * multiplier;
  }

  // Grid Layouts
  static int gridCrossAxisCount(BuildContext context, {
    double minWidthPerTile = 150,
    int minCount = 2,
    int maxCount = 4,
  }) {
    final deviceType = getDeviceType(context);
    final availableWidth = screenWidth(context) - 
                          (screenPadding(context).left + screenPadding(context).right);
    
    switch (deviceType) {
      case DeviceType.smallPhone:
        return minCount;
      case DeviceType.phone:
        final ideal = (availableWidth / minWidthPerTile).floor();
        return ideal.clamp(minCount, 3);
      case DeviceType.tablet:
        final ideal = (availableWidth / minWidthPerTile).floor();
        return ideal.clamp(3, maxCount);
      case DeviceType.desktop:
        return maxCount;
    }
  }

  static double gridAspectRatio(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.smallPhone:
        return 1.4;
      case DeviceType.phone:
        return 1.6;
      case DeviceType.tablet:
        return 1.8;
      case DeviceType.desktop:
        return 2.0;
    }
  }

  // Component Heights
  static double cardHeight(BuildContext context, {double baseHeight = 120}) {
    final deviceType = getDeviceType(context);
    final multiplier = switch (deviceType) {
      DeviceType.smallPhone => 0.9,
      DeviceType.phone => 1.0,
      DeviceType.tablet => 1.1,
      DeviceType.desktop => 1.2,
    };
    return baseHeight * multiplier;
  }

  static double heroHeight(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.smallPhone:
        return 140.0;
      case DeviceType.phone:
        return 180.0;
      case DeviceType.tablet:
        return 220.0;
      case DeviceType.desktop:
        return 280.0;
    }
  }

  // Layout Helpers
  static double maxContentWidth(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.smallPhone:
        return double.infinity;
      case DeviceType.phone:
        return double.infinity;
      case DeviceType.tablet:
        return 600.0;
      case DeviceType.desktop:
        return 800.0;
    }
  }

  static bool shouldUseCenteredLayout(BuildContext context) {
    return isTablet(context) || isDesktop(context);
  }

  // Legacy compatibility methods
  static EdgeInsets containerPadding(BuildContext context) {
    return cardPadding(context);
  }

  static EdgeInsets innerPadding(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.smallPhone:
        return const EdgeInsets.all(8);
      case DeviceType.phone:
        return const EdgeInsets.all(12);
      case DeviceType.tablet:
        return const EdgeInsets.all(16);
      case DeviceType.desktop:
        return const EdgeInsets.all(20);
    }
  }

  static double gapWidth(BuildContext context, {double base = 8}) {
    return spacing(context, multiplier: 1);
  }
}

enum DeviceType {
  smallPhone,  // < 360px
  phone,       // 360-767px
  tablet,      // 768-1199px
  desktop,     // >= 1200px
}

enum AppIconSize {
  small,
  medium,
  large,
  extraLarge,
}

enum AppRadiusSize {
  small,
  medium,
  large,
  extraLarge,
}

