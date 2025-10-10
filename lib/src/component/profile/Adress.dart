import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/AdressModel.dart';
import '../../services/AdressService.dart';

class AdressScreen extends StatefulWidget {
  const AdressScreen({Key? key}) : super(key: key);

  @override
  State<AdressScreen> createState() => _AdressScreenState();
}

class _AdressScreenState extends State<AdressScreen> {
  bool _editMode = false;
  AdressModel? _adressModel;

  final _nameController = TextEditingController();
  final _nachnameController = TextEditingController();
  final _streetController = TextEditingController();
  final _zipController = TextEditingController();
  final _cityController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAdressData();
  }

  Future<void> _loadAdressData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (!doc.exists) return;

      final data = doc.data() ?? {};
      setState(() {
        _adressModel = AdressModel(
          uid: user.uid,
          name: data['name'] ?? '',
          username: data['username'] ?? '',
          surname: data['nachname'] ?? '',
          street: data['street'] ?? '',
          zip: data['zip'] ?? '',
          city: data['city'] ?? '',
          phoneNumber: int.tryParse(data['phone']?.toString() ?? '') ?? 0,
        );

        _nameController.text = _adressModel!.name;
        _nachnameController.text = _adressModel!.surname;
        _streetController.text = _adressModel!.street;
        _zipController.text = _adressModel!.zip;
        _cityController.text = _adressModel!.city;
        _phoneController.text =
        _adressModel!.phoneNumber == 0 ? '' : _adressModel!.phoneNumber.toString();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Laden der Adresse: $e')),
      );
    }
  }

  Future<void> _saveAdressData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nicht eingeloggt!')),
      );
      return;
    }

    final adress = AdressModel(
      uid: user.uid,
      name: _nameController.text.trim(),
      username: user.email ?? '',
      surname: _nachnameController.text.trim(),
      street: _streetController.text.trim(),
      zip: _zipController.text.trim(),
      city: _cityController.text.trim(),
      phoneNumber: int.tryParse(_phoneController.text.trim()) ?? 0,
    );

    try {
      await AdressService.addAdressData(adress);

      setState(() {
        _adressModel = adress;
        _editMode = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adresse gespeichert!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _adressModel == null
        ? const Center(child: CircularProgressIndicator())
        : Padding(
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
                tooltip: _editMode
                    ? 'Bearbeiten deaktivieren'
                    : 'Bearbeiten aktivieren',
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField('Name', _nameController),
          _buildTextField('Nachname', _nachnameController),
          _buildTextField('Straße', _streetController),
          _buildTextField('PLZ', _zipController,
              keyboardType: TextInputType.number),
          _buildTextField('Stadt', _cityController),
          _buildTextField('Telefonnummer', _phoneController,
              keyboardType: TextInputType.phone),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _editMode ? _saveAdressData : null,
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        keyboardType: keyboardType,
        enabled: _editMode,
      ),
    );
  }
}
