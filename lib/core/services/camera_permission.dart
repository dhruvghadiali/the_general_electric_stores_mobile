import 'package:permission_handler/permission_handler.dart';

/// What asking for the camera produced.
///
/// The three failures are genuinely different and the UI has to treat them
/// differently: [denied] can be asked again, [permanentlyDenied] can only be
/// fixed in Settings, and [restricted] cannot be fixed by this user at all
/// (parental controls, or an MDM policy).
enum CameraPermissionResult {
  granted,
  denied,
  permanentlyDenied,
  restricted,
}

/// The camera permission, asked for in one place.
///
/// iOS only ever shows its prompt once — every later `request()` returns the
/// stored answer without showing anything. That is why a permanently denied
/// result has to route the user to Settings rather than asking again, which
/// would look like a dead button.
class CameraPermission {
  const CameraPermission._();

  static Future<CameraPermissionResult> ensure() async {
    final PermissionStatus current = await Permission.camera.status;
    if (current.isGranted || current.isLimited) {
      return CameraPermissionResult.granted;
    }
    if (current.isPermanentlyDenied) {
      return CameraPermissionResult.permanentlyDenied;
    }
    if (current.isRestricted) return CameraPermissionResult.restricted;

    // Not asked yet, or asked and declined once on Android — either way the
    // system prompt is worth showing.
    final PermissionStatus asked = await Permission.camera.request();
    if (asked.isGranted || asked.isLimited) {
      return CameraPermissionResult.granted;
    }
    if (asked.isPermanentlyDenied) {
      return CameraPermissionResult.permanentlyDenied;
    }
    if (asked.isRestricted) return CameraPermissionResult.restricted;
    return CameraPermissionResult.denied;
  }

  /// Opens the OS settings page for this app.
  static Future<bool> openSettings() => openAppSettings();
}
