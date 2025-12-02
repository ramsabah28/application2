import 'package:flutter/material.dart';
import 'package:application2/src/payment/PayPal.dart';
import 'package:application2/src/payment/InAppBill.dart';
import 'package:application2/src/payment/CreditCard.dart';

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
    // shared button style to make all payment options visually consistent
    final ButtonStyle paymentButtonStyle = ElevatedButton.styleFrom(
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
    );

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
                        builder: (_) => PayPal(amount: amount, currency: currency),
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
            // Placeholder for other payment methods (now styled like PayPal)
            const SizedBox(height: 12),
            Center(
              child: SizedBox(
                width: 220,
                child: ElevatedButton.icon(
                  style: paymentButtonStyle,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CreditCard(
                          onSubmit: (values) {
                            // Mask card number for display
                            final number = values['number'] ?? '';
                            final last4 = number.length >= 4 ? number.substring(number.length - 4) : number;
                            final masked = '**** **** **** $last4';

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Zahlung erfolgreich mit Karte $masked')),
                            );

                            // Close all pushed routes and return to first route
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          },
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.credit_card,
                    color: Colors.black,
                  ),
                  label: const Text(
                    'Kreditkarte',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // In-app purchase option (consumable example) — styled like PayPal button
            const SizedBox(height: 12),
            Center(
              child: SizedBox(
                width: 220,
                child: ElevatedButton.icon(
                  style: paymentButtonStyle,
                  onPressed: () {
                    // TODO: replace 'your_product_id' with the product id configured in Play/App Store
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const InAppBill(productId: 'your_product_id', title: 'In-App Kauf'),
                    ));
                  },
                  icon: const Icon(
                    Icons.phone_iphone,
                    color: Colors.black,
                  ),
                  label: const Text(
                    'In-App Kauf',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
