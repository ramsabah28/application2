import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';
import 'package:application2/src/models/InvoiceModel.dart';
import 'package:application2/src/models/BillModel.dart';

class BillService {
  static Stream<List<InvoiceModel>> watchBillsByUser(String uid) {
    return FirebaseFirestore.instance
        .collection('bills')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
          final invoices = snapshot.docs.map((doc) {
            final data = doc.data();
            final dateMap = data['date'] as Map<String, dynamic>?;
            final dateString = dateMap == null
                ? ''
                : '${dateMap['year']}-${dateMap['month']}-${dateMap['day']}';
            final createdAt = data['createdAt'] as Timestamp?;
            final List<dynamic> pid = (data['pid'] as List?) ?? const [];
            return MapEntry(
              createdAt ?? Timestamp.now(),
              InvoiceModel(
                UUID: data['uuid'] as String? ?? doc.id,
                UID: data['userId'] as String? ?? '',
                PID: '',
                count: pid.length,
                price: (data['price'] as num?)?.toDouble() ?? 0.0,
                date: dateString,
                paid: (data['paid'] as bool?) ?? false,
              ),
            );
          }).toList();

          invoices.sort((a, b) => b.key.compareTo(a.key));
          return invoices.map((entry) => entry.value).toList();
        });
  }

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
      final randomTwoDigits = (Random().nextInt(90) + 10).toString();

      final bid = '$year$month$day$hour$minute$second$randomTwoDigits';

      final billRef = FirebaseFirestore.instance.collection('bills').doc(uuid);

      await billRef.set({
        'uuid': uuid,
        'userId': model.UID,
        'pid': model.items.map((i) => i.pid).toList(),
        'bid': bid,
        'price': model.price,
        'count': model.count,
        'date': {'year': now.year, 'month': now.month, 'day': now.day},
        'createdAt': FieldValue.serverTimestamp(),
        'paid': false,
      });

      final batch = FirebaseFirestore.instance.batch();
      for (final item in model.items) {
        final itemRef = billRef.collection('items').doc(item.pid);
        batch.set(itemRef, {
          'pid': item.pid,
          'count': item.count,
          'price': item.price,
        });
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Fehler beim Speichern der Rechnung: $e');
    }
  }
}
