import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/ReviewModel.dart';

class ReviewService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _collectionName = 'reviews';

  /// Add a new review to Firestore
  /// [productId] - The ID of the product being reviewed
  /// [rank] - Rating from 1-5
  /// [title] - Review title
  /// [message] - Review content
  static Future<String?> addReview({
    required String productId,
    required int rank,
    required String title,
    required String message,
  }) async {
    try {
      // Get current user
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User must be logged in to add a review');
      }

      // Generate UUID for the review
      final String reviewUuid = const Uuid().v4();
      
      // Get current date
      final String currentDate = DateTime.now().toIso8601String();

      // Create Review object
      final Review review = Review(
        uuid: reviewUuid,
        UID: currentUser.uid,
        PID: productId,
        date: currentDate,
        rank: rank,
        titel: title, // Note: keeping the typo from the model
        message: message,
      );

      // Add to Firestore
      await _firestore
          .collection(_collectionName)
          .doc(reviewUuid)
          .set(review.toMap());

      return reviewUuid;
    } catch (e) {
      print('Error adding review: $e');
      return null;
    }
  }

  /// Get all reviews for a specific product
  /// [productId] - The ID of the product
  static Future<List<Review>> getReviewsForProduct(String productId) async {
    try {
      print('Fetching reviews for product: $productId');
      final QuerySnapshot querySnapshot = await _firestore
          .collection(_collectionName)
          .where('PID', isEqualTo: productId)
          .get();

      print('Found ${querySnapshot.docs.length} review documents');
      
      final reviews = querySnapshot.docs
          .map((doc) {
            print('Review document data: ${doc.data()}');
            return Review.fromMap(doc.data() as Map<String, dynamic>);
          })
          .toList();

      // Sort by date locally instead of using orderBy to avoid index issues
      reviews.sort((a, b) {
        try {
          final dateA = DateTime.parse(a.date);
          final dateB = DateTime.parse(b.date);
          return dateB.compareTo(dateA); // Descending order (newest first)
        } catch (e) {
          return 0;
        }
      });

      return reviews;
    } catch (e) {
      print('Error fetching reviews for product: $e');
      return [];
    }
  }

  /// Get all reviews by a specific user
  /// [userId] - The ID of the user (optional, defaults to current user)
  static Future<List<Review>> getReviewsByUser([String? userId]) async {
    try {
      String targetUserId = userId ?? _auth.currentUser?.uid ?? '';
      
      if (targetUserId.isEmpty) {
        throw Exception('No user ID provided');
      }

      final QuerySnapshot querySnapshot = await _firestore
          .collection(_collectionName)
          .where('UID', isEqualTo: targetUserId)
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Review.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching reviews by user: $e');
      return [];
    }
  }

  /// Get a specific review by UUID
  /// [reviewUuid] - The UUID of the review
  static Future<Review?> getReviewById(String reviewUuid) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(_collectionName)
          .doc(reviewUuid)
          .get();

      if (doc.exists) {
        return Review.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error fetching review by ID: $e');
      return null;
    }
  }

  /// Update an existing review
  /// [reviewUuid] - The UUID of the review to update
  /// [rank] - New rating (optional)
  /// [title] - New title (optional)
  /// [message] - New message (optional)
  static Future<bool> updateReview({
    required String reviewUuid,
    int? rank,
    String? title,
    String? message,
  }) async {
    try {
      // Get current user
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User must be logged in to update a review');
      }

      // First check if the review exists and belongs to the current user
      final Review? existingReview = await getReviewById(reviewUuid);
      if (existingReview == null) {
        throw Exception('Review not found');
      }

      if (existingReview.UID != currentUser.uid) {
        throw Exception('You can only update your own reviews');
      }

      // Prepare update data
      Map<String, dynamic> updateData = {};
      if (rank != null) updateData['rank'] = rank;
      if (title != null) updateData['titel'] = title; // Note: keeping the typo
      if (message != null) updateData['message'] = message;
      updateData['date'] = DateTime.now().toIso8601String(); // Update timestamp

      // Update in Firestore
      await _firestore
          .collection(_collectionName)
          .doc(reviewUuid)
          .update(updateData);

      return true;
    } catch (e) {
      print('Error updating review: $e');
      return false;
    }
  }

  /// Delete a review
  /// [reviewUuid] - The UUID of the review to delete
  static Future<bool> deleteReview(String reviewUuid) async {
    try {
      // Get current user
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User must be logged in to delete a review');
      }

      // First check if the review exists and belongs to the current user
      final Review? existingReview = await getReviewById(reviewUuid);
      if (existingReview == null) {
        throw Exception('Review not found');
      }

      if (existingReview.UID != currentUser.uid) {
        throw Exception('You can only delete your own reviews');
      }

      // Delete from Firestore
      await _firestore
          .collection(_collectionName)
          .doc(reviewUuid)
          .delete();

      return true;
    } catch (e) {
      print('Error deleting review: $e');
      return false;
    }
  }

  /// Get average rating for a product
  /// [productId] - The ID of the product
  static Future<double> getAverageRating(String productId) async {
    try {
      final List<Review> reviews = await getReviewsForProduct(productId);
      
      if (reviews.isEmpty) return 0.0;
      
      final int totalRating = reviews.fold(0, (sum, review) => sum + review.rank);
      return totalRating / reviews.length;
    } catch (e) {
      print('Error calculating average rating: $e');
      return 0.0;
    }
  }

  /// Get review count for a product
  /// [productId] - The ID of the product
  static Future<int> getReviewCount(String productId) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection(_collectionName)
          .where('PID', isEqualTo: productId)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      print('Error getting review count: $e');
      return 0;
    }
  }

  /// Stream reviews for a product (real-time updates)
  /// [productId] - The ID of the product
  static Stream<List<Review>> streamReviewsForProduct(String productId) {
    return _firestore
        .collection(_collectionName)
        .where('PID', isEqualTo: productId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Review.fromMap(doc.data()))
            .toList());
  }

  /// Validate review data before submission
  /// [rank] - Rating (must be 1-5)
  /// [title] - Review title (must not be empty)
  /// [message] - Review message (must not be empty)
  static String? validateReviewData({
    required int rank,
    required String title,
    required String message,
  }) {
    if (rank < 1 || rank > 5) {
      return 'Rating must be between 1 and 5';
    }
    
    if (title.trim().isEmpty) {
      return 'Review title cannot be empty';
    }
    
    if (message.trim().isEmpty) {
      return 'Review message cannot be empty';
    }
    
    if (title.length > 100) {
      return 'Review title cannot exceed 100 characters';
    }
    
    if (message.length > 1000) {
      return 'Review message cannot exceed 1000 characters';
    }
    
    return null; // No validation errors
  }
}