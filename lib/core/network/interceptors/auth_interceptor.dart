import 'package:dio/dio.dart';

import 'package:the_general_electric_stores_mobile/core/constants/api_endpoints.dart';
import 'package:the_general_electric_stores_mobile/core/services/storage_service.dart';

/// Attaches the bearer token to every outgoing request, and ends the session
/// when the API stops accepting it.
///
/// There is no refresh here, and none is missing. The API issues one
/// self-contained JWT at signin — `jwt.sign({ user_type }, secret, { subject,
/// expiresIn })` — and mounts no route to renew, confirm or revoke it. So a 401
/// has exactly one meaning: the token is spent, and the only way back is
/// signing in again. Retrying it, queueing behind a refresh, or holding the
/// request open would all be pretending there is a second chance to be had.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required StorageService storage,
    required Future<void> Function() onSessionExpired,
  })  : _storage = storage,
        _onSessionExpired = onSessionExpired;

  final StorageService _storage;
  final Future<void> Function() _onSessionExpired;

  /// Signin is the one path that carries no token. Auth paths are role-scoped
  /// (`/employee/auth/signin`), so matching on the suffix keeps this correct
  /// however many roles exist.
  bool _isPublic(String path) => ApiEndpoints.publicSuffixes
      .any((String suffix) => path.endsWith(suffix));

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isPublic(options.path)) {
      final String? token = await _storage.accessToken;
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final bool sessionOver = err.response?.statusCode == 401 &&
        !_isPublic(err.requestOptions.path);

    if (sessionOver) {
      // Cleared before the error travels on, so whatever screen handles it is
      // already looking at a signed-out app rather than racing this.
      await _storage.clearSession();
      await _onSessionExpired();
    }

    handler.next(err);
  }
}
