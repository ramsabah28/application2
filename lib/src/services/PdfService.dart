import 'dart:io';
import 'dart:convert';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:application2/src/services/ProductService.dart';
import 'package:flutter/services.dart' show rootBundle;

class PdfService {
  static Future<Map<String, dynamic>> _loadBankInfo() async {
    try {
      final String response = await rootBundle.loadString('lib/src/data/bill.json');
      final List<dynamic> data = json.decode(response);
      if (data.isNotEmpty) {
        return data[0] as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error loading bank info: $e');
    }
    return {
      'Kontoinhaber': 'PocketStore-Ram Sabah',
      'IBEN': 'DE00 0000 0000 0000 0000 00',
      'Bank': 'Musterbank Stadt',
      'BIC': 'TSXXTBSSXXXXXX',
      'Verwendungszweck': 'replace with the bid!'
    };
  }

  static Future<File> generateBillPdf({required String billId}) async {
    final docRef = FirebaseFirestore.instance.collection('bills').doc(billId);
    final snap = await docRef.get();
    if (!snap.exists) {
      throw Exception('Rechnung nicht gefunden');
    }
    final data = snap.data() as Map<String, dynamic>;
    
    // Get basic bill information
    final String userId = data['userId'] ?? 'Unbekannt';
    final int totalItemCount = (data['count'] as int?) ?? 0;
    final Map<String, dynamic>? dateMap = data['date'] as Map<String, dynamic>?;
    final String dateStr = dateMap == null
        ? ''
        : '${dateMap['year']}-${dateMap['month']}-${dateMap['day']}';

    // Get user information
    String userName = 'Unbekannt';
    String userAddress = 'Adresse nicht verfügbar';
    
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        userName = userData['name'] ?? 'Unbekannt';
        
        // Build address from user data
        final street = userData['street'] ?? '';
        final houseNumber = userData['houseNumber'] ?? '';
        final zipCode = userData['zipCode'] ?? '';
        final city = userData['city'] ?? '';
        
        if (street.isNotEmpty || city.isNotEmpty) {
          userAddress = '';
          if (street.isNotEmpty) {
            userAddress += street;
            if (houseNumber.isNotEmpty) {
              userAddress += ' $houseNumber';
            }
          }
          if (zipCode.isNotEmpty || city.isNotEmpty) {
            if (userAddress.isNotEmpty) userAddress += '\n';
            if (zipCode.isNotEmpty) userAddress += '$zipCode ';
            if (city.isNotEmpty) userAddress += city;
          }
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    }

    // Load bank information
    final bankInfo = await _loadBankInfo();
    final bid = data['bid'] ?? 'N/A';
    
    // Replace Verwendungszweck with actual BID
    final bankInfoWithBid = Map<String, dynamic>.from(bankInfo);
    bankInfoWithBid['Verwendungszweck'] = bid.toString();

    // Get detailed items from subcollection
    final itemsCollection = await docRef.collection('items').get();
    final List<QueryDocumentSnapshot> itemDocs = itemsCollection.docs;
    
    // Debug: Print the data structure
    print('PDF Generation - Raw bill data keys: ${data.keys}');
    print('PDF Generation - Items subcollection count: ${itemDocs.length}');
    for (var doc in itemDocs) {
      print('PDF Generation - Item doc: ${doc.data()}');
    }

    // Load app logo
    pw.ImageProvider? logoImage;
    try {
      final logoBytes = await rootBundle.load('lib/assets/Logo.png');
      logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
    } catch (e) {
      // Logo loading failed, continue without it
      print('Logo could not be loaded: $e');
    }

    final pdf = pw.Document();

    // Process items with product details
    final items = <Map<String, dynamic>>[];
    double subtotal = 0.0;
    
    for (final itemDoc in itemDocs) {
      try {
        final itemData = itemDoc.data() as Map<String, dynamic>;
        final pid = itemData['pid']?.toString() ?? '';
        final count = itemData['count'] as int? ?? 1;
        final itemPrice = (itemData['price'] as num?)?.toDouble() ?? 0.0;
        
        if (pid.isEmpty) continue;
        
        final product = await ProductService.loadProduct(pid);
        final itemTotal = itemPrice * count;
        subtotal += itemTotal;
        
        items.add({
          'name': product.name,
          'brand': product.brand,
          'price': itemPrice,
          'count': count,
          'total': itemTotal,
        });
        
        print('PDF Generation - Added item: ${product.name}, Count: $count, Price: $itemPrice');
        
      } catch (e) {
        // If product loading fails, use the data we have
        final itemData = itemDoc.data() as Map<String, dynamic>;
        final pid = itemData['pid']?.toString() ?? 'Unbekanntes Produkt';
        final count = itemData['count'] as int? ?? 1;
        final itemPrice = (itemData['price'] as num?)?.toDouble() ?? 0.0;
        
        final itemTotal = itemPrice * count;
        subtotal += itemTotal;
        
        items.add({
          'name': pid,
          'brand': 'Unbekannt',
          'price': itemPrice,
          'count': count,
          'total': itemTotal,
        });
        
        print('PDF Generation - Added fallback item: $pid, Error: $e');
      }
    }
    
    // Debug: Print final items
    print('PDF Generation - Final items count: ${items.length}');
    for (int i = 0; i < items.length; i++) {
      var item = items[i];
      print('PDF Generation - Item $i: ${item['name']}, Brand: ${item['brand']}, Count: ${item['count']}, Price: ${item['price']}');
    }

    // Calculate breakdown
    final tax = subtotal * 0.19; // 19% MwSt
    final shipping = subtotal > 0 ? 4.99 : 0.0;
    final grandTotal = subtotal + tax + shipping;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header with logo and title
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Rechnung', 
                        style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 4),
                    ],
                  ),
                  if (logoImage != null)
                    pw.Container(
                      height: 60,
                      width: 60,
                      child: pw.Image(logoImage),
                    ),
                ],
              ),
              pw.SizedBox(height: 30),
              
              // User information and bank information section
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Left side - User information
                  pw.Expanded(
                    flex: 1,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Rechnungsempfänger:', 
                          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                        pw.SizedBox(height: 8),
                        pw.Text(userName, 
                          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 4),
                        pw.Text(userAddress, 
                          style: pw.TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 40),
                  // Right side - Bank information with background box
                  pw.Expanded(
                    flex: 1,
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey100,
                        borderRadius: pw.BorderRadius.circular(8),
                        border: pw.Border.all(color: PdfColors.grey300, width: 1),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Bankverbindung:', 
                            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                          pw.SizedBox(height: 8),
                          pw.Text('${bankInfoWithBid['Kontoinhaber']}', 
                            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 4),
                          pw.Text('IBAN: ${bankInfoWithBid['IBEN']}', 
                            style: pw.TextStyle(fontSize: 12)),
                          pw.SizedBox(height: 2),
                          pw.Text('BIC: ${bankInfoWithBid['BIC']}', 
                            style: pw.TextStyle(fontSize: 12)),
                          pw.SizedBox(height: 2),
                          pw.Text('Bank: ${bankInfoWithBid['Bank']}', 
                            style: pw.TextStyle(fontSize: 12)),
                          pw.SizedBox(height: 4),
                          pw.Text('Verwendungszweck: ${bankInfoWithBid['Verwendungszweck']}', 
                            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 30),
              
              // Invoice details
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Rechnungsnummer:', 
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('${data['bid'] ?? 'N/A'}'),
                      pw.SizedBox(height: 8),
                      pw.Text('Benutzer-ID:', 
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(userId),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Datum:', 
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(dateStr),
                      pw.SizedBox(height: 8),
                      pw.Text('Artikel gesamt:', 
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('$totalItemCount Stück'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),
              
              // Items table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3), // Product name
                  1: const pw.FlexColumnWidth(2), // Brand
                  2: const pw.FlexColumnWidth(1), // Quantity
                  3: const pw.FlexColumnWidth(1.5), // Single price
                  4: const pw.FlexColumnWidth(1.5), // Total price
                },
                children: [
                  // Header row
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Produkt', 
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Marke', 
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Anzahl', 
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Einzelpreis', 
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Gesamt', 
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  // Data rows - ensure we have at least one row even if empty
                  if (items.isEmpty)
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Keine Artikel gefunden'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(''),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(''),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(''),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(''),
                        ),
                      ],
                    ),
                  // Data rows from items
                  ...items.map((item) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(item['name']?.toString() ?? 'Unbekannt'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(item['brand']?.toString() ?? 'Unbekannt'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('${item['count'] ?? 0}x'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('${((item['price'] ?? 0.0) as double).toStringAsFixed(2)} EUR'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('${((item['total'] ?? 0.0) as double).toStringAsFixed(2)} EUR'),
                      ),
                    ],
                  )).toList(),
                ],
              ),
              pw.SizedBox(height: 20),
              
              // Price breakdown
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Container(
                  width: 250,
                  child: pw.Column(
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Zwischensumme:'),
                          pw.Text('${subtotal.toStringAsFixed(2)} EUR'),
                        ],
                      ),
                      pw.SizedBox(height: 4),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('MwSt (19%):'),
                          pw.Text('${tax.toStringAsFixed(2)} EUR'),
                        ],
                      ),
                      pw.SizedBox(height: 4),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Versandkosten:'),
                          pw.Text('${shipping.toStringAsFixed(2)} EUR'),
                        ],
                      ),
                      pw.Divider(thickness: 1),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Gesamtsumme:', 
                            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                          pw.Text('${grandTotal.toStringAsFixed(2)} EUR', 
                            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
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


