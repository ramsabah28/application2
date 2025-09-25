import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  CollectionReference orderRef =
  FirebaseFirestore.instance.collection('orders');

  List<Map<String, dynamic>> orders = [
  ];

  var uuidGenerator = Uuid();

  for (var order in orders) {
    try {
      order['uuid'] = uuidGenerator.v4();

      await orderRef.add(order);
      print('Added product: ${order['name']} with uuid: ${order['uuid']}');
    } catch (e) {
      print('Failed to add product ${order['name']}: $e');
    }
  }

  print('All products uploaded.');

}