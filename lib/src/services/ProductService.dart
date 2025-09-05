import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/ProductModel.dart';

class ProductService {
  static Future<List<ProductModel>> loadProductData() async {
    final String response =
    await rootBundle.loadString('lib/src/data/product_moc.json');
    final List<dynamic> data = json.decode(response);
    return data.map((item) => ProductModel.fromJson(item)).toList();
  }

  static Future<ProductModel> loadProduct(String uuid) async {
    final String response =
    await rootBundle.loadString('lib/src/data/product_moc.json');
    final List<dynamic> data = json.decode(response);

    try {
      final productJson =
      data.firstWhere((item) => item['uuid'] == uuid, orElse: () => null);

      if (productJson == null) {
        throw Exception("Product with uuid $uuid not found");
      }

      return ProductModel.fromJson(productJson);
    } catch (e) {
      throw Exception("Error loading product: $e");
    }
  }


}
