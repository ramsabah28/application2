import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PayPal extends StatefulWidget {
  final double ammount;
  final String currency;

  const PayPal({required this.ammount, required this.currency, super.key});

  @override
  State<PayPal> createState() => _PayPalState();
}

class _PayPalState extends State<PayPal> {
  // Use live PayPal sign-in. If you need sandbox, change to the sandbox URL.
  final Uri _paypalUrl = Uri.parse('https://www.paypal.com/signin');

  @override
  void initState() {
    super.initState();
    // Open PayPal after the first frame so context is available for SnackBar.
    WidgetsBinding.instance.addPostFrameCallback((_) => _openPayPal());
  }

  Future<void> _openPayPal() async {
    try {
      final launched = await launchUrl(
        _paypalUrl,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Konnte PayPal nicht öffnen.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Öffnen von PayPal: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PayPal')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Sie werden zu PayPal weitergeleitet, um die Zahlung abzuschließen.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _openPayPal,
                child: const Text('PayPal Login öffnen'),
              ),
              const SizedBox(height: 8),
              Text('Betrag: ${"%.2f".replaceAll("%", "")}${widget.ammount} ${widget.currency}'),
            ],
          ),
        ),
      ),
    );
  }
}
