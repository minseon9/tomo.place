import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'get_search_categories_usecase.dart';


final getSearchCategoriesUseCaseProvider = Provider<GetSearchCategoriesUseCase>((ref) {
  return const GetSearchCategoriesUseCase();
});
