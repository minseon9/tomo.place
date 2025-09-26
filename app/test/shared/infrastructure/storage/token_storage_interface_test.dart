import 'package:flutter_test/flutter_test.dart';
import 'package:tomo_place/shared/infrastructure/storage/token_storage_service.dart';

void main() {
  test('TokenStorageService implements TokenStorageInterface', () {
    final service = TokenStorageService();
    expect(service, isA<TokenStorageInterface>());
  });
}

