class CategoryModel {
  final String id;
  final String label;
  final String iconPath;
  final bool isSelected;

  const CategoryModel({
    required this.id,
    required this.label,
    required this.iconPath,
    this.isSelected = false,
  });

  CategoryModel copyWith({
    String? id,
    String? label,
    String? iconPath,
    bool? isSelected,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      label: label ?? this.label,
      iconPath: iconPath ?? this.iconPath,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryModel &&
        other.id == id &&
        other.label == label &&
        other.iconPath == iconPath &&
        other.isSelected == isSelected;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        label.hashCode ^
        iconPath.hashCode ^
        isSelected.hashCode;
  }

  @override
  String toString() {
    return 'CategoryModel(id: $id, label: $label, iconPath: $iconPath, isSelected: $isSelected)';
  }
}
