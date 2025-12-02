import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';

Future<void> main() async {
  final String baseUrl = "https://silicasoft.de/imagePath/";
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  CollectionReference productsRef =
  FirebaseFirestore.instance.collection('product');

  var uuidGenerator = Uuid();
  var random = Random();

  final categories = [
    "Kunst",
    "Mode",
    "Schmuck",
    "Haus",
    "Models",
    "Spiele",
    "Game",
    "Movie",
  ];

  final Filament = [
    "PLA",
    "ABS",
    "PETG",
    "TUP",
    "ASA",
    "Nylon",
    "Wood Composite",
    "Carbon Fiber",
    "PVA",
    "Philips"
  ];

  for (var i = 1; i <= 2; i++) {
    try {
      final uuid = uuidGenerator.v4();

      final brand = Filament[random.nextInt(Filament.length)];
      final category = categories[random.nextInt(categories.length)];
      final price = (50 + random.nextInt(950)) + random.nextDouble();
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
        "category": "Models",
        "brand": brand,
        "price": double.parse(price.toStringAsFixed(2)),
        "imageUrl":
        baseUrl  + "00$i/00$i-1.jpg",
        "images": List.generate(
          3,
              (j) => {
            "url": baseUrl + "00$i/00$i-${j+1}.jpg",
            "color": ["Red", "Blue", "Green", "Black", "White"][j % 5],
          },
        ),
      };

      await productsRef.doc(uuid).set(product);

      print('✅ Added product #$i: ${product['name']}');
    } catch (e) {
      print('❌ Failed to add product #$i: $e');
    }
  }

  print('🎉 All 1000 products uploaded successfully!');
}
