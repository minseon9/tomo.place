import 'package:faker/faker.dart';

/// 사용자 관련 테스트 데이터 생성기
class FakeUserGenerator {
  FakeUserGenerator._();

  /// 기본 사용자 데이터 생성
  static Map<String, dynamic> createUserData() {
    return {
      'id': faker.guid.guid(),
      'email': faker.internet.email(),
      'name': faker.person.name(),
      'profileImage': faker.image.loremPicsum(),
    };
  }

  /// 커스텀 이메일로 사용자 데이터 생성
  static Map<String, dynamic> createUserDataWithEmail(String email) {
    return {
      'id': faker.guid.guid(),
      'email': email,
      'name': faker.person.name(),
      'profileImage': faker.image.loremPicsum(),
    };
  }

  /// 커스텀 이름으로 사용자 데이터 생성
  static Map<String, dynamic> createUserDataWithName(String name) {
    return {
      'id': faker.guid.guid(),
      'email': faker.internet.email(),
      'name': name,
      'profileImage': faker.image.loremPicsum(),
    };
  }

  /// 커스텀 ID로 사용자 데이터 생성
  static Map<String, dynamic> createUserDataWithId(String id) {
    return {
      'id': id,
      'email': faker.internet.email(),
      'name': faker.person.name(),
      'profileImage': faker.image.loremPicsum(),
    };
  }

  /// 프로필 이미지가 없는 사용자 데이터 생성
  static Map<String, dynamic> createUserDataWithoutProfileImage() {
    return {
      'id': faker.guid.guid(),
      'email': faker.internet.email(),
      'name': faker.person.name(),
      'profileImage': null,
    };
  }

  /// 최소한의 사용자 데이터 생성 (필수 필드만)
  static Map<String, dynamic> createMinimalUserData() {
    return {
      'id': faker.guid.guid(),
      'email': faker.internet.email(),
    };
  }

  /// 확장된 사용자 데이터 생성 (추가 필드 포함)
  static Map<String, dynamic> createExtendedUserData() {
    return {
      'id': faker.guid.guid(),
      'email': faker.internet.email(),
      'name': faker.person.name(),
      'profileImage': faker.image.loremPicsum(),
      'phoneNumber': faker.phoneNumber.us(),
      'dateOfBirth': faker.date.dateTime(minYear: 1950, maxYear: 2005).toIso8601String(),
      'address': faker.address.streetAddress(),
      'city': faker.address.city(),
      'country': faker.address.country(),
    };
  }
}

