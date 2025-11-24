// lib/features/community/data/datasources/review_local_datasource.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cinema_noir/features/community/data/models/user_review_model.dart';

class ReviewLocalDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _reviewsCollection = 'movie_reviews';

  /// Add or update a user's review for a movie
  Future<void> addOrUpdateReview({
    required int movieId,
    required String movieTitle,
    required double rating,
    required String review,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final now = DateTime.now();
    // ID unik gabungan userId dan movieId
    final reviewId = '${user.uid}_$movieId';

    final userReview = UserReviewModel(
      id: reviewId,
      userId: user.uid,
      userName: user.displayName ?? 'Anonymous',
      userEmail: user.email ?? '',
      movieId: movieId,
      movieTitle: movieTitle,
      rating: rating,
      review: review,
      createdAt: now,
      updatedAt: now,
    );

    await _firestore
        .collection(_reviewsCollection)
        .doc(reviewId)
        .set(userReview.toJson());
  }

  /// Get user's review for a specific movie (Restored!)
  /// Digunakan untuk mengecek apakah user sudah pernah review film ini
  Future<UserReviewModel?> getUserReviewForMovie(int movieId) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final reviewId = '${user.uid}_$movieId';
    final doc = await _firestore
        .collection(_reviewsCollection)
        .doc(reviewId)
        .get();

    if (doc.exists && doc.data() != null) {
      return UserReviewModel.fromJson(doc.data()!);
    }
    return null;
  }

  /// Get all reviews for a specific movie (Public Reviews)
  Future<List<UserReviewModel>> getReviewsForMovie(int movieId) async {
    try {
      final snapshot = await _firestore
          .collection(_reviewsCollection)
          .where('movieId', isEqualTo: movieId)
          .orderBy('createdAt', descending: true) // Menggunakan Index
          .limit(20)
          .get();

      print('DEBUG: Ditemukan ${snapshot.docs.length} review di Firestore.');

      final reviews = snapshot.docs
          .map((doc) => UserReviewModel.fromJson(doc.data()))
          .toList();
      
      return reviews;
    } catch (e) {
      print('Error getting reviews for movie: $e');
      return [];
    }
  }

  /// Get user's all reviews (For Profile Page)
  /// Hanya SATU deklarasi sekarang
  Future<List<UserReviewModel>> getUserReviews() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final snapshot = await _firestore
          .collection(_reviewsCollection)
          .where('userId', isEqualTo: user.uid)
          .limit(50)
          .get();

      final reviews = snapshot.docs
          .map((doc) => UserReviewModel.fromJson(doc.data()))
          .toList();

      // Sort client-side (aman untuk query user pribadi)
      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return reviews;
    } catch (e) {
      print('Error getting user reviews: $e');
      return [];
    }
  }

  /// Delete a user's review
  Future<void> deleteReview(int movieId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final reviewId = '${user.uid}_$movieId';
    await _firestore
        .collection(_reviewsCollection)
        .doc(reviewId)
        .delete();
  }

  /// Get average rating for a movie
  Future<Map<String, dynamic>> getMovieRatingStats(int movieId) async {
    try {
      final snapshot = await _firestore
          .collection(_reviewsCollection)
          .where('movieId', isEqualTo: movieId)
          .get();

      if (snapshot.docs.isEmpty) {
        return {
          'averageRating': 0.0,
          'totalReviews': 0,
        };
      }

      double totalRating = 0.0;
      int reviewCount = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['rating'] is num) {
           totalRating += (data['rating'] as num).toDouble();
           reviewCount++;
        }
      }

      return {
        'averageRating': reviewCount > 0 ? totalRating / reviewCount : 0.0,
        'totalReviews': reviewCount,
      };
    } catch (e) {
      print('Error getting movie rating stats: $e');
      return {
        'averageRating': 0.0,
        'totalReviews': 0,
      };
    }
  }

  /// Get trending movies
  Future<List<Map<String, dynamic>>> getTrendingMovies() async {
    try {
      final snapshot = await _firestore
          .collection(_reviewsCollection)
          .limit(100)
          .get();

      Map<int, Map<String, dynamic>> movieStats = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final movieId = data['movieId'] as int;
        final movieTitle = data['movieTitle'] as String;
        final rating = (data['rating'] as num).toDouble();
        final createdAt = (data['createdAt'] as Timestamp).toDate();

        if (DateTime.now().difference(createdAt).inDays <= 30) {
          if (movieStats.containsKey(movieId)) {
            movieStats[movieId]!['totalRating'] += rating;
            movieStats[movieId]!['reviewCount']++;
          } else {
            movieStats[movieId] = {
              'movieId': movieId,
              'movieTitle': movieTitle,
              'totalRating': rating,
              'reviewCount': 1,
            };
          }
        }
      }

      List<Map<String, dynamic>> trendingMovies = movieStats.values.map((movie) {
        movie['averageRating'] = movie['totalRating'] / movie['reviewCount'];
        return movie;
      }).toList();

      trendingMovies.sort((a, b) => b['reviewCount'].compareTo(a['reviewCount']));
      
      return trendingMovies.take(10).toList();
    } catch (e) {
      print('Error getting trending movies: $e');
      return [];
    }
  }
}