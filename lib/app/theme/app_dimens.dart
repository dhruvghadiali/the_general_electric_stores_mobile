/// Spacing, radius and sizing scale.
///
/// Every gap in the app is one of these steps. A magic `EdgeInsets.all(13)`
/// in a widget is a bug, not a preference.
class AppDimens {
  const AppDimens._();

  // Spacing — 4pt scale
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  // Radius
  static const double radiusSm = 6;
  static const double radiusMd = 10;
  static const double radiusLg = 16;
  static const double radiusPill = 999;

  // Components
  static const double buttonHeight = 52;
  static const double appBarHeight = 56;
  static const double iconSm = 16;
  static const double iconMd = 20;
  static const double iconLg = 24;
  static const double iconXl = 32;

  // Layout
  static const double screenPadding = lg;
  static const double maxContentWidth = 560;
}
