import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:the_general_electric_stores_mobile/core/utils/logger.dart';

/// Request/response logging for development builds.
///
/// Headers are copied before anything is printed and `Authorization` is
/// redacted in the copy — a token in the console is a token in a screenshot,
/// and mutating the live headers would send the redacted value to the server.
class LoggingInterceptor extends Interceptor {
  const LoggingInterceptor({this.maxBodyLength = 2000});

  final int maxBodyLength;

  static const List<String> _redactedHeaders = <String>[
    'authorization',
    'cookie',
    'set-cookie',
    'x-api-key',
  ];

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    AppLogger.d(
      '--> ${options.method} ${options.uri}\n'
      'headers: ${_safeHeaders(options.headers)}\n'
      'query: ${options.queryParameters}\n'
      'body: ${_body(options.data)}',
    );
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    AppLogger.d(
      '<-- ${response.statusCode} ${response.requestOptions.method} '
      '${response.requestOptions.uri}\n'
      'body: ${_body(response.data)}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.w(
      'xxx ${err.response?.statusCode ?? err.type.name} '
      '${err.requestOptions.method} ${err.requestOptions.uri}\n'
      'body: ${_body(err.response?.data)}',
    );
    handler.next(err);
  }

  Map<String, dynamic> _safeHeaders(Map<String, dynamic> headers) {
    final Map<String, dynamic> copy = Map<String, dynamic>.of(headers);
    for (final String key in copy.keys.toList()) {
      if (_redactedHeaders.contains(key.toLowerCase())) {
        copy[key] = '<redacted>';
      }
    }
    return copy;
  }

  String _body(Object? data) {
    if (data == null) return 'null';
    if (data is FormData) {
      return 'FormData(fields: ${data.fields.length}, '
          'files: ${data.files.length})';
    }

    String text;
    try {
      text = data is String ? data : jsonEncode(data);
    } on Object {
      text = data.toString();
    }

    return text.length <= maxBodyLength
        ? text
        : '${text.substring(0, maxBodyLength)}… (${text.length} chars)';
  }
}
