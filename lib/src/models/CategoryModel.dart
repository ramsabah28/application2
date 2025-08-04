import 'dart:convert';
import 'package:flutter/services.dart';

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

Future<List<CategoryModel>> loadMocsCategory() async {

  final String jsonString = await rootBundle.loadString('assets/mock/mock_categories.json');
  final List<dynamic> jsonData = json.decode(jsonString);

  return jsonData.map((item) => CategoryModel.fromJson(item)).toList();

}
