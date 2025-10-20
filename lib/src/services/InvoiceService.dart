import 'package:application2/src/models/InvoiceModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class InvoiceService {
  static Future<void> addInvoice(InvoiceModel invoice) async {
    try {
      final uuid = const Uuid().v4();

      final now = DateTime.now();
      final year = now.year;
      final month = now.month;
      final day = now.day;

      final doc = <String, dynamic>{
        'uuid': uuid,
        'userId': invoice.UID,
        'pid': invoice.PID,
        'count': invoice.count,
        'price': invoice.price,
        'paid' : invoice.paid,
        'date': {'year': year, 'month': month, 'day': day},
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('invoices').doc(uuid).set(doc);
    } catch (e) {
      throw Exception('Fehler beim Speichern der Rechnung (Invoice): $e');
    }
  }

  static Future<void> addInvoiceWithItems(
      InvoiceModel invoice, List<Map<String, dynamic>> items) async {
    try {
      final uuid = const Uuid().v4();

      final now = DateTime.now();
      final year = now.year;
      final month = now.month;
      final day = now.day;

      final ref = FirebaseFirestore.instance.collection('invoices').doc(uuid);

      await ref.set({
        'uuid': uuid,
        'userId': invoice.UID,
        'pid': invoice.PID,
        'count': invoice.count,
        'price': invoice.price,
        'paid': invoice.paid,
        'date': {'year': year, 'month': month, 'day': day},
        'createdAt': FieldValue.serverTimestamp(),
      });

      final batch = FirebaseFirestore.instance.batch();
      for (final item in items) {
        final itemRef = ref.collection('items').doc(item['product'] as String);
        batch.set(itemRef, {
          'product': item['product'],
          'price': item['price'],
          'count': item['count'],
        });
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Fehler beim Speichern der Rechnung mit Positionen: $e');
    }
  }

  static Stream<List<InvoiceModel>> watchInvoicesByUser(String uid) {
    return FirebaseFirestore.instance
        .collection('invoices')
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
            return MapEntry(
              createdAt ?? Timestamp.now(),
              InvoiceModel(
                UUID: data['uuid'] as String? ?? doc.id,
                UID: data['userId'] as String? ?? '',
                PID: data['pid'] as String? ?? '',
                count: (data['count'] as num?)?.toInt() ?? 0,
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
}
