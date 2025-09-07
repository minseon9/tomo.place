import 'package:flutter_test/flutter_test.dart';

import 'package:app/shared/exception_handler/exceptions/server_exception.dart';
import 'package:app/shared/exception_handler/models/exception_codes.dart';
import 'package:app/shared/exception_handler/models/exception_types.dart';

void main() {
  group('ServerException', () {
    group('constructor', () {
      test('should create instance with all required parameters', () {
        const exception = ServerException(
          message: 'Test server error',
          userMessage: '서버 오류가 발생했습니다.',
          title: '서버 오류',
          errorType: ExceptionTypes.serverError,
          statusCode: 500,
          errorCode: 'TEST_001',
          suggestedAction: '잠시 후 다시 시도해주세요.',
        );

        expect(exception.message, equals('Test server error'));
        expect(exception.userMessage, equals('서버 오류가 발생했습니다.'));
        expect(exception.title, equals('서버 오류'));
        expect(exception.errorType, equals(ExceptionTypes.serverError));
        expect(exception.statusCode, equals(500));
        expect(exception.errorCode, equals('TEST_001'));
        expect(exception.suggestedAction, equals('잠시 후 다시 시도해주세요.'));
      });

      test('should create instance with optional parameters', () {
        const exception = ServerException(
          message: 'Test server error',
          userMessage: '서버 오류가 발생했습니다.',
          title: '서버 오류',
          errorType: ExceptionTypes.serverError,
          statusCode: 500,
        );

        expect(exception.message, equals('Test server error'));
        expect(exception.userMessage, equals('서버 오류가 발생했습니다.'));
        expect(exception.title, equals('서버 오류'));
        expect(exception.errorType, equals(ExceptionTypes.serverError));
        expect(exception.statusCode, equals(500));
        expect(exception.errorCode, isNull);
        expect(exception.suggestedAction, isNull);
      });
    });

    group('badRequest', () {
      test('should create bad request exception', () {
        final exception = ServerException.badRequest(message: 'Invalid request data');

        expect(exception.message, equals('Bad request: Invalid request data'));
        expect(exception.userMessage, equals('잘못된 요청입니다. 다시 시도해주세요.'));
        expect(exception.title, equals('잘못된 요청'));
        expect(exception.errorType, equals(ExceptionTypes.clientError));
        expect(exception.statusCode, equals(400));
        expect(exception.errorCode, equals(ExceptionCodes.badRequest));
        expect(exception.suggestedAction, equals('입력 정보를 확인하고 다시 시도해주세요.'));
      });

      test('should have correct status code', () {
        final exception = ServerException.badRequest(message: 'Test');
        expect(exception.statusCode, equals(400));
      });

      test('should have correct error code', () {
        final exception = ServerException.badRequest(message: 'Test');
        expect(exception.errorCode, equals(ExceptionCodes.badRequest));
      });

      test('should have correct error type', () {
        final exception = ServerException.badRequest(message: 'Test');
        expect(exception.errorType, equals(ExceptionTypes.clientError));
      });
    });

    group('unauthorized', () {
      test('should create unauthorized exception', () {
        final exception = ServerException.unauthorized(message: 'Token expired');

        expect(exception.message, equals('Unauthorized: Token expired'));
        expect(exception.userMessage, equals('인증이 필요합니다. 다시 로그인해주세요.'));
        expect(exception.title, equals('인증 필요'));
        expect(exception.errorType, equals(ExceptionTypes.authentication));
        expect(exception.statusCode, equals(401));
        expect(exception.errorCode, equals(ExceptionCodes.unauthorized));
        expect(exception.suggestedAction, equals('다시 로그인해주세요.'));
      });

      test('should have correct status code', () {
        final exception = ServerException.unauthorized(message: 'Test');
        expect(exception.statusCode, equals(401));
      });

      test('should have correct error code', () {
        final exception = ServerException.unauthorized(message: 'Test');
        expect(exception.errorCode, equals(ExceptionCodes.unauthorized));
      });

      test('should have correct error type', () {
        final exception = ServerException.unauthorized(message: 'Test');
        expect(exception.errorType, equals(ExceptionTypes.authentication));
      });
    });

    group('forbidden', () {
      test('should create forbidden exception', () {
        final exception = ServerException.forbidden(message: 'Access denied');

        expect(exception.message, equals('Forbidden: Access denied'));
        expect(exception.userMessage, equals('접근 권한이 없습니다.'));
        expect(exception.title, equals('접근 거부'));
        expect(exception.errorType, equals(ExceptionTypes.authorization));
        expect(exception.statusCode, equals(403));
        expect(exception.errorCode, equals(ExceptionCodes.forbidden));
        expect(exception.suggestedAction, equals('관리자에게 문의하세요.'));
      });

      test('should have correct status code', () {
        final exception = ServerException.forbidden(message: 'Test');
        expect(exception.statusCode, equals(403));
      });

      test('should have correct error code', () {
        final exception = ServerException.forbidden(message: 'Test');
        expect(exception.errorCode, equals(ExceptionCodes.forbidden));
      });

      test('should have correct error type', () {
        final exception = ServerException.forbidden(message: 'Test');
        expect(exception.errorType, equals(ExceptionTypes.authorization));
      });
    });

    group('notFound', () {
      test('should create not found exception', () {
        final exception = ServerException.notFound(message: 'Resource not found');

        expect(exception.message, equals('Not found: Resource not found'));
        expect(exception.userMessage, equals('요청한 페이지를 찾을 수 없습니다.'));
        expect(exception.title, equals('페이지 없음'));
        expect(exception.errorType, equals(ExceptionTypes.resource));
        expect(exception.statusCode, equals(404));
        expect(exception.errorCode, equals(ExceptionCodes.notFound));
        expect(exception.suggestedAction, equals('URL을 확인하고 다시 시도해주세요.'));
      });

      test('should have correct status code', () {
        final exception = ServerException.notFound(message: 'Test');
        expect(exception.statusCode, equals(404));
      });

      test('should have correct error code', () {
        final exception = ServerException.notFound(message: 'Test');
        expect(exception.errorCode, equals(ExceptionCodes.notFound));
      });

      test('should have correct error type', () {
        final exception = ServerException.notFound(message: 'Test');
        expect(exception.errorType, equals(ExceptionTypes.resource));
      });
    });

    group('internalServerError', () {
      test('should create internal server error exception', () {
        final exception = ServerException.internalServerError(message: 'Database connection failed');

        expect(exception.message, equals('Internal server error: Database connection failed'));
        expect(exception.userMessage, equals('서버 내부 오류가 발생했습니다. 잠시 후 다시 시도해주세요.'));
        expect(exception.title, equals('서버 오류'));
        expect(exception.errorType, equals(ExceptionTypes.serverError));
        expect(exception.statusCode, equals(500));
        expect(exception.errorCode, equals(ExceptionCodes.internalServerError));
        expect(exception.suggestedAction, equals('잠시 후 다시 시도해주세요.'));
      });

      test('should have correct status code', () {
        final exception = ServerException.internalServerError(message: 'Test');
        expect(exception.statusCode, equals(500));
      });

      test('should have correct error code', () {
        final exception = ServerException.internalServerError(message: 'Test');
        expect(exception.errorCode, equals(ExceptionCodes.internalServerError));
      });

      test('should have correct error type', () {
        final exception = ServerException.internalServerError(message: 'Test');
        expect(exception.errorType, equals(ExceptionTypes.serverError));
      });
    });

    group('badGateway', () {
      test('should create bad gateway exception', () {
        final exception = ServerException.badGateway(message: 'Upstream server error');

        expect(exception.message, equals('Bad gateway: Upstream server error'));
        expect(exception.userMessage, equals('서버 연결 오류가 발생했습니다. 잠시 후 다시 시도해주세요.'));
        expect(exception.title, equals('서버 연결 오류'));
        expect(exception.errorType, equals(ExceptionTypes.serverError));
        expect(exception.statusCode, equals(502));
        expect(exception.errorCode, equals(ExceptionCodes.badGateway));
        expect(exception.suggestedAction, equals('잠시 후 다시 시도해주세요.'));
      });

      test('should have correct status code', () {
        final exception = ServerException.badGateway(message: 'Test');
        expect(exception.statusCode, equals(502));
      });

      test('should have correct error code', () {
        final exception = ServerException.badGateway(message: 'Test');
        expect(exception.errorCode, equals(ExceptionCodes.badGateway));
      });

      test('should have correct error type', () {
        final exception = ServerException.badGateway(message: 'Test');
        expect(exception.errorType, equals(ExceptionTypes.serverError));
      });
    });

    group('serviceUnavailable', () {
      test('should create service unavailable exception', () {
        final exception = ServerException.serviceUnavailable(message: 'Maintenance in progress');

        expect(exception.message, equals('Service unavailable: Maintenance in progress'));
        expect(exception.userMessage, equals('서비스를 일시적으로 사용할 수 없습니다. 잠시 후 다시 시도해주세요.'));
        expect(exception.title, equals('서비스 일시 중단'));
        expect(exception.errorType, equals(ExceptionTypes.serverError));
        expect(exception.statusCode, equals(503));
        expect(exception.errorCode, equals(ExceptionCodes.serviceUnavailable));
        expect(exception.suggestedAction, equals('잠시 후 다시 시도해주세요.'));
      });

      test('should have correct status code', () {
        final exception = ServerException.serviceUnavailable(message: 'Test');
        expect(exception.statusCode, equals(503));
      });

      test('should have correct error code', () {
        final exception = ServerException.serviceUnavailable(message: 'Test');
        expect(exception.errorCode, equals(ExceptionCodes.serviceUnavailable));
      });

      test('should have correct error type', () {
        final exception = ServerException.serviceUnavailable(message: 'Test');
        expect(exception.errorType, equals(ExceptionTypes.serverError));
      });
    });

    group('fromStatusCode', () {
      group('client errors (4xx)', () {
        test('should handle 400 status code', () {
          final exception = ServerException.fromStatusCode(
            statusCode: 400,
            message: 'Bad request',
          );

          expect(exception.statusCode, equals(400));
          expect(exception.errorType, equals(ExceptionTypes.clientError));
          expect(exception.title, equals('잘못된 요청'));
          expect(exception.userMessage, equals('잘못된 요청입니다. 다시 시도해주세요.'));
          expect(exception.errorCode, equals(ExceptionCodes.badRequest));
          expect(exception.suggestedAction, equals('입력 정보를 확인하고 다시 시도해주세요.'));
        });

        test('should handle 401 status code', () {
          final exception = ServerException.fromStatusCode(
            statusCode: 401,
            message: 'Unauthorized',
          );

          expect(exception.statusCode, equals(401));
          expect(exception.errorType, equals(ExceptionTypes.clientError));
          expect(exception.title, equals('인증 필요'));
          expect(exception.userMessage, equals('인증이 필요합니다. 다시 로그인해주세요.'));
          expect(exception.errorCode, equals(ExceptionCodes.unauthorized));
          expect(exception.suggestedAction, equals('다시 로그인해주세요.'));
        });

        test('should handle 403 status code', () {
          final exception = ServerException.fromStatusCode(
            statusCode: 403,
            message: 'Forbidden',
          );

          expect(exception.statusCode, equals(403));
          expect(exception.errorType, equals(ExceptionTypes.clientError));
          expect(exception.title, equals('접근 거부'));
          expect(exception.userMessage, equals('접근 권한이 없습니다.'));
          expect(exception.errorCode, equals(ExceptionCodes.forbidden));
          expect(exception.suggestedAction, equals('관리자에게 문의하세요.'));
        });

        test('should handle 404 status code', () {
          final exception = ServerException.fromStatusCode(
            statusCode: 404,
            message: 'Not found',
          );

          expect(exception.statusCode, equals(404));
          expect(exception.errorType, equals(ExceptionTypes.clientError));
          expect(exception.title, equals('페이지 없음'));
          expect(exception.userMessage, equals('요청한 페이지를 찾을 수 없습니다.'));
          expect(exception.errorCode, equals(ExceptionCodes.notFound));
          expect(exception.suggestedAction, equals('URL을 확인하고 다시 시도해주세요.'));
        });

        test('should handle other 4xx status codes', () {
          final exception = ServerException.fromStatusCode(
            statusCode: 422,
            message: 'Unprocessable entity',
          );

          expect(exception.statusCode, equals(422));
          expect(exception.errorType, equals(ExceptionTypes.clientError));
          expect(exception.title, equals('클라이언트 오류'));
          expect(exception.userMessage, equals('요청 처리 중 오류가 발생했습니다.'));
          expect(exception.errorCode, isNull);
          expect(exception.suggestedAction, equals('입력 정보를 확인하고 다시 시도해주세요.'));
        });
      });

      group('server errors (5xx)', () {
        test('should handle 500 status code', () {
          final exception = ServerException.fromStatusCode(
            statusCode: 500,
            message: 'Internal server error',
          );

          expect(exception.statusCode, equals(500));
          expect(exception.errorType, equals(ExceptionTypes.serverError));
          expect(exception.title, equals('서버 오류'));
          expect(exception.userMessage, equals('서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.'));
          expect(exception.errorCode, isNull);
          expect(exception.suggestedAction, equals('잠시 후 다시 시도해주세요.'));
        });

        test('should handle 502 status code', () {
          final exception = ServerException.fromStatusCode(
            statusCode: 502,
            message: 'Bad gateway',
          );

          expect(exception.statusCode, equals(502));
          expect(exception.errorType, equals(ExceptionTypes.serverError));
          expect(exception.title, equals('서버 오류'));
          expect(exception.userMessage, equals('서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.'));
          expect(exception.errorCode, isNull);
          expect(exception.suggestedAction, equals('잠시 후 다시 시도해주세요.'));
        });

        test('should handle 503 status code', () {
          final exception = ServerException.fromStatusCode(
            statusCode: 503,
            message: 'Service unavailable',
          );

          expect(exception.statusCode, equals(503));
          expect(exception.errorType, equals(ExceptionTypes.serverError));
          expect(exception.title, equals('서버 오류'));
          expect(exception.userMessage, equals('서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.'));
          expect(exception.errorCode, isNull);
          expect(exception.suggestedAction, equals('잠시 후 다시 시도해주세요.'));
        });

        test('should handle other 5xx status codes', () {
          final exception = ServerException.fromStatusCode(
            statusCode: 504,
            message: 'Gateway timeout',
          );

          expect(exception.statusCode, equals(504));
          expect(exception.errorType, equals(ExceptionTypes.serverError));
          expect(exception.title, equals('서버 오류'));
          expect(exception.userMessage, equals('서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.'));
          expect(exception.errorCode, isNull);
          expect(exception.suggestedAction, equals('잠시 후 다시 시도해주세요.'));
        });
      });

      group('other status codes', () {
        test('should handle unknown status codes', () {
          final exception = ServerException.fromStatusCode(
            statusCode: 999,
            message: 'Unknown error',
          );

          expect(exception.statusCode, equals(999));
          expect(exception.errorType, equals(ExceptionTypes.serverError));
          expect(exception.title, equals('서버 오류'));
          expect(exception.userMessage, equals('서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.'));
          expect(exception.errorCode, isNull);
          expect(exception.suggestedAction, equals('잠시 후 다시 시도해주세요.'));
        });
      });
    });

    group('toString', () {
      test('should return formatted string representation', () {
        const exception = ServerException(
          message: 'Test server error',
          userMessage: '서버 오류',
          title: '오류',
          errorType: ExceptionTypes.serverError,
          statusCode: 500,
        );

        final result = exception.toString();
        expect(result, contains('ServerException'));
        expect(result, contains('statusCode: 500'));
        expect(result, contains('Test server error'));
      });

      test('should include status code and message', () {
        const exception = ServerException(
          message: 'Database connection failed',
          userMessage: '서버 오류',
          title: '오류',
          errorType: ExceptionTypes.serverError,
          statusCode: 500,
        );

        final result = exception.toString();
        expect(result, contains('statusCode: 500'));
        expect(result, contains('Database connection failed'));
      });
    });

    group('ExceptionInterface implementation', () {
      test('should implement all required properties', () {
        const exception = ServerException(
          message: 'Test server error',
          userMessage: '서버 오류',
          title: '오류',
          errorType: ExceptionTypes.serverError,
          statusCode: 500,
        );

        expect(exception.message, isA<String>());
        expect(exception.userMessage, isA<String>());
        expect(exception.title, isA<String>());
        expect(exception.errorType, isA<String>());
        expect(exception.errorCode, isA<String?>());
        expect(exception.suggestedAction, isA<String?>());
      });

      test('should return correct message', () {
        const exception = ServerException(
          message: 'Test server error message',
          userMessage: '서버 오류',
          title: '오류',
          errorType: ExceptionTypes.serverError,
          statusCode: 500,
        );

        expect(exception.message, equals('Test server error message'));
      });

      test('should return correct userMessage', () {
        const exception = ServerException(
          message: 'Test server error',
          userMessage: '서버 오류 메시지',
          title: '오류',
          errorType: ExceptionTypes.serverError,
          statusCode: 500,
        );

        expect(exception.userMessage, equals('서버 오류 메시지'));
      });

      test('should return correct title', () {
        const exception = ServerException(
          message: 'Test server error',
          userMessage: '서버 오류',
          title: '서버 오류 제목',
          errorType: ExceptionTypes.serverError,
          statusCode: 500,
        );

        expect(exception.title, equals('서버 오류 제목'));
      });

      test('should return correct errorCode', () {
        const exception = ServerException(
          message: 'Test server error',
          userMessage: '서버 오류',
          title: '오류',
          errorType: ExceptionTypes.serverError,
          statusCode: 500,
          errorCode: 'SRV_500',
        );

        expect(exception.errorCode, equals('SRV_500'));
      });

      test('should return correct errorType', () {
        const exception = ServerException(
          message: 'Test server error',
          userMessage: '서버 오류',
          title: '오류',
          errorType: ExceptionTypes.clientError,
          statusCode: 400,
        );

        expect(exception.errorType, equals(ExceptionTypes.clientError));
      });

      test('should return correct suggestedAction', () {
        const exception = ServerException(
          message: 'Test server error',
          userMessage: '서버 오류',
          title: '오류',
          errorType: ExceptionTypes.serverError,
          statusCode: 500,
          suggestedAction: '잠시 후 다시 시도하세요.',
        );

        expect(exception.suggestedAction, equals('잠시 후 다시 시도하세요.'));
      });
    });

    group('edge cases', () {
      test('should handle zero status code', () {
        const exception = ServerException(
          message: 'Test server error',
          userMessage: '서버 오류',
          title: '오류',
          errorType: ExceptionTypes.serverError,
          statusCode: 0,
        );

        expect(exception.statusCode, equals(0));
      });

      test('should handle negative status code', () {
        const exception = ServerException(
          message: 'Test server error',
          userMessage: '서버 오류',
          title: '오류',
          errorType: ExceptionTypes.serverError,
          statusCode: -1,
        );

        expect(exception.statusCode, equals(-1));
      });

      test('should handle empty message', () {
        const exception = ServerException(
          message: '',
          userMessage: '서버 오류',
          title: '오류',
          errorType: ExceptionTypes.serverError,
          statusCode: 500,
        );

        expect(exception.message, equals(''));
      });

      test('should handle special characters in message', () {
        const exception = ServerException(
          message: 'Error with special chars: !@#\$%^&*()',
          userMessage: '서버 오류',
          title: '오류',
          errorType: ExceptionTypes.serverError,
          statusCode: 500,
        );

        expect(exception.message, equals('Error with special chars: !@#\$%^&*()'));
      });
    });
  });
}
