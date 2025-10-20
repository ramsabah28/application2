import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:application2/src/services/ProductService.dart';

class PdfService {
  static Future<File> generateBillPdf({required String billId}) async {
    final docRef = FirebaseFirestore.instance.collection('bills').doc(billId);
    final snap = await docRef.get();
    if (!snap.exists) {
      throw Exception('Rechnung nicht gefunden');
    }
    final data = snap.data() as Map<String, dynamic>;
    final List<dynamic> pidList = (data['pid'] as List?) ?? const [];
    final double totalPrice = (data['price'] as num?)?.toDouble() ?? 0.0;
    final Map<String, dynamic>? dateMap = data['date'] as Map<String, dynamic>?;
    final String dateStr = dateMap == null
        ? ''
        : '${dateMap['year']}-${dateMap['month']}-${dateMap['day']}';

    final pdf = pw.Document();

    final items = <Map<String, dynamic>>[];
    for (final pid in pidList) {
      try {
        final p = await ProductService.loadProduct(pid.toString());
        items.add({'name': p.name, 'brand': p.brand, 'price': p.price});
      } catch (_) {
        items.add({'name': pid.toString(), 'brand': '', 'price': 0.0});
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Rechnung', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text('Rechnungsnummer: ${data['uuid'] ?? billId}') ,
              pw.Text('Datum: $dateStr'),
              pw.SizedBox(height: 16),
              pw.Table.fromTextArray(
                headers: ['Produkt', 'Marke', 'Preis'],
                data: [
                  for (final it in items) [it['name'], it['brand'], (it['price'] as double).toStringAsFixed(2) + '€']
                ],
              ),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text('Gesamtsumme: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('${totalPrice.toStringAsFixed(2)}€', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ],
          );
        },
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/rechnung_${billId}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}


