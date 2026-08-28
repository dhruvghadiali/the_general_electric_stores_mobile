import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Typed access to everything that comes out of `.env`.
///
/// Nothing else in the app reads [dotenv] directly — a value that is not
/// exposed here does not exist as far as the rest of the codebase is concerned.
class Env {
  const Env._();

  static const String _fileName = '.env';

  /// Loads `.env` into memory. Call once, before `runApp`.
  static Future<void> load() => dotenv.load(fileName: _fileName);

  static String get appEnv => _string('APP_ENV', 'development');

  /// Base URL of the-general-electric-stores-api. No version prefix: the API
  /// scopes every route by role in the path instead (`/employee/signin`).
  ///
  /// Against a local API, `10.0.2.2` is the host machine as seen from the
  /// Android emulator; use `127.0.0.1` for the iOS simulator and the LAN IP
  /// for a real device.
  static String get apiBaseUrl => _string(
        'API_BASE_URL',
        'https://the-general-electric-stores-api-sit.onrender.com',
      );

  static Duration get connectTimeout =>
      Duration(milliseconds: _int('API_CONNECT_TIMEOUT_MS', 30000));

  /// Generous by default: the SIT server sleeps on Render's free tier and the
  /// first request after an idle period waits out a cold start.
  static Duration get receiveTimeout =>
      Duration(milliseconds: _int('API_RECEIVE_TIMEOUT_MS', 60000));

  static bool get enableHttpLogs => _bool('ENABLE_HTTP_LOGS', isDevelopment);

  static bool get isDevelopment => appEnv == 'development';

  static bool get isProduction => appEnv == 'production';

  static String _string(String key, String fallback) {
    final String? value = dotenv.maybeGet(key);
    return (value == null || value.isEmpty) ? fallback : value;
  }

  static int _int(String key, int fallback) =>
      int.tryParse(_string(key, '$fallback')) ?? fallback;

  static bool _bool(String key, bool fallback) =>
      _string(key, '$fallback').toLowerCase() == 'true';
}
