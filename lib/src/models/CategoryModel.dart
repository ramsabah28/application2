
class CategoryModel {
  final String name;
  final String description;
  final String imageUrl;

  const CategoryModel({
    required this.name,
    required this.description,
    required this.imageUrl,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
    );
  }
}

