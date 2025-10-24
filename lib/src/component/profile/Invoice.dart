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
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final inv = invoices[index];
            return ListTile(
              title: Text('Rechnung ${inv.UUID.substring(0, 8)}'),
              subtitle: Text('Datum: ${inv.date}  |  Positionen: ${inv.count}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${inv.price.toStringAsFixed(2)}€', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(inv.paid ? 'Bezahlt' : 'Offen', style: TextStyle(color: inv.paid ? Colors.green : Colors.red)),
                    ],
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    tooltip: 'Als PDF herunterladen',
                    icon: const Icon(Icons.download_outlined),
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
                ],
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => InvoiceDetails(invoiceId: inv.UUID),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}