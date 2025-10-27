import 'package:flutter/material.dart';
import 'package:application2/src/payment/PayPal.dart';
import 'package:application2/src/payment/InAppBill.dart';

class PaymentSelection extends StatelessWidget {
  final double amount;
  final String currency;

  const PaymentSelection({
    Key? key,
    required this.amount,
    required this.currency,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(243, 243, 246, 1),
      appBar: AppBar(
        title: const Text('Zahlungsmethode wählen'),
        backgroundColor: const Color.fromRGBO(243, 243, 246, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Wählen Sie eine Zahlungsmethode:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // center the PayPal button
            Center(
              child: SizedBox(
                width: 220,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColorLight,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 12,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.black54, width: 2),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            PayPal(ammount: amount, currency: currency),
                      ),
                    );
                  },
                  icon: Image.asset(
                    'lib/assets/paypal.png',
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                  ),
                  label: Text(
                    'PayPal — ${amount.toStringAsFixed(2)} $currency',
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Placeholder for other payment methods
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Andere Zahlungsmethoden noch nicht implementiert.',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.credit_card),
              label: const Text('Kreditkarte'),
            ),
            const SizedBox(height: 12),
            // In-app purchase option (consumable example)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
              ),
              onPressed: () {
                // TODO: replace 'your_product_id' with the product id configured in Play/App Store
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const InAppBill(productId: 'your_product_id', title: 'In-App Kauf'),
                ));
              },
              icon: const Icon(Icons.phone_iphone),
              label: const Text('In-App Kauf'),
            ),
          ],
        ),
      ),
    );
  }
}
