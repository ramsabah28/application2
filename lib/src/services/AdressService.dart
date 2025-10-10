import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/AdressModel.dart';

class AdressService {
  static Future<void> addAdressData(AdressModel model) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Kein Benutzer angemeldet.');
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
            'name': model.name,
            'username': model.username,
            'nachname': model.surname,
            'street': model.street,
            'zip': model.zip,
            'city': model.city,
            'phone': model.phoneNumber,
          });
    } catch (e) {
      throw Exception('Fehler beim Speichern der Adresse: $e');
    }
  }

  /**
    Future<AdressModel> _loadAdressData(String uid) async {
    final user = FirebaseAuth.instance.currentUser;
    AdressModel? _adressModel;

    try {
    final doc = await FirebaseFirestore.instance
    .collection('users')
    .doc(user.uid)
    .get();


    final data = doc.data() ?? {};

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
    } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Fehler beim Laden der Adresse: $e')),
    );
    }
    }
 **/
}
