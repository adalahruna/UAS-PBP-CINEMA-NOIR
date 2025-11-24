// lib/features/community/presentation/cubit/movie_detail_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cinema_noir/features/community/data/repositories/community_repository.dart';
import 'package:cinema_noir/features/community/data/models/movie_detail_model.dart';
import 'package:cinema_noir/features/community/data/models/user_review_model.dart';

// States
abstract class MovieDetailState extends Equatable {
  const MovieDetailState();

  @override
  List<Object?> get props => [];
}

class MovieDetailInitial extends MovieDetailState {}

class MovieDetailLoading extends MovieDetailState {}

class MovieDetailLoaded extends MovieDetailState {
  final MovieDetailModel movieDetail;
  final UserReviewModel? userReview;
  final Map<String, dynamic> ratingStats;
  final bool isSubmittingReview;

  const MovieDetailLoaded({
    required this.movieDetail,
    this.userReview,
    required this.ratingStats,
    this.isSubmittingReview = false,
  });

  MovieDetailLoaded copyWith({
    MovieDetailModel? movieDetail,
    UserReviewModel? userReview,
    Map<String, dynamic>? ratingStats,
    bool? isSubmittingReview,
    bool clearUserReview = false,
  }) {
    return MovieDetailLoaded(
      movieDetail: movieDetail ?? this.movieDetail,
      userReview: clearUserReview ? null : (userReview ?? this.userReview),
      ratingStats: ratingStats ?? this.ratingStats,
      isSubmittingReview: isSubmittingReview ?? this.isSubmittingReview,
    );
  }

  @override
  List<Object?> get props => [movieDetail, userReview, ratingStats, isSubmittingReview];
}

class MovieDetailError extends MovieDetailState {
  final String message;

  const MovieDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class MovieDetailCubit extends Cubit<MovieDetailState> {
  final CommunityRepository _repository;

  MovieDetailCubit(this._repository) : super(MovieDetailInitial());

  /// Load movie details with user review and stats
  Future<void> loadMovieDetail(int movieId) async {
    emit(MovieDetailLoading());

    try {
      // Load all data concurrently
      final results = await Future.wait([
        _repository.getMovieDetails(movieId),
        _repository.getUserReviewForMovie(movieId),
        _repository.getMovieRatingStats(movieId),
      ]);

      final movieDetail = results[0] as MovieDetailModel;
      final userReview = results[1] as UserReviewModel?;
      final ratingStats = results[2] as Map<String, dynamic>;

      emit(MovieDetailLoaded(
        movieDetail: movieDetail,
        userReview: userReview,
        ratingStats: ratingStats,
      ));
    } catch (e) {
      emit(MovieDetailError(e.toString()));
    }
  }

  /// Submit or update user review
  Future<void> submitReview({
    required double rating,
    required String review,
  }) async {
    final currentState = state;
    if (currentState is! MovieDetailLoaded) return;

    emit(currentState.copyWith(isSubmittingReview: true));

    try {
      await _repository.addOrUpdateReview(
        movieId: currentState.movieDetail.id,
        movieTitle: currentState.movieDetail.title,
        rating: rating,
        review: review,
      );

      // Reload the movie details to get updated data
      await loadMovieDetail(currentState.movieDetail.id);
    } catch (e) {
      emit(currentState.copyWith(isSubmittingReview: false));
      // You might want to show a snackbar or toast here
      print('Error submitting review: $e');
    }
  }

  /// Delete user review
  Future<void> deleteReview() async {
    final currentState = state;
    if (currentState is! MovieDetailLoaded) return;

    try {
      await _repository.deleteReview(currentState.movieDetail.id);
      
      // Reload the movie details to get updated data
      await loadMovieDetail(currentState.movieDetail.id);
    } catch (e) {
      print('Error deleting review: $e');
    }
  }

  /// Refresh movie details
  Future<void> refresh() async {
    final currentState = state;
    if (currentState is MovieDetailLoaded) {
      await loadMovieDetail(currentState.movieDetail.id);
    }
  }
}