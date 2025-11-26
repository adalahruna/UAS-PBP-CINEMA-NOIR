// lib/features/community/presentation/cubit/community_state.dart

import 'package:equatable/equatable.dart';
import 'package:cinema_noir/features/home/data/models/movie_model.dart';
import 'package:cinema_noir/features/community/data/models/genre_model.dart';

abstract class CommunityState extends Equatable {
  const CommunityState();

  @override
  List<Object?> get props => [];
}

// Initial state
class CommunityInitial extends CommunityState {}

// Loading state
class CommunityLoading extends CommunityState {}

// Success state for community page
class CommunityLoaded extends CommunityState {
  final List<MovieModel> movies;
  final bool hasMoreMovies;
  final int currentPage;
  final bool isLoadingMore;
  final SortType currentSort;
  final int? currentGenreId;
  final List<GenreModel> genres;

  const CommunityLoaded({
    required this.movies,
    required this.hasMoreMovies,
    required this.currentPage,
    this.isLoadingMore = false,
    this.currentSort = SortType.popular,
    this.currentGenreId,
    this.genres = const [],
  });

  CommunityLoaded copyWith({
    List<MovieModel>? movies,
    bool? hasMoreMovies,
    int? currentPage,
    bool? isLoadingMore,
    SortType? currentSort,
    int? currentGenreId,
    List<GenreModel>? genres,
    bool clearGenre = false,
  }) {
    return CommunityLoaded(
      movies: movies ?? this.movies,
      hasMoreMovies: hasMoreMovies ?? this.hasMoreMovies,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentSort: currentSort ?? this.currentSort,
      currentGenreId: clearGenre ? null : (currentGenreId ?? this.currentGenreId),
      genres: genres ?? this.genres,
    );
  }

  @override
  List<Object?> get props => [movies, hasMoreMovies, currentPage, isLoadingMore, currentSort, currentGenreId, genres];
}

// Error state
class CommunityError extends CommunityState {
  final String message;

  const CommunityError(this.message);

  @override
  List<Object?> get props => [message];
}

// Search states
class CommunitySearchLoading extends CommunityState {}

class CommunitySearchLoaded extends CommunityState {
  final List<MovieModel> searchResults;
  final String query;
  final bool hasMoreResults;
  final int currentPage;

  const CommunitySearchLoaded({
    required this.searchResults,
    required this.query,
    required this.hasMoreResults,
    required this.currentPage,
  });

  CommunitySearchLoaded copyWith({
    List<MovieModel>? searchResults,
    String? query,
    bool? hasMoreResults,
    int? currentPage,
  }) {
    return CommunitySearchLoaded(
      searchResults: searchResults ?? this.searchResults,
      query: query ?? this.query,
      hasMoreResults: hasMoreResults ?? this.hasMoreResults,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [searchResults, query, hasMoreResults, currentPage];
}

class CommunitySearchError extends CommunityState {
  final String message;

  const CommunitySearchError(this.message);

  @override
  List<Object?> get props => [message];
}
