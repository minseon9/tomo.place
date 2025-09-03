import 'package:dio/dio.dart';

import '../../config/app_config.dart';
import '../../exceptions/network_exception.dart';
import '../../exceptions/server_exception.dart';

class ApiClient {
  final Dio _dio;

  ApiClient()
    : _dio = Dio(
        BaseOptions(
          baseUrl: AppConfig.apiUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

  void addInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);
  }

  Future<T> get<T>(
    String path,
    T Function(Map<String, dynamic>) fromJson, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<T> post<T>(
    String path,
    Map<String, dynamic> data,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final response = await _dio.post(path, data: data);
      return fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<T> put<T>(
    String path,
    Map<String, dynamic> data,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final response = await _dio.put(path, data: data);
      return fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<void> delete(String path) async {
    try {
      await _dio.delete(path);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Exception _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
        return NetworkException.connectionTimeout();
      case DioExceptionType.receiveTimeout:
        return NetworkException.receiveTimeout();
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message =
            e.response?.data?.toString() ?? e.message ?? 'Unknown error';
        if (statusCode != null) {
          return ServerException.fromStatusCode(
            statusCode: statusCode,
            message: message,
          );
        } else {
          return NetworkException.badResponse();
        }
      case DioExceptionType.cancel:
        return NetworkException.requestCancelled();
      case DioExceptionType.connectionError:
        return NetworkException.noConnection();
      default:
        return NetworkException.connectionError();
    }
  }
}
