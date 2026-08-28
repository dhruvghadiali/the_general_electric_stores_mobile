/// Values that are neither routes, endpoints nor storage keys.
class AppConstants {
  const AppConstants._();

  static const String appName = 'The General Electric Stores';

  /// Mirrors `pagination_defaults` in the API
  /// (`src/validators/constants/common.js`). Asking for more than
  /// [maxPageLimit] is a 400 from the server, so the client clamps first.
  static const int defaultPage = 1;
  static const int defaultPageLimit = 20;
  static const int maxPageLimit = 100;

  /// How long the list screens wait after the last keystroke before searching.
  static const Duration searchDebounce = Duration(milliseconds: 400);

  static const Duration snackBarDuration = Duration(seconds: 3);
}
