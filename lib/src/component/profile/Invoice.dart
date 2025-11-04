import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:application2/src/services/BillService.dart';
import 'package:application2/src/models/InvoiceModel.dart';
import 'InvoiceDetails.dart';
import 'package:application2/src/services/PdfService.dart';
import 'package:printing/printing.dart';

class Invoice extends StatelessWidget {
  const Invoice({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('Bitte anmelden, um Rechnungen zu sehen.'));
    }

    return StreamBuilder<List<InvoiceModel>>(
      stream: BillService.watchBillsByUser(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Fehler beim Laden der Rechnungen.'));
        }
        final invoices = snapshot.data ?? [];
        if (invoices.isEmpty) {
          return const Center(child: Text('Keine Rechnungen gefunden.'));
        }

        return ListView.separated(
          itemCount: invoices.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final inv = invoices[index];
            return Card(
              color: Colors.white,
              elevation: 4,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => InvoiceDetails(invoiceId: inv.UUID),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Rechnung ${inv.UUID.substring(0, 8)}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: inv.paid ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: inv.paid ? Colors.green : Colors.red,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              inv.paid ? 'Bezahlt' : 'Offen',
                              style: TextStyle(
                                color: inv.paid ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Invoice Details
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 6),
                          Text(
                            'Datum: ${inv.date}',
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.shopping_cart, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 6),
                          Text(
                            'Positionen: ${inv.count}',
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Price and Actions Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Gesamtsumme',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${inv.price.toStringAsFixed(2)}€',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              tooltip: 'Als PDF herunterladen',
                              icon: Icon(
                                Icons.download_outlined,
                                color: Theme.of(context).primaryColor,
                              ),
                              onPressed: () async {
                                try {
                                  final file = await PdfService.generateBillPdf(billId: inv.UUID);
                                  await Printing.sharePdf(
                                    bytes: await file.readAsBytes(), 
                                    filename: 'rechnung_${inv.UUID.substring(0,8)}.pdf'
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('PDF-Fehler: ${e.toString()}')),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}