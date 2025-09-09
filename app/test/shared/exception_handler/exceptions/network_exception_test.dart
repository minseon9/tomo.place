import 'package:flutter_test/flutter_test.dart';

import 'package:tomo_place/shared/exception_handler/exceptions/network_exception.dart';
import 'package:tomo_place/shared/exception_handler/models/exception_codes.dart';
import 'package:tomo_place/shared/exception_handler/models/exception_types.dart';

void main() {
  group('NetworkException', () {
    group('constructor', () {
      test('should create instance with all required parameters', () {
        const exception = NetworkException(
          message: 'Test network error',
          userMessage: '네트워크 오류가 발생했습니다.',
          title: '네트워크 오류',
          errorType: ExceptionTypes.network,
          errorCode: 'TEST_001',
          suggestedAction: '네트워크를 확인해주세요.',
          statusCode: 500,
        );

        expect(exception.message, equals('Test network error'));
        expect(exception.userMessage, equals('네트워크 오류가 발생했습니다.'));
        expect(exception.title, equals('네트워크 오류'));
        expect(exception.errorType, equals(ExceptionTypes.network));
        expect(exception.errorCode, equals('TEST_001'));
        expect(exception.suggestedAction, equals('네트워크를 확인해주세요.'));
        expect(exception.statusCode, equals(500));
      });

      test('should create instance with optional parameters', () {
        const exception = NetworkException(
          message: 'Test network error',
          userMessage: '네트워크 오류가 발생했습니다.',
          title: '네트워크 오류',
          errorType: ExceptionTypes.network,
        );

        expect(exception.message, equals('Test network error'));
        expect(exception.userMessage, equals('네트워크 오류가 발생했습니다.'));
        expect(exception.title, equals('네트워크 오류'));
        expect(exception.errorType, equals(ExceptionTypes.network));
        expect(exception.errorCode, isNull);
        expect(exception.suggestedAction, isNull);
        expect(exception.statusCode, isNull);
      });
    });

    group('connectionTimeout', () {
      test('should create connection timeout exception', () {
        final exception = NetworkException.connectionTimeout();

        expect(exception.message, equals('Connection timeout occurred'));
        expect(exception.userMessage, equals('네트워크 연결 시간이 초과되었습니다. 다시 시도해주세요.'));
        expect(exception.title, equals('연결 시간 초과'));
        expect(exception.errorType, equals(ExceptionTypes.timeout));
        expect(exception.errorCode, equals(ExceptionCodes.connectionTimeout));
        expect(exception.suggestedAction, equals('네트워크 상태를 확인하고 다시 시도해주세요.'));
        expect(exception.statusCode, isNull);
      });

      test('should have correct error code', () {
        final exception = NetworkException.connectionTimeout();
        expect(exception.errorCode, equals(ExceptionCodes.connectionTimeout));
      });

      test('should have correct error type', () {
        final exception = NetworkException.connectionTimeout();
        expect(exception.errorType, equals(ExceptionTypes.timeout));
      });
    });

    group('receiveTimeout', () {
      test('should create receive timeout exception', () {
        final exception = NetworkException.receiveTimeout();

        expect(exception.message, equals('Receive timeout occurred'));
        expect(exception.userMessage, equals('서버 응답 시간이 초과되었습니다. 다시 시도해주세요.'));
        expect(exception.title, equals('응답 시간 초과'));
        expect(exception.errorType, equals(ExceptionTypes.timeout));
        expect(exception.errorCode, equals(ExceptionCodes.receiveTimeout));
        expect(exception.suggestedAction, equals('잠시 후 다시 시도해주세요.'));
        expect(exception.statusCode, isNull);
      });

      test('should have correct error code', () {
        final exception = NetworkException.receiveTimeout();
        expect(exception.errorCode, equals(ExceptionCodes.receiveTimeout));
      });

      test('should have correct error type', () {
        final exception = NetworkException.receiveTimeout();
        expect(exception.errorType, equals(ExceptionTypes.timeout));
      });
    });

    group('noConnection', () {
      test('should create no connection exception', () {
        final exception = NetworkException.noConnection();

        expect(exception.message, equals('No network connection available'));
        expect(exception.userMessage, equals('네트워크 연결을 확인하고 다시 시도해주세요.'));
        expect(exception.title, equals('네트워크 연결 없음'));
        expect(exception.errorType, equals(ExceptionTypes.connection));
        expect(exception.errorCode, equals(ExceptionCodes.noConnection));
        expect(exception.suggestedAction, equals('Wi-Fi 또는 모바일 데이터 연결을 확인해주세요.'));
        expect(exception.statusCode, isNull);
      });

      test('should have correct error code', () {
        final exception = NetworkException.noConnection();
        expect(exception.errorCode, equals(ExceptionCodes.noConnection));
      });

      test('should have correct error type', () {
        final exception = NetworkException.noConnection();
        expect(exception.errorType, equals(ExceptionTypes.connection));
      });
    });

    group('dnsResolutionFailed', () {
      test('should create DNS resolution failed exception', () {
        final exception = NetworkException.dnsResolutionFailed();

        expect(exception.message, equals('DNS resolution failed'));
        expect(exception.userMessage, equals('서버 주소를 찾을 수 없습니다.'));
        expect(exception.title, equals('서버 연결 실패'));
        expect(exception.errorType, equals(ExceptionTypes.dns));
        expect(exception.errorCode, equals(ExceptionCodes.dnsResolutionFailed));
        expect(exception.suggestedAction, equals('인터넷 연결을 확인하고 다시 시도해주세요.'));
        expect(exception.statusCode, isNull);
      });

      test('should have correct error code', () {
        final exception = NetworkException.dnsResolutionFailed();
        expect(exception.errorCode, equals(ExceptionCodes.dnsResolutionFailed));
      });

      test('should have correct error type', () {
        final exception = NetworkException.dnsResolutionFailed();
        expect(exception.errorType, equals(ExceptionTypes.dns));
      });
    });

    group('sslCertificateError', () {
      test('should create SSL certificate error exception', () {
        final exception = NetworkException.sslCertificateError();

        expect(exception.message, equals('SSL certificate error'));
        expect(exception.userMessage, equals('보안 연결에 실패했습니다.'));
        expect(exception.title, equals('보안 연결 오류'));
        expect(exception.errorType, equals(ExceptionTypes.ssl));
        expect(exception.errorCode, equals(ExceptionCodes.sslCertificateError));
        expect(exception.suggestedAction, equals('앱을 업데이트하거나 관리자에게 문의하세요.'));
        expect(exception.statusCode, isNull);
      });

      test('should have correct error code', () {
        final exception = NetworkException.sslCertificateError();
        expect(exception.errorCode, equals(ExceptionCodes.sslCertificateError));
      });

      test('should have correct error type', () {
        final exception = NetworkException.sslCertificateError();
        expect(exception.errorType, equals(ExceptionTypes.ssl));
      });
    });

    group('requestCancelled', () {
      test('should create request cancelled exception', () {
        final exception = NetworkException.requestCancelled();

        expect(exception.message, equals('Request cancelled'));
        expect(exception.userMessage, equals('요청이 취소되었습니다.'));
        expect(exception.title, equals('요청 취소'));
        expect(exception.errorType, equals(ExceptionTypes.requestResponse));
        expect(exception.errorCode, equals(ExceptionCodes.requestCancelled));
        expect(exception.suggestedAction, isNull);
        expect(exception.statusCode, isNull);
      });

      test('should have correct error code', () {
        final exception = NetworkException.requestCancelled();
        expect(exception.errorCode, equals(ExceptionCodes.requestCancelled));
      });

      test('should have correct error type', () {
        final exception = NetworkException.requestCancelled();
        expect(exception.errorType, equals(ExceptionTypes.requestResponse));
      });
    });

    group('badResponse', () {
      test('should create bad response exception', () {
        final exception = NetworkException.badResponse();

        expect(exception.message, equals('Bad response received'));
        expect(exception.userMessage, equals('서버에서 잘못된 응답을 받았습니다.'));
        expect(exception.title, equals('응답 오류'));
        expect(exception.errorType, equals(ExceptionTypes.requestResponse));
        expect(exception.errorCode, equals(ExceptionCodes.badResponse));
        expect(exception.suggestedAction, equals('잠시 후 다시 시도해주세요.'));
        expect(exception.statusCode, isNull);
      });

      test('should have correct error code', () {
        final exception = NetworkException.badResponse();
        expect(exception.errorCode, equals(ExceptionCodes.badResponse));
      });

      test('should have correct error type', () {
        final exception = NetworkException.badResponse();
        expect(exception.errorType, equals(ExceptionTypes.requestResponse));
      });
    });

    group('connectionError', () {
      test('should create connection error exception', () {
        final exception = NetworkException.connectionError();

        expect(exception.message, equals('Connection error occurred'));
        expect(exception.userMessage, equals('네트워크 연결에 오류가 발생했습니다.'));
        expect(exception.title, equals('연결 오류'));
        expect(exception.errorType, equals(ExceptionTypes.connection));
        expect(exception.errorCode, equals(ExceptionCodes.connectionError));
        expect(exception.suggestedAction, equals('네트워크 연결을 확인하고 다시 시도해주세요.'));
        expect(exception.statusCode, isNull);
      });

      test('should have correct error code', () {
        final exception = NetworkException.connectionError();
        expect(exception.errorCode, equals(ExceptionCodes.connectionError));
      });

      test('should have correct error type', () {
        final exception = NetworkException.connectionError();
        expect(exception.errorType, equals(ExceptionTypes.connection));
      });
    });

    group('securityConnectionFailed', () {
      test('should create security connection failed exception', () {
        final exception = NetworkException.securityConnectionFailed();

        expect(exception.message, equals('Security connection failed'));
        expect(exception.userMessage, equals('보안 연결을 설정할 수 없습니다.'));
        expect(exception.title, equals('보안 연결 실패'));
        expect(exception.errorType, equals(ExceptionTypes.security));
        expect(exception.errorCode, equals(ExceptionCodes.securityConnectionFailed));
        expect(exception.suggestedAction, equals('네트워크 보안 설정을 확인하세요.'));
        expect(exception.statusCode, isNull);
      });

      test('should have correct error code', () {
        final exception = NetworkException.securityConnectionFailed();
        expect(exception.errorCode, equals(ExceptionCodes.securityConnectionFailed));
      });

      test('should have correct error type', () {
        final exception = NetworkException.securityConnectionFailed();
        expect(exception.errorType, equals(ExceptionTypes.security));
      });
    });

    group('toString', () {
      test('should return formatted string representation', () {
        const exception = NetworkException(
          message: 'Test network error',
          userMessage: '네트워크 오류',
          title: '오류',
          errorType: ExceptionTypes.network,
        );

        final result = exception.toString();
        expect(result, contains('NetworkException'));
        expect(result, contains('Test network error'));
        expect(result, isNot(contains('status:'))); // statusCode is null
      });

      test('should include status code when available', () {
        const exception = NetworkException(
          message: 'Test network error',
          userMessage: '네트워크 오류',
          title: '오류',
          errorType: ExceptionTypes.network,
          statusCode: 500,
        );

        final result = exception.toString();
        expect(result, contains('NetworkException'));
        expect(result, contains('Test network error'));
        expect(result, contains('status: 500'));
      });

      test('should not include status code when null', () {
        const exception = NetworkException(
          message: 'Test network error',
          userMessage: '네트워크 오류',
          title: '오류',
          errorType: ExceptionTypes.network,
        );

        final result = exception.toString();
        expect(result, isNot(contains('status:')));
      });
    });

    group('ExceptionInterface implementation', () {
      test('should implement all required properties', () {
        const exception = NetworkException(
          message: 'Test network error',
          userMessage: '네트워크 오류',
          title: '오류',
          errorType: ExceptionTypes.network,
        );

        expect(exception.message, isA<String>());
        expect(exception.userMessage, isA<String>());
        expect(exception.title, isA<String>());
        expect(exception.errorType, isA<String>());
        expect(exception.errorCode, isA<String?>());
        expect(exception.suggestedAction, isA<String?>());
      });

      test('should return correct message', () {
        const exception = NetworkException(
          message: 'Test network error message',
          userMessage: '네트워크 오류',
          title: '오류',
          errorType: ExceptionTypes.network,
        );

        expect(exception.message, equals('Test network error message'));
      });

      test('should return correct userMessage', () {
        const exception = NetworkException(
          message: 'Test network error',
          userMessage: '네트워크 오류 메시지',
          title: '오류',
          errorType: ExceptionTypes.network,
        );

        expect(exception.userMessage, equals('네트워크 오류 메시지'));
      });

      test('should return correct title', () {
        const exception = NetworkException(
          message: 'Test network error',
          userMessage: '네트워크 오류',
          title: '네트워크 오류 제목',
          errorType: ExceptionTypes.network,
        );

        expect(exception.title, equals('네트워크 오류 제목'));
      });

      test('should return correct errorCode', () {
        const exception = NetworkException(
          message: 'Test network error',
          userMessage: '네트워크 오류',
          title: '오류',
          errorType: ExceptionTypes.network,
          errorCode: 'NET_001',
        );

        expect(exception.errorCode, equals('NET_001'));
      });

      test('should return correct errorType', () {
        const exception = NetworkException(
          message: 'Test network error',
          userMessage: '네트워크 오류',
          title: '오류',
          errorType: ExceptionTypes.connection,
        );

        expect(exception.errorType, equals(ExceptionTypes.connection));
      });

      test('should return correct suggestedAction', () {
        const exception = NetworkException(
          message: 'Test network error',
          userMessage: '네트워크 오류',
          title: '오류',
          errorType: ExceptionTypes.network,
          suggestedAction: '네트워크를 확인하세요.',
        );

        expect(exception.suggestedAction, equals('네트워크를 확인하세요.'));
      });
    });

    group('edge cases', () {
      test('should handle zero status code', () {
        const exception = NetworkException(
          message: 'Test network error',
          userMessage: '네트워크 오류',
          title: '오류',
          errorType: ExceptionTypes.network,
          statusCode: 0,
        );

        expect(exception.statusCode, equals(0));
        expect(exception.toString(), contains('status: 0'));
      });

      test('should handle negative status code', () {
        const exception = NetworkException(
          message: 'Test network error',
          userMessage: '네트워크 오류',
          title: '오류',
          errorType: ExceptionTypes.network,
          statusCode: -1,
        );

        expect(exception.statusCode, equals(-1));
        expect(exception.toString(), contains('status: -1'));
      });

      test('should handle empty message', () {
        const exception = NetworkException(
          message: '',
          userMessage: '네트워크 오류',
          title: '오류',
          errorType: ExceptionTypes.network,
        );

        expect(exception.message, equals(''));
      });

      test('should handle special characters in message', () {
        const exception = NetworkException(
          message: 'Error with special chars: !@#\$%^&*()',
          userMessage: '네트워크 오류',
          title: '오류',
          errorType: ExceptionTypes.network,
        );

        expect(exception.message, equals('Error with special chars: !@#\$%^&*()'));
      });
    });
  });
}
