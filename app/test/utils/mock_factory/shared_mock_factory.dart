import 'package:mocktail/mocktail.dart';

import 'package:tomo_place/shared/infrastructure/network/base_client.dart';
import 'package:tomo_place/shared/infrastructure/storage/access_token_memory_store.dart';
import 'package:tomo_place/shared/infrastructure/storage/token_storage_service.dart';

/// Shared 인프라 Mock 클래스들
class MockBaseClient extends Mock implements BaseClient {}

class MockAccessTokenMemoryStoreInterface extends Mock implements AccessTokenMemoryStoreInterface {}

class MockTokenStorageInterface extends Mock implements TokenStorageInterface {}

/// Shared 인프라 Mock 객체 생성을 위한 팩토리 클래스
class SharedMockFactory {
  SharedMockFactory._();

  // Network Mocks
  static MockBaseClient createBaseClient() => MockBaseClient();

  // Storage Mocks
  static MockAccessTokenMemoryStoreInterface createAccessTokenMemoryStore() => MockAccessTokenMemoryStoreInterface();
  static MockTokenStorageInterface createTokenStorage() => MockTokenStorageInterface();
}

