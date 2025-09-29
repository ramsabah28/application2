import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';

Future<void> main() async {
  // Initialize Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Reference to Firestore collection
  CollectionReference productsRef =
  FirebaseFirestore.instance.collection('product');

  // List of products to add
  List<Map<String, dynamic>> products = [
    {
      "name": "iPhone 17 Pro",
      "count": 10,
      "description": "ADas neue iPhone 17 Pro und iPhone 17 Pro Max wurden von Grund auf entwickelt, um die leistungs­stärksten iPhone Modelle aller Zeiten zu sein. Zentrales Element des neuen Designs ist das heiß­geschmiedete Aluminium Unibody Gehäuse, das eine maximale Robustheit, Performance und Batterie­laufzeit ermöglicht.",
      "category": "tech",
      "brand": "Apple",
      "price": 1.300,
      "imageUrl":
      "https://i.otto.de/i/otto/7db310fe-b236-5a0a-a2c7-64bbf85d77f0?h=1040&w=1102&sm=clamp&upscale=true&fmt=auto&qlt=40&unsharp=0,1,0.6,7"
    },
  ];

  var uuidGenerator = Uuid();

  for (var product in products) {
    try {
      product['uuid'] = uuidGenerator.v4();

      await productsRef.add(product);
      print('Added product: ${product['name']} with uuid: ${product['uuid']}');
    } catch (e) {
      print('Failed to add product ${product['name']}: $e');
    }
  }

  print('All products uploaded.');
}
