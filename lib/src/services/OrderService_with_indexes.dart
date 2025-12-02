// This is the original OrderService code with Firestore ordering
// Use this ONLY after creating the required Firebase indexes

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/OrderModel.dart';

class OrderServiceWithIndexes {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _ordersCollection = 'orders';

  static Future<void> addOrder({
    required String uid,
    required String billId,
  }) async {
    try {
      final uuid = const Uuid().v4();
      final now = DateTime.now();
      final dateString = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      final orderData = {
        'uuid': uuid,
        'UID': uid,
        'BID': billId,
        'status': 'placed',
        'date': dateString,
        'delivered': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection(_ordersCollection).doc(uuid).set(orderData);
    } catch (e) {
      throw Exception('Fehler beim Erstellen der Bestellung: $e');
    }
  }

  static Stream<List<OrderModel>> watchOrdersByUser(String uid) {
    return _firestore
        .collection(_ordersCollection)
        .where('UID', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return OrderModel(
          uuid: data['uuid'] ?? doc.id,
          UID: data['UID'] ?? '',
          BID: data['BID'] ?? '',
          status: data['status'] ?? 'placed',
          date: data['date'] ?? '',
          deleverd: data['delivered'] ?? false,
        );
      }).toList();
    });
  }

  /// Get all orders where delivered == false (WITH INDEX)
  static Future<List<OrderModel>> getUndeliveredOrders() async {
    try {
      final querySnapshot = await _firestore
          .collection(_ordersCollection)
          .where('delivered', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return OrderModel(
          uuid: data['uuid'] ?? doc.id,
          UID: data['UID'] ?? '',
          BID: data['BID'] ?? '',
          status: data['status'] ?? 'placed',
          date: data['date'] ?? '',
          deleverd: data['delivered'] ?? false,
        );
      }).toList();
    } catch (e) {
      throw Exception('Fehler beim Laden der Bestellungen: $e');
    }
  }

  /// Get all orders for a specific user (WITH INDEX)
  static Future<List<OrderModel>> getOrdersByUser(String uid) async {
    try {
      final querySnapshot = await _firestore
          .collection(_ordersCollection)
          .where('UID', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return OrderModel(
          uuid: data['uuid'] ?? doc.id,
          UID: data['UID'] ?? '',
          BID: data['BID'] ?? '',
          status: data['status'] ?? 'placed',
          date: data['date'] ?? '',
          deleverd: data['delivered'] ?? false,
        );
      }).toList();
    } catch (e) {
      throw Exception('Fehler beim Laden der Bestellungen: $e');
    }
  }

  static Future<void> updateOrderStatus({
    required String uuid,
    required String uid,
    required String status,
  }) async {
    try {
      final validStatuses = ['placed', 'preparing', 'sent', 'in_delivery', 'delivered'];
      
      if (!validStatuses.contains(status)) {
        throw Exception('Ungültiger Status: $status');
      }

      await _firestore.collection(_ordersCollection).doc(uuid).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
        'delivered': status == 'delivered',
      });
    } catch (e) {
      throw Exception('Fehler beim Aktualisieren des Bestellstatus: $e');
    }
  }

  /// Mark order as delivered by uuid and UID
  static Future<void> markOrderAsDelivered({
    required String uuid,
    required String uid,
  }) async {
    try {
      await _firestore.collection(_ordersCollection).doc(uuid).update({
        'delivered': true,
        'status': 'delivered',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Fehler beim Markieren als geliefert: $e');
    }
  }

  /// Delete order by uuid and UID
  static Future<void> deleteOrder({
    required String uuid,
    required String uid,
  }) async {
    try {
      await _firestore.collection(_ordersCollection).doc(uuid).delete();
    } catch (e) {
      throw Exception('Fehler beim Löschen der Bestellung: $e');
    }
  }

  /// Get order by uuid
  static Future<OrderModel?> getOrderByUuid(String uuid) async {
    try {
      final doc = await _firestore.collection(_ordersCollection).doc(uuid).get();
      
      if (!doc.exists) {
        return null;
      }

      final data = doc.data()!;
      return OrderModel(
        uuid: data['uuid'] ?? doc.id,
        UID: data['UID'] ?? '',
        BID: data['BID'] ?? '',
        status: data['status'] ?? 'placed',
        date: data['date'] ?? '',
        deleverd: data['delivered'] ?? false,
      );
    } catch (e) {
      throw Exception('Fehler beim Laden der Bestellung: $e');
    }
  }
}