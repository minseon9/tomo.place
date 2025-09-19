import '../entities/category_data.dart';
import '../entities/category_model.dart';

/// 검색 카테고리를 가져오는 Use Case
class GetSearchCategoriesUseCase {
  const GetSearchCategoriesUseCase();

  /// 검색에 사용할 카테고리 목록을 가져옵니다
  /// 
  /// Returns: 검색 카테고리 목록
  List<CategoryModel> execute() {
    return CategoryData.defaultCategories;
  }
}
