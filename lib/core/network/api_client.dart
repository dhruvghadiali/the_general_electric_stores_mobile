import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData, MultipartFile, Response;

import 'package:the_general_electric_stores_mobile/core/config/env.dart';
import 'package:the_general_electric_stores_mobile/core/network/api_exception.dart';
import 'package:the_general_electric_stores_mobile/core/network/api_response.dart';
import 'package:the_general_electric_stores_mobile/core/network/interceptors/auth_interceptor.dart';
import 'package:the_general_electric_stores_mobile/core/network/interceptors/error_interceptor.dart';
import 'package:the_general_electric_stores_mobile/core/network/interceptors/logging_interceptor.dart';
import 'package:the_general_electric_stores_mobile/core/services/storage_service.dart';

/// The single HTTP door out of the app.
///
/// Repositories call [get], [post], [put], [patch] and [delete] and get back an
/// [ApiResponse]; anything that fails throws an [ApiException]. No widget, no
/// controller and no repository ever constructs a [Dio] of its own.
class ApiClient extends GetxService {
  static ApiClient get to => Get.find<ApiClient>();

  late final Dio _dio;

  /// Called when a refresh could not save the session. Wired up in
  /// `InitialBinding` so the network layer does not import the router.
  Future<void> Function()? onSessionExpired;

  Future<ApiClient> init() async {
    _dio = Dio(
      BaseOptions(
        baseUrl: Env.apiBaseUrl,
        connectTimeout: Env.connectTimeout,
        receiveTimeout: Env.receiveTimeout,
        sendTimeout: Env.connectTimeout,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        headers: <String, dynamic>{'Accept': 'application/json'},
        // Non-2xx responses go through the error interceptor, which is the one
        // place that knows how to read the API's error envelope.
        validateStatus: (int? status) =>
            status != null && status >= 200 && status < 300,
      ),
    );

    _dio.interceptors.addAll(<Interceptor>[
      AuthInterceptor(
        storage: StorageService.to,
        onSessionExpired: () async => onSessionExpired?.call(),
      ),
      if (Env.enableHttpLogs) const LoggingInterceptor(),
      const ErrorInterceptor(),
    ]);

    return this;
  }

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
    T Function(Object? data)? parser,
    CancelToken? cancelToken,
  }) {
    return _send<T>(
      () => _dio.get<dynamic>(
        path,
        queryParameters: query,
        cancelToken: cancelToken,
      ),
      parser,
    );
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    T Function(Object? data)? parser,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) {
    return _send<T>(
      () => _dio.post<dynamic>(
        path,
        data: body,
        queryParameters: query,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      ),
      parser,
    );
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    T Function(Object? data)? parser,
    CancelToken? cancelToken,
  }) {
    return _send<T>(
      () => _dio.put<dynamic>(
        path,
        data: body,
        queryParameters: query,
        cancelToken: cancelToken,
      ),
      parser,
    );
  }

  Future<ApiResponse<T>> patch<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    T Function(Object? data)? parser,
    CancelToken? cancelToken,
  }) {
    return _send<T>(
      () => _dio.patch<dynamic>(
        path,
        data: body,
        queryParameters: query,
        cancelToken: cancelToken,
      ),
      parser,
    );
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    T Function(Object? data)? parser,
    CancelToken? cancelToken,
  }) {
    return _send<T>(
      () => _dio.delete<dynamic>(
        path,
        data: body,
        queryParameters: query,
        cancelToken: cancelToken,
      ),
      parser,
    );
  }

  Future<ApiResponse<T>> _send<T>(
    Future<Response<dynamic>> Function() request,
    T Function(Object? data)? parser,
  ) async {
    try {
      final Response<dynamic> response = await request();
      final Object? body = response.data;

      if (body is Map<String, dynamic>) {
        return ApiResponse<T>.fromJson(
          body,
          response.statusCode ?? 200,
          parser: parser,
        );
      }

      // A 204, or an endpoint that answered with a bare array.
      return ApiResponse<T>(
        statusCode: response.statusCode ?? 200,
        message: '',
        data: parser == null ? null : parser(body),
      );
    } on DioException catch (error) {
      final Object? converted = error.error;
      if (converted is ApiException) throw converted;
      throw ApiException(
        message: error.message ?? 'Something went wrong. Please try again.',
        statusCode: error.response?.statusCode,
        raw: error,
      );
    }
  }
}
