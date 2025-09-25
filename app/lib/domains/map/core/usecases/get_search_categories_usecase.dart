import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../entities/category_data.dart';
import '../entities/category_model.dart';

class GetSearchCategoriesUseCase {
  const GetSearchCategoriesUseCase();

  List<CategoryModel> execute() {
    return CategoryData.defaultCategories;
  }
}

final getSearchCategoriesUseCaseProvider = Provider<GetSearchCategoriesUseCase>((ref) {
  return const GetSearchCategoriesUseCase();
});
