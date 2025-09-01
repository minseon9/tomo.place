import 'package:dio/dio.dart';
import '../../config/app_config.dart';
import '../../exceptions/network_exception.dart';
import '../../exceptions/server_exception.dart';

/// 공통 API 클라이언트
/// 
/// 모든 도메인에서 공통으로 사용하는 네트워크 클라이언트입니다.
/// 기본 설정과 에러 처리를 담당합니다.
class ApiClient {
  final Dio _dio;
  
  ApiClient() : _dio = Dio(BaseOptions(
    baseUrl: AppConfig.apiUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));
  
  /// GET 요청
  Future<T> get<T>(
    String path,
    T Function(Map<String, dynamic>) fromJson, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );
      return fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }
  
  /// POST 요청
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
  
  /// PUT 요청
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
  
  /// DELETE 요청
  Future<void> delete(String path) async {
    try {
      await _dio.delete(path);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }
  
  /// DioException을 적절한 예외로 변환
  Exception _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
        return NetworkException.connectionTimeout();
      case DioExceptionType.receiveTimeout:
        return NetworkException.receiveTimeout();
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?.toString() ?? e.message ?? 'Unknown error';
        if (statusCode != null) {
          return ServerException.fromStatusCode(
            statusCode: statusCode,
            message: message,
          );
        } else {
          return NetworkException(
            'Bad response: $message',
            userMessage: '서버 응답 오류가 발생했습니다.',
          );
        }
      case DioExceptionType.cancel:
        return NetworkException(
          'Request cancelled: ${e.message}',
          userMessage: '요청이 취소되었습니다.',
        );
      case DioExceptionType.connectionError:
        return NetworkException.noConnection();
      default:
        return NetworkException(
          'Network error: ${e.message}',
          userMessage: '네트워크 오류가 발생했습니다.',
        );
    }
  }
}
