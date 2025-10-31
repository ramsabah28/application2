import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user data from Firestore
  static Future<UserData?> getCurrentUserData() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      final DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return UserData.fromFirestore(data);
      }
      return null;
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  /// Get user data as a stream for real-time updates
  static Stream<UserData?> getCurrentUserDataStream() {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value(null);
    }

    return _firestore
        .collection('users')
        .doc(currentUser.uid)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return UserData.fromFirestore(data);
      }
      return null;
    });
  }

  /// Get user data by UID
  static Future<UserData?> getUserDataByUID(String uid) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return UserData.fromFirestore(data);
      }
      return null;
    } catch (e) {
      print('Error fetching user data by UID: $e');
      return null;
    }
  }

  /// Update user data in Firestore
  static Future<bool> updateUserData(UserData userData) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .update(userData.toFirestore());
      
      return true;
    } catch (e) {
      print('Error updating user data: $e');
      return false;
    }
  }

  /// Create user data in Firestore (for new users)
  static Future<bool> createUserData(UserData userData) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .set(userData.toFirestore());
      
      return true;
    } catch (e) {
      print('Error creating user data: $e');
      return false;
    }
  }
}

class UserData {
  final String? name;
  final String? nachname; // surname
  final String? email;
  final String? username;
  final String? city;
  final String? street;
  final String? zip;
  final int? phone;
  final String? uid;

  UserData({
    this.name,
    this.nachname,
    this.email,
    this.username,
    this.city,
    this.street,
    this.zip,
    this.phone,
    this.uid,
  });

  /// Create UserData from Firestore document
  factory UserData.fromFirestore(Map<String, dynamic> data) {
    return UserData(
      name: data['name'] as String?,
      nachname: data['nachname'] as String?,
      email: data['email'] as String?,
      username: data['username'] as String?,
      city: data['city'] as String?,
      street: data['street'] as String?,
      zip: data['zip'] as String?,
      phone: data['phone'] as int?,
      uid: data['uid'] as String?,
    );
  }

  /// Convert UserData to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      if (name != null) 'name': name,
      if (nachname != null) 'nachname': nachname,
      if (email != null) 'email': email,
      if (username != null) 'username': username,
      if (city != null) 'city': city,
      if (street != null) 'street': street,
      if (zip != null) 'zip': zip,
      if (phone != null) 'phone': phone,
      if (uid != null) 'uid': uid,
    };
  }

  /// Get full name (name + surname)
  String get fullName {
    final firstName = name ?? '';
    final lastName = nachname ?? '';
    return '$firstName $lastName'.trim();
  }

  /// Get display email (fallback to username if email is null)
  String get displayEmail {
    return email ?? username ?? '';
  }

  /// Get formatted address
  String get address {
    final streetAddress = street ?? '';
    final cityName = city ?? '';
    final zipCode = zip ?? '';
    
    if (streetAddress.isEmpty && cityName.isEmpty && zipCode.isEmpty) {
      return '';
    }
    
    final parts = <String>[];
    if (streetAddress.isNotEmpty) parts.add(streetAddress);
    if (zipCode.isNotEmpty && cityName.isNotEmpty) {
      parts.add('$zipCode $cityName');
    } else if (cityName.isNotEmpty) {
      parts.add(cityName);
    } else if (zipCode.isNotEmpty) {
      parts.add(zipCode);
    }
    
    return parts.join(', ');
  }
}