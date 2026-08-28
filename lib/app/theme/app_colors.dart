import 'package:flutter/material.dart';

/// The brand palette, derived from the logo.
///
/// Two colours are measured off the mark itself — the ink `#164863` and the
/// pale blue of the "e" bar `#9CBEC8`. Everything else is a tonal ramp built
/// from those two hues (201° and 194°), so every shade in the app traces back
/// to the logo rather than to somebody's eyedropper.
///
/// Widgets read colours from `Theme.of(context).colorScheme` wherever a
/// semantic role exists. These constants are what the schemes are built from,
/// not a shortcut around them.
class AppColors {
  const AppColors._();

  // ------------------------------------------------------------ logo colours

  /// The ink of the mark, exactly as it appears in the logo file.
  static const Color brandInk = Color(0xFF164863);

  /// The pale blue of the "e" bar, exactly as it appears in the logo file.
  static const Color brandPale = Color(0xFF9CBEC8);

  // -------------------------------------------------------------- blue ramp
  // Hue 201°, lightness stepped, saturation eased off at the pale end.
  // The number after each shade is its contrast ratio on white — anything
  // used for body text needs 4.5, large text 3.0.

  static const Color blue50 = Color(0xFFF0F5F8); // 1.10
  static const Color blue100 = Color(0xFFDDE8EE); // 1.25
  static const Color blue200 = Color(0xFFB2D4E6); // 1.56
  static const Color blue300 = Color(0xFF71B9DF); // 2.17
  static const Color blue400 = Color(0xFF2E98D1); // 3.23
  static const Color blue500 = Color(0xFF23739F); // 5.20
  static const Color blue600 = Color(0xFF1C5B7D); // 7.38
  static const Color blue700 = Color(0xFF164964); // 9.73 — the logo ink
  static const Color blue800 = Color(0xFF103549); // 12.88
  static const Color blue900 = Color(0xFF0B2330); // 16.21

  // -------------------------------------------------------------- teal ramp
  // Hue 194°, built from the pale bar. Muted on purpose: this is the
  // supporting colour, and it must never compete with the primary.

  static const Color teal50 = Color(0xFFF1F5F6); // 1.10
  static const Color teal100 = Color(0xFFE0E8EB); // 1.24
  static const Color teal200 = Color(0xFFBDD4DB); // 1.54
  static const Color teal300 = Color(0xFF90B6C1); // 2.18
  static const Color teal400 = Color(0xFF5B93A4); // 3.40
  static const Color teal500 = Color(0xFF45707D); // 5.43
  static const Color teal600 = Color(0xFF375862); // 7.64
  static const Color teal700 = Color(0xFF2C464E); // 9.98
  static const Color teal800 = Color(0xFF203439); // 13.09
  static const Color teal900 = Color(0xFF152226); // 16.32

  // ----------------------------------------------------------- neutral ramp
  // Tinted ~10% toward the brand hue. Cohesive with the blues without
  // reading as blue, and warmer than a pure grey next to the mark.

  static const Color neutral0 = Color(0xFFFFFFFF);
  static const Color neutral50 = Color(0xFFF8F9F9);
  static const Color neutral100 = Color(0xFFF2F4F5);
  static const Color neutral200 = Color(0xFFE4E7E9);
  static const Color neutral300 = Color(0xFFD2D7DA);
  static const Color neutral500 = Color(0xFF819098);
  static const Color neutral600 = Color(0xFF5C707A);
  static const Color neutral700 = Color(0xFF425057);
  static const Color neutral800 = Color(0xFF20272A);
  static const Color neutral900 = Color(0xFF131719);
  static const Color neutral950 = Color(0xFF0C0F10);

  // ----------------------------------------------------------------- status
  // Hues borrowed from the standard semantic set, darkened to sit next to a
  // deep blue primary without shouting over it.

  static const Color success = Color(0xFF15803D);
  static const Color warning = Color(0xFFB45309);
  static const Color error = Color(0xFFC0261F);
  static const Color info = blue600;

  // ------------------------------------------------------ neutrals — light

  static const Color background = neutral50;
  static const Color surface = neutral0;
  static const Color surfaceAlt = neutral100;
  static const Color textPrimary = neutral800;
  static const Color textTertiary = neutral500;

  // ------------------------------------------------------- neutrals — dark

  static const Color backgroundDark = neutral950;
  static const Color surfaceAltDark = Color(0xFF1B2124);
  static const Color borderDark = Color(0xFF2B3438);
  static const Color textTertiaryDark = neutral500;

  // ---------------------------------------------------------------- schemes

  static const ColorScheme lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: blue700,
    onPrimary: neutral0,
    primaryContainer: blue100,
    onPrimaryContainer: blue800,
    secondary: teal600,
    onSecondary: neutral0,
    secondaryContainer: teal100,
    onSecondaryContainer: teal800,
    tertiary: blue500,
    onTertiary: neutral0,
    tertiaryContainer: blue50,
    onTertiaryContainer: blue700,
    error: error,
    onError: neutral0,
    errorContainer: Color(0xFFFCE4E3),
    onErrorContainer: Color(0xFF6E1511),
    surface: neutral0,
    onSurface: neutral800,
    surfaceContainerLowest: neutral0,
    surfaceContainerLow: neutral50,
    surfaceContainer: neutral50,
    surfaceContainerHigh: neutral100,
    // neutral200 here would drop the muted-text pair to 4.17 — below AA.
    surfaceContainerHighest: neutral100,
    onSurfaceVariant: neutral600,
    outline: neutral200,
    outlineVariant: neutral300,
    inverseSurface: neutral800,
    onInverseSurface: neutral100,
    inversePrimary: blue300,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
  );

  static const ColorScheme darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: blue300,
    onPrimary: blue900,
    primaryContainer: blue800,
    onPrimaryContainer: blue100,
    secondary: teal300,
    onSecondary: teal900,
    secondaryContainer: teal800,
    onSecondaryContainer: teal100,
    tertiary: blue200,
    onTertiary: blue900,
    tertiaryContainer: blue700,
    onTertiaryContainer: blue50,
    error: Color(0xFFF08B85),
    onError: Color(0xFF48100D),
    errorContainer: Color(0xFF6E1511),
    onErrorContainer: Color(0xFFFCE4E3),
    surface: neutral900,
    onSurface: neutral100,
    surfaceContainerLowest: neutral950,
    surfaceContainerLow: neutral900,
    surfaceContainer: surfaceAltDark,
    surfaceContainerHigh: surfaceAltDark,
    surfaceContainerHighest: borderDark,
    onSurfaceVariant: neutral300,
    outline: borderDark,
    outlineVariant: neutral700,
    inverseSurface: neutral100,
    onInverseSurface: neutral800,
    inversePrimary: blue700,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
  );
}
