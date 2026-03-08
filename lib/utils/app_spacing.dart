import 'package:flutter/material.dart';

class AppSpacing {
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 12.0;
  static const double spacingLg = 16.0;
  static const double spacingXl = 24.0;
  static const double spacing2Xl = 32.0;

  static const EdgeInsets paddingXs = EdgeInsets.all(spacingXs);
  static const EdgeInsets paddingSm = EdgeInsets.all(spacingSm);
  static const EdgeInsets paddingMd = EdgeInsets.all(spacingMd);
  static const EdgeInsets paddingLg = EdgeInsets.all(spacingLg);

  static const BorderRadius borderRadiusSm = BorderRadius.all(
    Radius.circular(8),
  );
  static const BorderRadius borderRadiusMd = BorderRadius.all(
    Radius.circular(12),
  );
  static const BorderRadius borderRadiusLg = BorderRadius.all(
    Radius.circular(16),
  );
}
