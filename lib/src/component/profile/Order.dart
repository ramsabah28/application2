import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/OrderService.dart';
import '../../services/UserService.dart';
import '../../models/OrderModel.dart';

class Order extends StatefulWidget {
  const Order({Key? key}) : super(key: key);

  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> with TickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(
        child: Text('Bitte anmelden, um Bestellungen zu sehen.'),
      );
    }

    return StreamBuilder<List<OrderModel>>(
      stream: OrderService.watchOrdersByUser(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text('Fehler beim Laden der Bestellungen.'),
          );
        }

        final allOrders = snapshot.data ?? [];
        // Filter for open orders (delivered == false)
        final openOrders = allOrders.where((order) => !order.deleverd).toList();

        if (openOrders.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Keine offenen Bestellungen',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Ihre Bestellungen erscheinen hier',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Theme.of(context).primaryColorLight,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bestellung ${order.uuid.substring(0, 8)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Text(
                  order.date,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(
                      context,
                    ).primaryColorDark.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Icon(
                  _getStatusIcon(order.status),
                  color: _getStatusColor(order.status, true),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _getStatusText(order.status),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _getStatusColor(order.status, true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _buildStatusProgress(context, order.status),
            const SizedBox(height: 12),

            Row(
              children: [
                Icon(
                  Icons.receipt_outlined,
                  size: 16,
                  color: Theme.of(
                    context,
                  ).primaryColorDark.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  'Rechnung: ${order.BID.substring(0, 8)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).primaryColorDark.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showOrderDetails(context, order);
                    },
                    icon: Icon(
                      Icons.visibility_outlined,
                      size: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                    label: Text(
                      'Details anzeigen',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      side: BorderSide(color: Theme.of(context).primaryColor),
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
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
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
        final stepStatus = steps[index];
        final isCompleted = index <= currentIndex;
        final isCurrent = index == currentIndex;
        final isLast = index == steps.length - 1;
        final statusColor = _getStatusColor(stepStatus, isCompleted);

        return Expanded(
          child: Row(
            children: [
              AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  return Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted ? statusColor : Colors.grey[300],
                      boxShadow: isCurrent && isCompleted
                          ? [
                              BoxShadow(
                                color: statusColor.withValues(
                                  alpha: _glowAnimation.value * 0.8,
                                ),
                                blurRadius: 8 * _glowAnimation.value,
                                spreadRadius: 2 * _glowAnimation.value,
                              ),
                              BoxShadow(
                                color: statusColor.withValues(
                                  alpha: _glowAnimation.value * 0.4,
                                ),
                                blurRadius: 16 * _glowAnimation.value,
                                spreadRadius: 4 * _glowAnimation.value,
                              ),
                            ]
                          : null,
                    ),
                    child: isCompleted
                        ? Icon(
                            Icons.check,
                            size: 12,
                            color: Colors.white,
                            shadows: isCurrent
                                ? [
                                    Shadow(
                                      color: Colors.white.withValues(
                                        alpha: _glowAnimation.value,
                                      ),
                                      blurRadius: 4 * _glowAnimation.value,
                                    ),
                                  ]
                                : null,
                          )
                        : null,
                  );
                },
              ),
              if (!isLast)
                Expanded(
                  child: AnimatedBuilder(
                    animation: _glowAnimation,
                    builder: (context, child) {
                      return Container(
                        height: 2,
                        decoration: BoxDecoration(
                          color: isCompleted ? statusColor : Colors.grey[300],
                          boxShadow: isCurrent && isCompleted
                              ? [
                                  BoxShadow(
                                    color: statusColor.withValues(
                                      alpha: _glowAnimation.value * 0.6,
                                    ),
                                    blurRadius: 4 * _glowAnimation.value,
                                    spreadRadius: 1 * _glowAnimation.value,
                                  ),
                                ]
                              : null,
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getStatusColor(String status, bool isCompleted) {
    if (!isCompleted) return Colors.grey[300]!;

    switch (status) {
      case 'placed':
        return Colors.blue;
      case 'preparing':
        return Colors.orange;
      case 'sent':
        return Colors.purple;
      case 'in_delivery':
        return Colors.green;
      default:
        return Theme.of(context).primaryColor;
    }
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
        backgroundColor: Theme.of(context).primaryColorLight,
        title: Text('Lieferungsdetails ${order.uuid.substring(0, 8)}'),
        content: FutureBuilder<UserData?>(
          future: UserService.getUserDataByUID(order.UID),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final userData = userSnapshot.data;
            final userName = userData?.fullName.isNotEmpty == true
                ? userData!.fullName
                : 'Unbekannt';
            final userEmail = userData?.displayEmail.isNotEmpty == true
                ? userData!.displayEmail
                : 'Keine E-Mail';
            final userAddress = userData?.address.isNotEmpty == true
                ? userData!.address
                : 'Keine Adresse hinterlegt';

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Kunde:', userName),
                _buildDetailRow('E-Mail:', userEmail),
                _buildDetailRow('Adresse:', userAddress),
                _buildDetailRow('Datum:', order.date),
                _buildDetailRow('Status:', _getStatusText(order.status)),
                _buildDetailRow('Zugestellt:', order.deleverd ? 'Ja' : 'Nein'),
              ],
            );
          },
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
            child: Text(value, style: const TextStyle(fontFamily: 'monospace')),
          ),
        ],
      ),
    );
  }

  void _trackOrder(BuildContext context, OrderModel order) {
    final nextStatus = _getNextStatus(order.status);
    final isDelivered = order.status == 'delivered';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).primaryColorLight,
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
            const SizedBox(height: 12),
            // Show next status information
            if (!isDelivered && nextStatus != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColorLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.next_plan,
                          color: Theme.of(context).primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Nächster Schritt:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          _getStatusIcon(nextStatus),
                          color: _getStatusColor(nextStatus, true),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _getStatusText(nextStatus),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: _getStatusColor(nextStatus, true),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else if (isDelivered) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Bestellung wurde erfolgreich zugestellt!',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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

  String? _getNextStatus(String currentStatus) {
    final steps = ['placed', 'preparing', 'sent', 'in_delivery', 'delivered'];
    final currentIndex = steps.indexOf(currentStatus);

    if (currentIndex == -1 || currentIndex >= steps.length - 1) {
      return null; // No next status or already delivered
    }

    return steps[currentIndex + 1];
  }
}
