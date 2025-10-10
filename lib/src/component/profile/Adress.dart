import 'package:flutter/material.dart';

class AdressScreen extends StatefulWidget {
  const AdressScreen({Key? key}) : super(key: key);

  @override
  State<AdressScreen> createState() => _AdressScreenState();
}

class _AdressScreenState extends State<AdressScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nachnameController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          SizedBox(height: 12),
          TextField(
            controller: _nachnameController,
            decoration: const InputDecoration(labelText: 'Nachname'),
          ),
          SizedBox(height: 12),
          TextField(
            controller: _streetController,
            decoration: const InputDecoration(labelText: 'Straße'),
          ),
          SizedBox(height: 12),
          TextField(
            controller: _zipController,
            decoration: const InputDecoration(labelText: 'PLZ'),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 12),
          TextField(
            controller: _cityController,
            decoration: const InputDecoration(labelText: 'Stadt'),
          ),
          SizedBox(height: 12),
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(labelText: 'Telefonnummer'),
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // TODO: use the same uid of the user to update the collection (the user document in firestore) with all inputs here after klicking on the save button
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
  }
}
