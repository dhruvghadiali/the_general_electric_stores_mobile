/// Keys used with [StorageService]. One place, so a key is never mistyped
/// in a way that silently reads back null.
class StorageKeys {
  const StorageKeys._();

  // Secure storage
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';

  // Preferences
  static const String user = 'user';

  /// Which role the session was opened under. Needed to build the role-scoped
  /// auth paths on later requests, and known before the user record loads.
  static const String userRole = 'user_role';
}
