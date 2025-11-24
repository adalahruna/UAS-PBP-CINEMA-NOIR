// lib/features/community/data/repositories/community_repository.dart

import 'package:cinema_noir/features/home/data/models/movie_model.dart';
import 'package:cinema_noir/features/community/data/models/movie_detail_model.dart';
import 'package:cinema_noir/features/community/data/models/user_review_model.dart';
import 'package:cinema_noir/features/community/data/datasources/community_remote_datasource.dart';
import 'package:cinema_noir/features/community/data/datasources/review_local_datasource.dart';

class CommunityRepository {
  final CommunityRemoteDataSource _remoteDataSource;
  final ReviewLocalDataSource _reviewDataSource;

  CommunityRepository()
      : _remoteDataSource = CommunityRemoteDataSource(),
        _reviewDataSource = ReviewLocalDataSource();

  /// Get popular movies with pagination
  Future<List<MovieModel>> getPopularMovies({int page = 1}) async {
    return await _remoteDataSource.getPopularMovies(page: page);
  }

  /// Get discover movies with pagination
  Future<List<MovieModel>> getDiscoverMovies({int page = 1}) async {
    return await _remoteDataSource.getDiscoverMovies(page: page);
  }

  /// Get movie details with additional info
  Future<MovieDetailModel> getMovieDetails(int movieId) async {
    // Get movie details from TMDB
    final movieDetail = await _remoteDataSource.getMovieDetails(movieId);
    
    // Get user reviews from Firestore and combine with TMDB reviews
    final userReviews = await _reviewDataSource.getReviewsForMovie(movieId);
    
    // Convert user reviews to ReviewModel format for consistency
    final List<ReviewModel> allReviews = [
      ...movieDetail.reviews, // TMDB reviews
      ...userReviews.map((userReview) => ReviewModel(
        id: userReview.id,
        author: userReview.userName,
        content: userReview.review,
        createdAt: userReview.createdAt.toIso8601String(),
        rating: userReview.rating,
        avatarPath: null,
      )),
    ];

    return movieDetail.copyWith(reviews: allReviews);
  }

  /// Search movies
  Future<List<MovieModel>> searchMovies(String query, {int page = 1}) async {
    return await _remoteDataSource.searchMovies(query, page: page);
  }

  /// Get movies by genre
  Future<List<MovieModel>> getMoviesByGenre(int genreId, {int page = 1}) async {
    return await _remoteDataSource.getMoviesByGenre(genreId, page: page);
  }

  /// Add or update user review
  Future<void> addOrUpdateReview({
    required int movieId,
    required String movieTitle,
    required double rating,
    required String review,
  }) async {
    return await _reviewDataSource.addOrUpdateReview(
      movieId: movieId,
      movieTitle: movieTitle,
      rating: rating,
      review: review,
    );
  }

  /// Get user's review for a movie
  Future<UserReviewModel?> getUserReviewForMovie(int movieId) async {
    return await _reviewDataSource.getUserReviewForMovie(movieId);
  }

  /// Get all reviews for a movie
  Future<List<UserReviewModel>> getReviewsForMovie(int movieId) async {
    return await _reviewDataSource.getReviewsForMovie(movieId);
  }

  /// Get user's all reviews
  Future<List<UserReviewModel>> getUserReviews() async {
    return await _reviewDataSource.getUserReviews();
  }

  /// Delete user's review
  Future<void> deleteReview(int movieId) async {
    return await _reviewDataSource.deleteReview(movieId);
  }

  /// Get movie rating statistics
  Future<Map<String, dynamic>> getMovieRatingStats(int movieId) async {
    return await _reviewDataSource.getMovieRatingStats(movieId);
  }

  /// Get trending movies
  Future<List<Map<String, dynamic>>> getTrendingMovies() async {
    return await _reviewDataSource.getTrendingMovies();
  }
}