import 'category_model.dart';

class CategoryData {
  static const List<CategoryModel> defaultCategories = [
    CategoryModel(
      id: 'restaurant',
      label: '음식점',
      iconPath: 'assets/icons/restaurant_icon.svg',
    ),
    CategoryModel(
      id: 'cafe',
      label: '카페',
      iconPath: 'assets/icons/cafe_icon.svg',
    ),
    CategoryModel(
      id: 'lodging',
      label: '숙박',
      iconPath: 'assets/icons/lodging_icon.svg',
    ),
    CategoryModel(
      id: 'natural_feature',
      label: '자연명소',
      iconPath: 'assets/icons/natural_feature_icon.svg',
    ),
    CategoryModel(
      id: 'park',
      label: '공원',
      iconPath: 'assets/icons/park_icon.svg',
    ),
    CategoryModel(
      id: 'beach',
      label: '해변',
      iconPath: 'assets/icons/beach_icon.svg',
    ),
    CategoryModel(
      id: 'campground',
      label: '캠핑장',
      iconPath: 'assets/icons/campground_icon.svg',
    ),
  ];
}
