/// Hierarchical business sector / category model.
class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.slug,
    this.parentId,
    this.iconName,
    this.displayOrder = 0,
    this.opportunitiesCount = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      nameAr: json['title_ar'] as String? ?? json['name_ar'] as String? ?? '',
      nameEn: json['title_en'] as String? ?? json['name_en'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      parentId: json['parent_id'] as String?,
      iconName: json['icon_name'] as String?,
      displayOrder: json['display_order'] as int? ?? 0,
      opportunitiesCount: json['opportunities_count'] as int? ?? 0,
    );
  }

  final String id;
  final String nameAr;
  final String nameEn;
  final String slug;
  final String? parentId;
  final String? iconName;
  final int displayOrder;
  final int opportunitiesCount;

  String localizedName(String locale) =>
      locale == 'en' && nameEn.isNotEmpty ? nameEn : nameAr;
}
