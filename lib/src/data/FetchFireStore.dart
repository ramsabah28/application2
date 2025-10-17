import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Firestore reference
  CollectionReference productsRef =
  FirebaseFirestore.instance.collection('product');

  var uuidGenerator = Uuid();

  // Product data
  List<Map<String, dynamic>> products = [
    {
      "name": "iPhone 17 Pro",
      "count": 10,
      "description":
      "Das neue iPhone 17 Pro und iPhone 17 Pro Max ",
      "midDescription":
      "Das iPhone 17 Pro kombiniert modernste Technologie mit einem eleganten Aluminium Unibody Design. Es wurde für höchste Leistung, Energieeffizienz und Langlebigkeit entwickelt.",
      "longDescription":
      "Das iPhone 17 Pro bietet ein völlig neues Design mit einem heißgeschmiedeten Aluminiumrahmen für maximale Stabilität und Leichtigkeit. Ausgestattet mit dem neuesten A19 Bionic Chip sorgt es für beeindruckende Geschwindigkeit und Energieeffizienz. Das Super Retina XDR Display liefert herausragende Helligkeit und Farbgenauigkeit. Mit verbesserten Kamerasystemen, fortschrittlicher KI-Verarbeitung und einer noch längeren Akkulaufzeit ist das iPhone 17 Pro ein echtes Powerpaket für professionelle Nutzer und Technikliebhaber.",
      "category": "tech",
      "brand": "Apple",
      "price": 1300.0,
      "imageUrl":
      "https://i.otto.de/i/otto/7db310fe-b236-5a0a-a2c7-64bbf85d77f0?h=1040&w=1102&sm=clamp&upscale=true&fmt=auto&qlt=40&unsharp=0,1,0.6,7",
    },
  ];

  for (var product in products) {
    try {
      final uuid = uuidGenerator.v4();
      product['uuid'] = uuid;

      // Add list of images with colors
      product['images'] = List.generate(
        3,
            (i) => {
          "url":
          "https://i.otto.de/i/otto/7db310fe-b236-5a0a-a2c7-64bbf85d77f0?h=1040&w=1102&sm=clamp&upscale=true&fmt=auto&qlt=40&unsharp=0,1,0.6,7",
          "color": ["Silver", "Black", "Gold"][i % 3],
        },
      );

      // Save to Firestore using UUID as document ID
      await productsRef.doc(uuid).set(product);

      print('✅ Added product: ${product['name']} with uuid: $uuid');
    } catch (e) {
      print('❌ Failed to add product ${product['name']}: $e');
    }
  }

  print('🎉 All products uploaded.');
}
