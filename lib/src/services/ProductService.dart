import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/ProductModel.dart';

class ProductService {
  static Future<List<ProductModel>> loadProductData() async {
    final String response =
    await rootBundle.loadString('lib/src/data/product_moc_extend.json');
    final List<dynamic> data = json.decode(response);
    return data.map((item) => ProductModel.fromJson(item)).toList();
  }
}
