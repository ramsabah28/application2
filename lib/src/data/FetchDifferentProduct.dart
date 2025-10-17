import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Firestore reference
  CollectionReference productsRef =
  FirebaseFirestore.instance.collection('product');

  var uuidGenerator = Uuid();
  var random = Random();

  // Some example categories and brands
  final categories = [
    "tech",
    "fashion",
    "home",
    "sports",
    "toys",
    "beauty",
    "garden",
    "books",
    "automotive",
    "office"
  ];

  final brands = [
    "Apple",
    "Samsung",
    "Sony",
    "LG",
    "Nike",
    "Adidas",
    "Dell",
    "HP",
    "Lenovo",
    "Philips"
  ];

  // Generate and upload 1000 products
  for (var i = 0; i < 1000; i++) {
    try {
      final uuid = uuidGenerator.v4();

      // Randomized values
      final brand = brands[random.nextInt(brands.length)];
      final category = categories[random.nextInt(categories.length)];
      final price = (50 + random.nextInt(950)) + random.nextDouble(); // 50–1000
      final count = 1 + random.nextInt(20);

      // Create product map
      final product = {
        "uuid": uuid,
        "name": "$brand Product $i",
        "count": count,
        "description":
        "This is a high-quality $brand product from the $category category. Built to deliver performance and durability.",
        "midDescription":
        "The $brand Product $i offers reliable performance, designed for daily use with a focus on quality and comfort.",
        "longDescription":
        "The $brand Product $i is engineered to meet the highest standards in the $category market. Crafted with attention to detail and equipped with advanced features, it ensures optimal performance, longevity, and user satisfaction.",
        "category": category,
        "brand": brand,
        "price": double.parse(price.toStringAsFixed(2)),
        "imageUrl":
        "https://picsum.photos/seed/$i/600/600", // unique random image
        "images": List.generate(
          3,
              (j) => {
            "url": "https://picsum.photos/seed/${i}_$j/600/600",
            "color": ["Red", "Blue", "Green", "Black", "White"][j % 5],
          },
        ),
      };

      // Upload to Firestore with custom UUID as document ID
      await productsRef.doc(uuid).set(product);

      print('✅ Added product #$i: ${product['name']}');
    } catch (e) {
      print('❌ Failed to add product #$i: $e');
    }
  }

  print('🎉 All 1000 products uploaded successfully!');
}
