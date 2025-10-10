import 'package:application2/src/models/BillModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';

class BillService {
  static Future<void> addBill(BillModel model) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Kein Benutzer angemeldet.');
      }

      final uuid = const Uuid().v4();

      final now = DateTime.now();
      final year = now.year.toString();
      final month = now.month.toString().padLeft(2, '0');
      final day = now.day.toString().padLeft(2, '0');
      final hour = now.hour.toString().padLeft(2, '0');
      final minute = now.minute.toString().padLeft(2, '0');
      final second = now.second.toString().padLeft(2, '0');
      final randomTwoDigits = (Random().nextInt(90) + 10).toString(); // safer randomness

      final bid = '$year$month$day$hour$minute$second$randomTwoDigits';

      await FirebaseFirestore.instance.collection('bills').doc(uuid).set({
        'uuid': uuid,
        'userId': model.UID,
        'pid': model.PID,
        'bid': bid,
        'price': model.price,
        'count': model.count,
        'date': {
          'year': now.year,
          'month': now.month,
          'day': now.day,
        },
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Fehler beim Speichern der Rechnung: $e');
    }
  }
}
