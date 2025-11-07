import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/ProductModel.dart';
import '../../models/ReviewModel.dart';
import '../../services/ProductService.dart';
import '../../services/ReviewService.dart';

class UserReview extends StatefulWidget {
  const UserReview({super.key});

  @override
  State<UserReview> createState() => _UserReviewState();
}

class _UserReviewState extends State<UserReview> {
  List<ProductModel> _purchasedProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserPurchasedProducts();
  }

  Future<void> _loadUserPurchasedProducts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Get all bills for the current user
      final billsSnapshot = await FirebaseFirestore.instance
          .collection('bills')
          .where('userId', isEqualTo: user.uid)
          .get();

      Set<String> productIds = {};
      
      // Extract all unique product IDs from bills
      for (var billDoc in billsSnapshot.docs) {
        final data = billDoc.data();
        final List<dynamic> pid = data['pid'] as List<dynamic>? ?? [];
        for (String id in pid) {
          productIds.add(id);
        }
      }

      // Fetch product details for each unique product ID
      List<ProductModel> products = [];
      for (String productId in productIds) {
        try {
          final product = await ProductService.loadProduct(productId);
          products.add(product);
        } catch (e) {
          print('Error loading product $productId: $e');
        }
      }

      setState(() {
        _purchasedProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading purchased products: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      return Container(
        color: const Color(0xFFF5F6FA),
        child: const Center(
          child: Text(
            'Bitte anmelden, um Bewertungen zu sehen.',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return Container(
      color: const Color(0xFFF5F6FA),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                Icon(
                  Icons.rate_review_outlined,
                  size: 60,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Meine Bewertungen',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bewerten Sie Ihre gekauften Produkte',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).primaryColorDark,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _purchasedProducts.isEmpty
                    ? _buildEmptyState()
                    : _buildProductList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Keine gekauften Produkte',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Kaufen Sie Produkte, um sie bewerten zu können.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _purchasedProducts.length,
      itemBuilder: (context, index) {
        final product = _purchasedProducts[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return Card(
      color: Theme.of(context).primaryColorLight,
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 80,
                height: 80,
                color: Colors.grey[200],
                child: product.imageUrl.isNotEmpty
                    ? Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.image_not_supported,
                            color: Colors.grey[400],
                            size: 40,
                          );
                        },
                      )
                    : Icon(
                        Icons.image_not_supported,
                        color: Colors.grey[400],
                        size: 40,
                      ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.brand,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '€${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            
            // Review Button
            Column(
              children: [
                if (true) // equivalent to widget.showAddReview
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: ElevatedButton.icon(
                      onPressed: () => _showAddReviewDialog(product),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text('Add Review', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
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

  void _showAddReviewDialog(ProductModel product) {
    showDialog(
      context: context,
      builder: (context) => AddReviewDialog(
        productId: product.uuid,
        onReviewAdded: () {
          // Refresh the purchased products list if needed
          _loadUserPurchasedProducts();
        },
      ),
    );
  }


}

class AddReviewDialog extends StatefulWidget {
  final String productId;
  final VoidCallback onReviewAdded;

  const AddReviewDialog({
    super.key,
    required this.productId,
    required this.onReviewAdded,
  });

  @override
  State<AddReviewDialog> createState() => _AddReviewDialogState();
}

class _AddReviewDialogState extends State<AddReviewDialog> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  int _rating = 5;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    // Validate data
    final validationError = ReviewService.validateReviewData(
      rank: _rating,
      title: _titleController.text,
      message: _messageController.text,
    );

    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationError)),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final reviewUuid = await ReviewService.addReview(
        productId: widget.productId,
        rank: _rating,
        title: _titleController.text.trim(),
        message: _messageController.text.trim(),
      );

      if (reviewUuid != null) {
        widget.onReviewAdded();
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Review added successfully!')),
          );
        }
      } else {
        throw Exception('Failed to add review');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Review'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Rating
            Row(
              children: [
                const Text('Rating: '),
                ...List.generate(5, (index) {
                  return IconButton(
                    onPressed: () {
                      setState(() {
                        _rating = index + 1;
                      });
                    },
                    icon: Icon(
                      Icons.star,
                      color: index < _rating ? Colors.amber : Colors.grey[300],
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 16),
            // Title
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Review Title',
                border: OutlineInputBorder(),
              ),
              maxLength: 100,
            ),
            const SizedBox(height: 16),
            // Message
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'Review Message',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              maxLength: 1000,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitReview,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Submit'),
        ),
      ],
    );
  }
}