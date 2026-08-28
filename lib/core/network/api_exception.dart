import 'package:dio/dio.dart';

/// Every failure that leaves the network layer is one of these.
///
/// Nothing above [ApiClient] ever sees a [DioException]: the error interceptor
/// converts transport failures and the API's own error envelope into a single
/// type with a message that is already safe to show a user.
class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.type = ApiExceptionType.unknown,
    this.errors = const <String, String>{},
    this.raw,
  });

  final String message;
  final int? statusCode;
  final ApiExceptionType type;

  /// Field-level validation messages keyed by field name, as returned by the
  /// API's Joi layer. Empty for anything that is not a 400.
  final Map<String, String> errors;

  final Object? raw;

  bool get isUnauthorized => statusCode == 401;

  bool get isForbidden => statusCode == 403;

  bool get isValidation => statusCode == 400 || statusCode == 422;

  bool get isNetwork =>
      type == ApiExceptionType.noConnection || type == ApiExceptionType.timeout;

  @override
  String toString() => 'ApiException($statusCode, $type): $message';
}

enum ApiExceptionType {
  /// The device has no usable connection, or the host refused it.
  noConnection,

  /// Connect, send or receive timed out.
  timeout,

  /// The server answered with a non-2xx status.
  badResponse,

  /// The request was cancelled by the caller.
  cancelled,

  /// A response arrived but did not look like the API's envelope.
  badFormat,

  unknown,
}
