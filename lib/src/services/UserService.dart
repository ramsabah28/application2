import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/UserModel.dart';

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
        return UserService.fromFirestore(data);
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
        return UserService.fromFirestore(data);
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
        return UserService.fromFirestore(data);
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
          .update(UserService.toFirestore(userData));
      
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
          .set(UserService.toFirestore(userData));
      
      return true;
    } catch (e) {
      print('Error creating user data: $e');
      return false;
    }
  }

  /// Create UserData from Firestore document
  static UserData fromFirestore(Map<String, dynamic> data) {
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
      roll: data['roll'] as String?,
    );
  }

  /// Convert UserData to Firestore document
  static Map<String, dynamic> toFirestore(UserData userData) {
    return {
      if (userData.name != null) 'name': userData.name,
      if (userData.nachname != null) 'nachname': userData.nachname,
      if (userData.email != null) 'email': userData.email,
      if (userData.username != null) 'username': userData.username,
      if (userData.city != null) 'city': userData.city,
      if (userData.street != null) 'street': userData.street,
      if (userData.zip != null) 'zip': userData.zip,
      if (userData.phone != null) 'phone': userData.phone,
      if (userData.uid != null) 'uid': userData.uid,
      if (userData.roll != null) 'roll': userData.roll,
    };
  }

  /// Get full name (name + surname)
  static String getFullName(UserData userData) {
    final firstName = userData.name ?? '';
    final lastName = userData.nachname ?? '';
    return '$firstName $lastName'.trim();
  }

  /// Get display email (fallback to username if email is null)
  static String getDisplayEmail(UserData userData) {
    return userData.email ?? userData.username ?? '';
  }

  /// Get formatted address
  static String getAddress(UserData userData) {
    final streetAddress = userData.street ?? '';
    final cityName = userData.city ?? '';
    final zipCode = userData.zip ?? '';
    
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

  /// Get user role by UID
  static Future<String?> getUserRole(String uid) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['roll'] as String?;
      }
      return null;
    } catch (e) {
      print('Error fetching user role: $e');
      return null;
    }
  }

  /// Check if user is admin
  static Future<bool> isUserAdmin(String uid) async {
    try {
      final String? role = await getUserRole(uid);
      return role == 'admin';
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }
}