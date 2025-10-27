import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PayPal extends StatefulWidget {
  final double ammount;
  final String currency;

  const PayPal({required this.ammount, required this.currency, super.key});

  @override
  State<PayPal> createState() => _PayPalState();
}

class _PayPalState extends State<PayPal> {
  bool _loading = true;
  String? _approvalUrl;
  String? _orderId;
  String _returnUrlMarker = 'https://example.com/paypal-return'; // replace with your return URL configured in cloud function

  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(onNavigationRequest: _handleNavigation))
      ;

    WidgetsBinding.instance.addPostFrameCallback((_) => _createOrder());
  }

  Future<void> _createOrder() async {
    setState(() => _loading = true);
    try {
      final functions = FirebaseFunctions.instance;
      final callable = functions.httpsCallable('createOrder');
      final resp = await callable.call(<String, dynamic>{
        'amount': widget.ammount.toStringAsFixed(2),
        'currency': widget.currency,
      });
      final data = Map<String, dynamic>.from(resp.data as Map);
      _approvalUrl = data['approvalUrl'] as String?;
      _orderId = data['orderId'] as String?;
      if (_approvalUrl != null) {
        await _controller.loadRequest(Uri.parse(_approvalUrl!));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fehler beim Erstellen der Bestellung: $e')));
      Navigator.of(context).pop();
    } finally {
      setState(() => _loading = false);
    }
  }

  NavigationDecision _handleNavigation(NavigationRequest request) {
    final url = request.url;
    // PayPal redirects to your return_url with a token/orderId param. Detect that and capture.
    if (url.startsWith(_returnUrlMarker) || Uri.tryParse(url)?.queryParameters.containsKey('token') == true) {
      // stop navigation and capture
      _captureOrder();
      return NavigationDecision.prevent;
    }
    return NavigationDecision.navigate;
  }

  Future<void> _captureOrder() async {
    if (_orderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order-ID fehlt')));
      return;
    }
    setState(() => _loading = true);
    try {
      final functions = FirebaseFunctions.instance;
      final callable = functions.httpsCallable('captureOrder');
      final resp = await callable.call(<String, dynamic>{'orderId': _orderId});
      final data = Map<String, dynamic>.from(resp.data as Map);
      // data should include capture status and transaction id
      final status = data['status'] ?? 'UNKNOWN';
      if (status == 'COMPLETED' || status == 'COMPLETED') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Zahlung erfolgreich')));
        Navigator.of(context).popUntil((route) => route.isFirst);
        // TODO: mark invoice paid on server or in firestore
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Zahlungsstatus: $status')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fehler beim Erfassen der Bestellung: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PayPal')),
      body: Stack(
        children: [
          if (_approvalUrl != null)
            WebViewWidget(controller: _controller)
          else if (_loading)
            const Center(child: CircularProgressIndicator())
          else
            Center(child: Text('Fehler beim Laden der Bezahlseite')),
        ],
      ),
    );
  }
}
