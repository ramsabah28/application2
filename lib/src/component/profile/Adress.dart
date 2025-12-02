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
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
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
        _phoneController.text = _adressModel!.phoneNumber == 0
            ? ''
            : _adressModel!.phoneNumber.toString();
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nicht eingeloggt!')));
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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Adresse gespeichert!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return _adressModel == null
        ? Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
          )
        : Container(
            color: Theme.of(context).primaryColorLight,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColorLight,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Adressdaten',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _editMode ? 'Bearbeiten aktiv' : 'Nur ansehen',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).primaryColorDark.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: _editMode 
                                ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                                : Theme.of(context).primaryColorLight.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                _editMode = !_editMode;
                              });
                            },
                            icon: Icon(
                              _editMode ? Icons.close : Icons.edit_outlined,
                              color: _editMode 
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).primaryColorDark,
                            ),
                            tooltip: _editMode
                                ? 'Bearbeiten deaktivieren'
                                : 'Bearbeiten aktivieren',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Form Section
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColorLight,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: _buildTextField('Name', _nameController)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildTextField('Nachname', _nachnameController)),
                          ],
                        ),
                        _buildTextField('Straße', _streetController),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: _buildTextField(
                                'PLZ',
                                _zipController,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: _buildTextField('Stadt', _cityController),
                            ),
                          ],
                        ),
                        _buildTextField(
                          'Telefonnummer',
                          _phoneController,
                          keyboardType: TextInputType.phone,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Save Button Section
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _editMode ? _saveAdressData : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _editMode 
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).primaryColorLight.withValues(alpha: 0.5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: _editMode ? 4 : 0,
                      ),
                      icon: Icon(
                        Icons.save_outlined,
                        color: _editMode ? Colors.white : Colors.grey,
                      ),
                      label: Text(
                        _editMode ? 'Änderungen speichern' : 'Bearbeiten aktivieren zum Speichern',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _editMode ? Colors.white : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColorDark,
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            enabled: _editMode,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 16,
              color: _editMode 
                  ? Theme.of(context).primaryColorDark
                  : Theme.of(context).primaryColorDark.withValues(alpha: 0.6),
            ),
            decoration: InputDecoration(
              hintText: _editMode ? 'Eingeben...' : '',
              filled: true,
              fillColor: _editMode 
                  ? Theme.of(context).primaryColorLight.withValues(alpha: 0.1)
                  : Theme.of(context).primaryColorLight.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColorLight.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColorLight.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColorLight.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
