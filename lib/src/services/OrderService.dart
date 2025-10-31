import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/OrderModel.dart';

class OrderService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _ordersCollection = 'orders';

  /// Add a new order by user UID to Firebase with status "placed"
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
        'delivered': false, // Fixed typo from "deleverd"
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection(_ordersCollection).doc(uuid).set(orderData);
    } catch (e) {
      throw Exception('Fehler beim Erstellen der Bestellung: $e');
    }
  }

  /// Get all orders where delivered == false
  static Future<List<OrderModel>> getUndeliveredOrders() async {
    try {
      final querySnapshot = await _firestore
          .collection(_ordersCollection)
          .where('delivered', isEqualTo: false)
          .get();

      final orders = querySnapshot.docs.map((doc) {
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
      
      // Sort by date in descending order (newest first) in the app
      orders.sort((a, b) => b.date.compareTo(a.date));
      return orders;
    } catch (e) {
      throw Exception('Fehler beim Laden der Bestellungen: $e');
    }
  }

  /// Get all orders for a specific user
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
      throw Exception('Fehler beim Laden der Benutzer-Bestellungen: $e');
    }
  }

  /// Stream of orders for real-time updates for a specific user
  static Stream<List<OrderModel>> watchOrdersByUser(String uid) {
    return _firestore
        .collection(_ordersCollection)
        .where('UID', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      final orders = snapshot.docs.map((doc) {
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
      
      // Sort by date in descending order (newest first) in the app
      orders.sort((a, b) => b.date.compareTo(a.date));
      return orders;
    });
  }

  /// Update order status by uuid and UID
  /// Valid statuses: placed, preparing, sent, in_delivery, delivered
  static Future<void> updateOrderStatus({
    required String uuid,
    required String uid,
    required String newStatus,
  }) async {
    try {
      // Validate status
      final validStatuses = ['placed', 'preparing', 'sent', 'in_delivery', 'delivered'];
      if (!validStatuses.contains(newStatus)) {
        throw Exception('Ungültiger Status: $newStatus. Gültige Werte: ${validStatuses.join(', ')}');
      }

      // Check if order exists and belongs to user
      final orderDoc = await _firestore.collection(_ordersCollection).doc(uuid).get();
      if (!orderDoc.exists) {
        throw Exception('Bestellung nicht gefunden');
      }

      final orderData = orderDoc.data()!;
      if (orderData['UID'] != uid) {
        throw Exception('Bestellung gehört nicht zu diesem Benutzer');
      }

      // Update order status
      final updateData = {
        'status': newStatus,
        'delivered': newStatus == 'delivered',
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add delivery date if status is delivered
      if (newStatus == 'delivered') {
        final now = DateTime.now();
        updateData['deliveryDate'] = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      }

      await _firestore.collection(_ordersCollection).doc(uuid).update(updateData);
    } catch (e) {
      throw Exception('Fehler beim Aktualisieren der Bestellung: $e');
    }
  }

  /// Admin function: Update order status without user validation
  static Future<void> adminUpdateOrderStatus({
    required String uuid,
    required String newStatus,
  }) async {
    try {
      // Validate status
      final validStatuses = ['placed', 'preparing', 'sent', 'in_delivery', 'delivered'];
      if (!validStatuses.contains(newStatus)) {
        throw Exception('Ungültiger Status: $newStatus. Gültige Werte: ${validStatuses.join(', ')}');
      }

      // Check if order exists
      final orderDoc = await _firestore.collection(_ordersCollection).doc(uuid).get();
      if (!orderDoc.exists) {
        throw Exception('Bestellung nicht gefunden');
      }

      // Update order status
      final updateData = {
        'status': newStatus,
        'delivered': newStatus == 'delivered',
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add delivery date if status is delivered
      if (newStatus == 'delivered') {
        final now = DateTime.now();
        updateData['deliveryDate'] = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      }

      await _firestore.collection(_ordersCollection).doc(uuid).update(updateData);
    } catch (e) {
      throw Exception('Fehler beim Aktualisieren der Bestellung: $e');
    }
  }

  /// Get order by UUID
  static Future<OrderModel?> getOrderById(String uuid) async {
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

  /// Get order tracking information
  static Future<Map<String, dynamic>> getOrderTracking(String uuid) async {
    try {
      final doc = await _firestore.collection(_ordersCollection).doc(uuid).get();
      if (!doc.exists) {
        throw Exception('Bestellung nicht gefunden');
      }

      final data = doc.data()!;
      return {
        'uuid': data['uuid'] ?? uuid,
        'status': data['status'] ?? 'placed',
        'date': data['date'] ?? '',
        'delivered': data['delivered'] ?? false,
        'deliveryDate': data['deliveryDate'],
        'createdAt': data['createdAt'],
        'updatedAt': data['updatedAt'],
      };
    } catch (e) {
      throw Exception('Fehler beim Laden des Tracking-Status: $e');
    }
  }
}
