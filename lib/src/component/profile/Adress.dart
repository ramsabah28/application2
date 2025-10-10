import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdressScreen extends StatefulWidget {
  const AdressScreen({Key? key}) : super(key: key);

  @override
  State<AdressScreen> createState() => _AdressScreenState();
}

class _AdressScreenState extends State<AdressScreen> {
  bool _editMode = false;
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Adressdaten',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _editMode = !_editMode;
                  });
                },
                icon: Icon(_editMode ? Icons.close : Icons.edit),
                tooltip: _editMode ? 'Bearbeiten deaktivieren' : 'Bearbeiten aktivieren',
              ),
            ],
          ),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
            enabled: _editMode,
          ),
          SizedBox(height: 12),
          TextField(
            controller: _nachnameController,
            decoration: const InputDecoration(labelText: 'Nachname'),
            enabled: _editMode,
          ),
          SizedBox(height: 12),
          TextField(
            controller: _streetController,
            decoration: const InputDecoration(labelText: 'Straße'),
            enabled: _editMode,
          ),
          SizedBox(height: 12),
          TextField(
            controller: _zipController,
            decoration: const InputDecoration(labelText: 'PLZ'),
            keyboardType: TextInputType.number,
            enabled: _editMode,
          ),
          SizedBox(height: 12),
          TextField(
            controller: _cityController,
            decoration: const InputDecoration(labelText: 'Stadt'),
            enabled: _editMode,
          ),
          SizedBox(height: 12),
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(labelText: 'Telefonnummer'),
            keyboardType: TextInputType.phone,
            enabled: _editMode,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _editMode
            //TODO: create a function in AdressService.dart and move this part to it.
                ? () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Nicht eingeloggt!')),
                      );
                      return;
                    }
                    try {
                      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                        'name': _nameController.text.trim(),
                        'nachname': _nachnameController.text.trim(),
                        'street': _streetController.text.trim(),
                        'zip': _zipController.text.trim(),
                        'city': _cityController.text.trim(),
                        'phone': _phoneController.text.trim(),
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Adresse gespeichert!')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Fehler beim Speichern: ' + e.toString())),
                      );
                    }
                  }
                : null,
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
  }
}
