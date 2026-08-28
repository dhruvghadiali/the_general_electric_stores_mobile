import 'package:dio/dio.dart';

import 'package:the_general_electric_stores_mobile/core/network/api_exception.dart';

/// Turns every transport failure and every error envelope from the API into an
/// [ApiException] with a message that is already fit to show a user.
///
/// The API's error handler answers `{ status, message, errors? }`, so the
/// server's own message is preferred whenever there is one; the generic text
/// below is only the fallback for a response that carried nothing useful.
class ErrorInterceptor extends Interceptor {
  const ErrorInterceptor();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: _toApiException(err),
      ),
    );
  }

  ApiException _toApiException(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return _timeout();

      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return ApiException(
          message: 'No connection to the server. Check your network and '
              'try again.',
          type: ApiExceptionType.noConnection,
          raw: err.error,
        );

      case DioExceptionType.cancel:
        return const ApiException(
          message: 'Request cancelled.',
          type: ApiExceptionType.cancelled,
        );

      case DioExceptionType.badCertificate:
        return const ApiException(
          message: 'The server certificate could not be verified.',
          type: ApiExceptionType.badFormat,
        );

      case DioExceptionType.badResponse:
        return _fromResponse(err.response);

      // Dio adds members to this enum between minor versions
      // (`transformTimeout` arrived in 5.9). Naming each new one here would
      // make this file compile only against the version it was written for,
      // so anything unrecognised is classified by its name instead.
      default:
        return err.type.name.toLowerCase().contains('timeout')
            ? _timeout()
            : ApiException(
                message: 'Something went wrong. Please try again.',
                raw: err.error,
              );
    }
  }

  ApiException _timeout() => const ApiException(
        message: 'The server took too long to respond. Please try again.',
        type: ApiExceptionType.timeout,
      );

  ApiException _fromResponse(Response<dynamic>? response) {
    final int? status = response?.statusCode;
    final Object? body = response?.data;
    final Map<String, dynamic> json =
        body is Map<String, dynamic> ? body : const <String, dynamic>{};

    final Object? message = json['message'];

    return ApiException(
      message: message is String && message.isNotEmpty
          ? message
          : _defaultMessage(status),
      statusCode: status,
      type: ApiExceptionType.badResponse,
      errors: _fieldErrors(json),
      raw: body,
    );
  }

  /// Reads the field-level detail a Joi rejection carries. Both the object form
  /// (`{"email": "..."}`) and the array form (`[{"field": "email",
  /// "message": "..."}]`) are accepted.
  Map<String, String> _fieldErrors(Map<String, dynamic> json) {
    final Object? errors = json['errors'] ?? json['details'] ?? json['error'];

    if (errors is Map) {
      return errors.map(
        (Object? key, Object? value) => MapEntry<String, String>(
          '$key',
          value is List ? value.join(', ') : '$value',
        ),
      );
    }

    if (errors is List) {
      final Map<String, String> result = <String, String>{};
      for (final Object? entry in errors) {
        if (entry is! Map) continue;
        final Object? field = entry['field'] ?? entry['path'] ?? entry['key'];
        final Object? message = entry['message'] ?? entry['msg'];
        if (field != null && message != null) result['$field'] = '$message';
      }
      return result;
    }

    return const <String, String>{};
  }

  String _defaultMessage(int? status) {
    switch (status) {
      case 400:
        return 'Some of the details are not valid. Please check and retry.';
      case 401:
        return 'Your session has expired. Please sign in again.';
      case 403:
        return 'You do not have permission to do that.';
      case 404:
        return 'We could not find what you were looking for.';
      case 409:
        return 'That conflicts with something that already exists.';
      case 422:
        return 'Some of the details are not valid. Please check and retry.';
      case 429:
        return 'Too many requests. Please wait a moment and try again.';
      default:
        if (status != null && status >= 500) {
          return 'Something went wrong on our side. Please try again shortly.';
        }
        return 'Something went wrong. Please try again.';
    }
  }
}
