import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ProductModel.dart';

class ProductService {
  static Future<List<ProductModel>> loadProductData() async {
    try {
      CollectionReference products = FirebaseFirestore.instance.collection(
        'product',
      );
      QuerySnapshot querySnapshot = await products.get();

      List<ProductModel> productList = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        print("###_  $data ");
        return ProductModel.fromJson(data);
      }).toList();

      for (var p in productList) {
        print("Fetched product: ${p.name}, price: ${p.price}");
      }

      return productList;
    } catch (e) {
      print("Error fetching products from Firestore: $e");
      return [];
    }
  }

  static Future<ProductModel> loadProduct(String uuid) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('product').doc(uuid).get();
      if (!doc.exists) {
        throw Exception("Product with uuid $uuid not found");
      }
      final data = doc.data() as Map<String, dynamic>;
      return ProductModel.fromJson(data);
    } catch (e) {
      throw Exception("Error fetching product with uuid $uuid: $e");
    }
  }
}
