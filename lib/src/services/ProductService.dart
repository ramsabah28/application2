import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/ProductModel.dart';

class ProductService {
  static Future<List<ProductModel>> loadProductData() async {
    final String response = await rootBundle.loadString('lib/src/data/product_moc.json');
    final List<dynamic> data = await json.decode(response);
    return data.map((item) => ProductModel.fromJson(item)).toList();
  }
}
