import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A simple credit card input form.
///
/// Provides fields for cardholder name, card number, expiry (MM/YY or MM/YYYY)
/// and CVV. An optional [onSubmit] callback receives a map with the
/// entered values when the user taps the Pay button.
class CreditCard extends StatefulWidget {
  final void Function(Map<String, String> values)? onSubmit;

  const CreditCard({Key? key, this.onSubmit}) : super(key: key);

  @override
  State<CreditCard> createState() => _CreditCardState();
}

class _CreditCardState extends State<CreditCard> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _numberCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  bool _obscureCvv = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _numberCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  String? _validateCardNumber(String? v) {
    if (v == null) return 'Bitte Kartennummer eingeben';
    final cleaned = v.replaceAll(RegExp(r'\s+'), '');
    if (cleaned.isEmpty) return 'Bitte Kartennummer eingeben';
    if (!RegExp(r'^\d{13,19}\$').hasMatch(cleaned)) return 'Ungültige Kartennummer';
    return null;
  }

  String? _validateExpiry(String? v) {
    if (v == null || v.trim().isEmpty) return 'Bitte Ablaufdatum eingeben';
    final cleaned = v.trim();
    final reg = RegExp(r'^(0[1-9]|1[0-2])\/(\d{2}|\d{4})\$');
    if (!reg.hasMatch(cleaned)) return 'Format MM/YY oder MM/YYYY';

    final parts = cleaned.split('/');
    final month = int.tryParse(parts[0])!;
    var year = int.parse(parts[1]);
    if (parts[1].length == 2) {
      final now = DateTime.now();
      final prefix = (now.year ~/ 100) * 100;
      year += prefix;
      // If adding prefix makes year in past (e.g., 1999), move to next century
      if (year < now.year) year += 100;
    }

    final lastDay = DateTime(year, month + 1, 0);
    if (lastDay.isBefore(DateTime.now())) return 'Karte ist abgelaufen';
    return null;
  }

  String? _validateCvv(String? v) {
    if (v == null || v.trim().isEmpty) return 'Bitte CVV eingeben';
    if (!RegExp(r'^\d{3,4}\$').hasMatch(v.trim())) return 'Ungültiges CVV';
    return null;
  }

  void _onPay() {
    if (!_formKey.currentState!.validate()) return;
    final values = {
      'cardholder': _nameCtrl.text.trim(),
      'number': _numberCtrl.text.replaceAll(RegExp(r'\s+'), ''),
      'expiry': _expiryCtrl.text.trim(),
      'cvv': _cvvCtrl.text.trim(),
    };

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Zahlungsdaten bereit')));

    if (widget.onSubmit != null) widget.onSubmit!(values);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorLight,
      appBar: AppBar(title: const Text('Kreditkarte'), backgroundColor: Theme.of(context).primaryColorLight,),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Name auf der Karte'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Bitte Namen eingeben' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _numberCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(labelText: 'Kartennummer', hintText: '#### #### #### ####'),
                validator: _validateCardNumber,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _expiryCtrl,
                      keyboardType: TextInputType.datetime,
                      decoration: const InputDecoration(labelText: 'Ablauf (MM/YY)'),
                      validator: _validateExpiry,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _cvvCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: 'CVV',
                        suffixIcon: IconButton(
                          icon: Icon(_obscureCvv ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _obscureCvv = !_obscureCvv),
                        ),
                      ),
                      obscureText: _obscureCvv,
                      validator: _validateCvv,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _onPay, child: const Text('Bezahlen')),
            ],
          ),
        ),
      ),
    );
  }
}
