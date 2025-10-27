import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PayPal extends StatefulWidget {
  final double amount;
  final String currency;

  final String? paymentLink;
  final String basePayPalLink;

  const PayPal({
    required this.amount,
    this.currency = 'EUR',
    this.paymentLink,
    this.basePayPalLink = 'https://paypal.me/placeholder',
    super.key,
  });

  @override
  State<PayPal> createState() => _PayPalState();
}

class _PayPalState extends State<PayPal> {
  bool _loading = true;
  String? _paymentUrl;

  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(onNavigationRequest: _handleNavigation),
      );

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPaymentPage());
  }

  Future<void> _loadPaymentPage() async {
    setState(() => _loading = true);

    try {
      final formattedAmount = widget.amount.toStringAsFixed(2);

      if (widget.paymentLink != null && widget.paymentLink!.isNotEmpty) {
        // Use the provided paymentLink. Allow a {amount} placeholder.
        _paymentUrl = widget.paymentLink!.contains('{amount}')
            ? widget.paymentLink!.replaceAll('{amount}', formattedAmount)
            : widget.paymentLink!;
      } else {
        // Fallback to basePayPalLink — assume PayPal.me style and append amount
        final base = widget.basePayPalLink.trim();
        if (base.endsWith('/')) {
          _paymentUrl = '$base$formattedAmount';
        } else {
          _paymentUrl = '$base/$formattedAmount';
        }
      }

      // Attempt to add currency as a query parameter if it's not already present.
      try {
        final uri = Uri.parse(_paymentUrl!);
        final newQuery = Map<String, String>.from(uri.queryParameters);
        if (widget.currency.isNotEmpty && !newQuery.containsKey('currency')) {
          newQuery['currency'] = widget.currency;
          _paymentUrl = uri.replace(queryParameters: newQuery).toString();
        }
      } catch (_) {
        // TODO: Handel exceptions here
      }

      await _controller.loadRequest(Uri.parse(_paymentUrl!));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Laden der PayPal-Seite: $e')),
      );
      Navigator.of(context).pop();
    } finally {
      setState(() => _loading = false);
    }
  }

  NavigationDecision _handleNavigation(NavigationRequest request) {
    final url = request.url;

    if (url.contains('paypal.com/checkoutnow/success') ||
        url.contains('paypal.com/thankyou') ||
        url.contains('return')) {
      // Payment done — close or show success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zahlung abgeschlossen!')),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
      return NavigationDecision.prevent;
    }

    if (url.contains('cancel') || url.contains('error')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zahlung abgebrochen')),
      );
      Navigator.of(context).pop();
      return NavigationDecision.prevent;
    }

    return NavigationDecision.navigate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PayPal')),
      body: Stack(
        children: [
          if (_paymentUrl != null)
            WebViewWidget(controller: _controller)
          else if (_loading)
            const Center(child: CircularProgressIndicator())
          else
            const Center(child: Text('Fehler beim Laden der Bezahlseite')),
        ],
      ),
    );
  }
}
