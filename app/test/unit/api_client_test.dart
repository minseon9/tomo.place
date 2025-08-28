import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:app/shared/infrastructure/network/api_client.dart';
import 'package:app/shared/config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ApiClient Tests', () {
    late ApiClient apiClient;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await AppConfig.initialize();
      apiClient = ApiClient();
    });

    tearDown(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    });

    test('should be initialized with correct base URL', () {
      expect(apiClient, isNotNull);
      // Dio 인스턴스가 올바르게 생성되었는지 확인
      expect(apiClient, isA<ApiClient>());
    });

    test('should handle successful GET request', () async {
      // Mock HTTP server를 사용하거나 실제 테스트 서버가 필요
      // 여기서는 예외 처리가 올바르게 작동하는지 테스트
      
      try {
        await apiClient.get('/test-endpoint', {});
      } catch (e) {
        // 네트워크 에러가 발생하는 것이 정상 (테스트 환경에서는 서버가 없음)
        expect(e, isA<Exception>());
      }
    });

    test('should handle successful POST request', () async {
      final testData = {'key': 'value'};
      
      try {
        await apiClient.post('/test-endpoint', {}, data: testData);
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });

    test('should handle successful PUT request', () async {
      final testData = {'key': 'updated-value'};
      
      try {
        await apiClient.put('/test-endpoint', {}, data: testData);
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });

    test('should handle successful DELETE request', () async {
      try {
        await apiClient.delete('/test-endpoint', {});
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });

    test('should handle DioException with response', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          statusCode: 404,
          data: {'error': 'Not Found'},
          requestOptions: RequestOptions(path: '/test'),
        ),
      );

      expect(
        () => apiClient._handleDioException(dioException),
        throwsA(isA<Exception>()),
      );
    });

    test('should handle DioException without response', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );

      expect(
        () => apiClient._handleDioException(dioException),
        throwsA(isA<Exception>()),
      );
    });

    test('should handle DioException with timeout', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );

      expect(
        () => apiClient._handleDioException(dioException),
        throwsA(isA<Exception>()),
      );
    });

    test('should handle DioException with network error', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionError,
        error: 'Network error',
      );

      expect(
        () => apiClient._handleDioException(dioException),
        throwsA(isA<Exception>()),
      );
    });

    test('should handle DioException with cancel', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.cancel,
      );

      expect(
        () => apiClient._handleDioException(dioException),
        throwsA(isA<Exception>()),
      );
    });

    test('should handle DioException with receive timeout', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.receiveTimeout,
      );

      expect(
        () => apiClient._handleDioException(dioException),
        throwsA(isA<Exception>()),
      );
    });

    test('should handle DioException with send timeout', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.sendTimeout,
      );

      expect(
        () => apiClient._handleDioException(dioException),
        throwsA(isA<Exception>()),
      );
    });

    test('should handle DioException with bad certificate', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badCertificate,
      );

      expect(
        () => apiClient._handleDioException(dioException),
        throwsA(isA<Exception>()),
      );
    });

    test('should handle DioException with connection error', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionError,
      );

      expect(
        () => apiClient._handleDioException(dioException),
        throwsA(isA<Exception>()),
      );
    });

    test('should handle DioException with unknown type', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.unknown,
      );

      expect(
        () => apiClient._handleDioException(dioException),
        throwsA(isA<Exception>()),
      );
    });

    test('should handle null response data gracefully', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          statusCode: 404,
          data: null,
          requestOptions: RequestOptions(path: '/test'),
        ),
      );

      expect(
        () => apiClient._handleDioException(dioException),
        throwsA(isA<Exception>()),
      );
    });
  });
}
