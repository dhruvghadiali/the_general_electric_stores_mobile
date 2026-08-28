/// Every bundled asset path, in one place.
///
/// A typo in an asset string is a runtime failure with no compile-time
/// warning, so no widget writes one inline.
class AppAssets {
  const AppAssets._();

  static const String _images = 'assets/images';

  /// The full "ge" wordmark, transparent background, 493×283.
  static const String logo = '$_images/logo.png';
}
