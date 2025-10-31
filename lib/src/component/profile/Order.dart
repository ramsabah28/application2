import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/OrderService.dart';
import '../../models/OrderModel.dart';

class Order extends StatelessWidget {
  const Order({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('Bitte anmelden, um Bestellungen zu sehen.'));
    }

    return StreamBuilder<List<OrderModel>>(
      stream: OrderService.watchOrdersByUser(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return const Center(child: Text('Fehler beim Laden der Bestellungen.'));
        }
        
        final allOrders = snapshot.data ?? [];
        // Filter for open orders (delivered == false)
        final openOrders = allOrders.where((order) => !order.deleverd).toList();
        
        if (openOrders.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'Keine offenen Bestellungen',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Ihre Bestellungen erscheinen hier',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16.0),
          itemCount: openOrders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final order = openOrders[index];
            return _buildOrderCard(context, order);
          },
        );
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with order ID and date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bestellung ${order.uuid.substring(0, 8)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  order.date,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Status section
            Row(
              children: [
                Icon(
                  _getStatusIcon(order.status),
                  color: _getStatusColor(order.status),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _getStatusText(order.status),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _getStatusColor(order.status),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Progress indicator
            _buildStatusProgress(context, order.status),
            const SizedBox(height: 12),
            
            // Bill ID section
            Row(
              children: [
                Icon(
                  Icons.receipt_outlined,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  'Rechnung: ${order.BID.substring(0, 8)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Action button
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showOrderDetails(context, order);
                    },
                    icon: const Icon(Icons.visibility_outlined, size: 16),
                    label: const Text('Details anzeigen'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _trackOrder(context, order);
                    },
                    icon: const Icon(Icons.track_changes_outlined, size: 16),
                    label: const Text('Verfolgen'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusProgress(BuildContext context, String status) {
    final steps = ['placed', 'preparing', 'sent', 'in_delivery'];
    final currentIndex = steps.indexOf(status);
    
    return Row(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final isCompleted = index <= currentIndex;
        final isLast = index == steps.length - 1;
        
        return Expanded(
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? Theme.of(context).primaryColor : Colors.grey[300],
                ),
                child: isCompleted
                    ? const Icon(Icons.check, size: 12, color: Colors.white)
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isCompleted ? Theme.of(context).primaryColor : Colors.grey[300],
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'placed':
        return Icons.shopping_cart_outlined;
      case 'preparing':
        return Icons.kitchen_outlined;
      case 'sent':
        return Icons.local_shipping_outlined;
      case 'in_delivery':
        return Icons.delivery_dining_outlined;
      case 'delivered':
        return Icons.check_circle_outlined;
      default:
        return Icons.help_outline;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'placed':
        return Colors.blue;
      case 'preparing':
        return Colors.orange;
      case 'sent':
        return Colors.purple;
      case 'in_delivery':
        return Colors.indigo;
      case 'delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'placed':
        return 'Bestellt';
      case 'preparing':
        return 'In Vorbereitung';
      case 'sent':
        return 'Versendet';
      case 'in_delivery':
        return 'In Zustellung';
      case 'delivered':
        return 'Zugestellt';
      default:
        return 'Unbekannt';
    }
  }

  void _showOrderDetails(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bestellung ${order.uuid.substring(0, 8)}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Bestellnummer:', order.uuid),
            _buildDetailRow('Rechnungs-ID:', order.BID),
            _buildDetailRow('Benutzer-ID:', order.UID),
            _buildDetailRow('Datum:', order.date),
            _buildDetailRow('Status:', _getStatusText(order.status)),
            _buildDetailRow('Zugestellt:', order.deleverd ? 'Ja' : 'Nein'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Schließen'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }

  void _trackOrder(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bestellung verfolgen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Bestellung ${order.uuid.substring(0, 8)}'),
            const SizedBox(height: 16),
                                        _buildStatusProgress(context, order.status),
            const SizedBox(height: 16),
            Text(
              'Aktueller Status: ${_getStatusText(order.status)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Schließen'),
          ),
        ],
      ),
    );
  }
}