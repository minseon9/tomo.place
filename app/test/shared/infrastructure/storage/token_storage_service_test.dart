import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tomo_place/shared/infrastructure/storage/token_storage_service.dart';

class _MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  group('TokenStorageService', () {
    late _MockFlutterSecureStorage storage;
    late TokenStorageService service;

    test('기본 생성자를 통해 FlutterSecureStorage를 사용할 수 있다', () {
      final defaultService = TokenStorageService();
      expect(defaultService, isA<TokenStorageInterface>());
    });

    setUpAll(() {
      registerFallbackValue(const AndroidOptions());
      registerFallbackValue(const IOSOptions());
      registerFallbackValue(const LinuxOptions());
      registerFallbackValue(const WebOptions());
      registerFallbackValue(const WindowsOptions());
      registerFallbackValue(const MacOsOptions());
    });

    setUp(() {
      storage = _MockFlutterSecureStorage();
      service = TokenStorageService(storage: storage);
    });

    group('saveRefreshToken', () {
      test('refresh token과 만료 시간을 저장한다', () async {
        when(() => storage.write(key: any(named: 'key'), value: any(named: 'value')))
            .thenAnswer((_) async {});

        final expiresAt = DateTime(2030, 1, 1, 12, 34, 56, 789, 123);

        await service.saveRefreshToken(
          refreshToken: 'token',
          refreshTokenExpiresAt: expiresAt,
        );

        verify(() => storage.write(key: 'refresh_token', value: 'token')).called(1);
        verify(
          () => storage.write(
            key: 'refresh_token_expiry',
            value: expiresAt.toIso8601String(),
          ),
        ).called(1);
      });
    });

    group('getRefreshToken', () {
      test('저장된 토큰을 반환한다', () async {
        when(() => storage.read(key: any(named: 'key'))).thenAnswer((_) async => 'token');

        final result = await service.getRefreshToken();

        expect(result, 'token');
        verify(() => storage.read(key: 'refresh_token')).called(1);
      });

      test('값이 없으면 null을 반환한다', () async {
        when(() => storage.read(key: any(named: 'key'))).thenAnswer((_) async => null);

        final result = await service.getRefreshToken();

        expect(result, isNull);
        verify(() => storage.read(key: 'refresh_token')).called(1);
      });
    });

    group('getRefreshTokenExpiry', () {
      test('저장된 만료 시간을 파싱해 반환한다', () async {
        final iso = DateTime(2030, 1, 1).toIso8601String();
        when(() => storage.read(key: any(named: 'key'))).thenAnswer((_) async => iso);

        final result = await service.getRefreshTokenExpiry();

        expect(result, DateTime.parse(iso));
        verify(() => storage.read(key: 'refresh_token_expiry')).called(1);
      });

      test('값이 없으면 null을 반환한다', () async {
        when(() => storage.read(key: any(named: 'key'))).thenAnswer((_) async => null);

        final result = await service.getRefreshTokenExpiry();

        expect(result, isNull);
        verify(() => storage.read(key: 'refresh_token_expiry')).called(1);
      });
    });

    group('clearTokens', () {
      test('토큰과 만료 시간을 모두 삭제한다', () async {
        when(() => storage.delete(key: any(named: 'key'))).thenAnswer((_) async {});

        await service.clearTokens();

        verify(() => storage.delete(key: 'refresh_token')).called(1);
        verify(() => storage.delete(key: 'refresh_token_expiry')).called(1);
      });
    });
  });
}

