import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/usecases/get_search_categories_usecase.dart';

/// Map UseCase Provider들
/// 
/// Map 도메인의 UseCase들을 Provider로 제공하여
/// 의존성 주입과 테스트 용이성을 확보합니다.

/// Get Search Categories UseCase Provider
final getSearchCategoriesUseCaseProvider = Provider<GetSearchCategoriesUseCase>((ref) {
  return const GetSearchCategoriesUseCase();
});
