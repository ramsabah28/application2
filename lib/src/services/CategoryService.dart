import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/CategoryModel.dart';

class CategoryService {
  static Future<List<CategoryModel>> loadCategories() async {
    try {
      final String response = await rootBundle.loadString('lib/src/data/category_Moc_.json');
      final List<dynamic> data = json.decode(response);
      
      return data.map<CategoryModel>((item) {
        return CategoryModel.fromJson(item);
      }).toList();
    } catch (e) {
      print('Error loading categories: $e');
      return [];
    }
  }
} 