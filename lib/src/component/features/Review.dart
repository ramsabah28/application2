import 'package:flutter/material.dart';
import '../../models/ReviewModel.dart';
import '../../services/ReviewService.dart';

class ReviewWidget extends StatefulWidget {
  final String productId;
  final bool showAddReview;

  const ReviewWidget({
    super.key,
    required this.productId,
    this.showAddReview = true,
  });

  @override
  State<ReviewWidget> createState() => _ReviewWidgetState();
}

class _ReviewWidgetState extends State<ReviewWidget> {
  List<Review> reviews = [];
  bool isLoading = true;
  double averageRating = 0.0;
  int reviewCount = 0;

  @override
  void initState() {
    super.initState();
    _loadReviews();
    _loadRatingStats();
  }

  Future<void> _loadReviews() async {
    setState(() {
      isLoading = true;
    });

    try {
      final loadedReviews = await ReviewService.getReviewsForProduct(widget.productId);
      print('Loaded ${loadedReviews.length} reviews for product ${widget.productId}');
      setState(() {
        reviews = loadedReviews;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading reviews: $e');
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading reviews: $e')),
        );
      }
    }
  }

  Future<void> _loadRatingStats() async {
    try {
      final rating = await ReviewService.getAverageRating(widget.productId);
      final count = await ReviewService.getReviewCount(widget.productId);
      setState(() {
        averageRating = rating;
        reviewCount = count;
      });
    } catch (e) {
      print('Error loading rating stats: $e');
    }
  }

  void _showAddReviewDialog() {
    showDialog(
      context: context,
      builder: (context) => AddReviewDialog(
        productId: widget.productId,
        onReviewAdded: () {
          _loadReviews();
          _loadRatingStats();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rating Summary
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Text(
                'Reviews ($reviewCount)',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Spacer(),
              if (averageRating > 0) ...[
                Icon(Icons.star, color: Colors.amber, size: 20),
                Text(' ${averageRating.toStringAsFixed(1)}'),
              ],
            ],
          ),
        ),

        // Add Review Button
        if (widget.showAddReview)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton.icon(
              onPressed: _showAddReviewDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Review'),
            ),
          ),

        // Reviews List
        if (isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (reviews.isEmpty)
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Icon(
                  Icons.rate_review_outlined,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 8),
                const Text('No reviews yet. Be the first to review!'),
              ],
            ),
          )
        else
          Column(
            children: [
              const SizedBox(height: 16),
              ...reviews.map((review) => ReviewCard(review: review)).toList(),
            ],
          ),
      ],
    );
  }
}

class ReviewCard extends StatelessWidget {
  final Review review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Rating Stars
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      Icons.star,
                      color: index < review.rank ? Colors.amber : Colors.grey[300],
                      size: 18,
                    );
                  }),
                ),
                const SizedBox(width: 8),
                Text(
                  '${review.rank}/5',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                // Date
                Text(
                  _formatDate(review.date),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Title
            if (review.titel.isNotEmpty) ...[
              Text(
                review.titel,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
            ],
            // Message
            Text(
              review.message,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            // User indicator
            Text(
              'Reviewer: ${_formatUserId(review.UID)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateString;
    }
  }

  String _formatUserId(String userId) {
    // Show only first 8 characters for privacy
    if (userId.length > 8) {
      return '${userId.substring(0, 8)}...';
    }
    return userId;
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