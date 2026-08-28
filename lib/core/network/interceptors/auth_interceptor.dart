import 'package:dio/dio.dart';

import 'package:the_general_electric_stores_mobile/core/constants/api_endpoints.dart';
import 'package:the_general_electric_stores_mobile/core/constants/user_role.dart';
import 'package:the_general_electric_stores_mobile/core/services/storage_service.dart';

/// Attaches the bearer token to every outgoing request and, when the API
/// answers 401, refreshes it once and replays the original request.
///
/// A second 401 on the same request is a dead session: the queue is cleared,
/// storage is wiped and [onSessionExpired] is called so the app can route back
/// to login. The refresh call itself is never retried, which is what stops the
/// interceptor recursing.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required Dio dio,
    required StorageService storage,
    required Future<void> Function() onSessionExpired,
  })  : _dio = dio,
        _storage = storage,
        _onSessionExpired = onSessionExpired;

  final Dio _dio;
  final StorageService _storage;
  final Future<void> Function() _onSessionExpired;

  /// Auth paths are role-scoped (`/employee/signin`), so matching on the
  /// suffix keeps this correct however many roles exist.
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
    final RequestOptions request = err.requestOptions;
    final bool retryable = err.response?.statusCode == 401 &&
        !_isPublic(request.path) &&
        request.extra['retried'] != true;

    if (!retryable) {
      handler.next(err);
      return;
    }

    final bool refreshed = await _refresh();
    if (!refreshed) {
      await _storage.clearSession();
      await _onSessionExpired();
      handler.next(err);
      return;
    }

    try {
      request.extra['retried'] = true;
      final String? token = await _storage.accessToken;
      request.headers['Authorization'] = 'Bearer $token';
      final Response<dynamic> response = await _dio.fetch<dynamic>(request);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  Future<bool> _refresh() async {
    final String? refreshToken = await _storage.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) return false;

    // The refresh path is scoped by the role the session was opened under.
    // Without it there is no path to call, so a session with no stored role
    // cannot be refreshed and has to sign in again.
    final UserRole? role = _storage.signedInRole;
    if (role == null) return false;

    try {
      final Response<dynamic> response = await _dio.post<dynamic>(
        ApiEndpoints.refreshToken(role),
        data: <String, dynamic>{'refresh_token': refreshToken},
      );

      final Object? body = response.data;
      if (body is! Map<String, dynamic>) return false;

      final Object? data = body['data'];
      final Map<String, dynamic>? tokens = data is Map<String, dynamic>
          ? data
          : (data is List && data.isNotEmpty && data.first is Map)
              ? Map<String, dynamic>.from(data.first as Map<dynamic, dynamic>)
              : null;
      if (tokens == null) return false;

      final Object? access = tokens['access_token'] ?? tokens['token'];
      if (access is! String || access.isEmpty) return false;

      final Object? next = tokens['refresh_token'];
      await _storage.saveTokens(
        accessToken: access,
        refreshToken: next is String && next.isNotEmpty ? next : null,
      );
      return true;
    } on DioException {
      return false;
    }
  }

}
