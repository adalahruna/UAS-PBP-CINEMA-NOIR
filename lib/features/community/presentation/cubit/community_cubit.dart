// lib/features/community/presentation/cubit/community_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinema_noir/features/community/data/repositories/community_repository.dart';
import 'package:cinema_noir/features/community/presentation/cubit/community_state.dart';
import 'package:cinema_noir/features/home/data/models/movie_model.dart';

class CommunityCubit extends Cubit<CommunityState> {
  final CommunityRepository _repository;

  CommunityCubit(this._repository) : super(CommunityInitial());

  /// Load community movies (popular/discover)
  Future<void> loadCommunityMovies({bool refresh = false}) async {
    if (refresh || state is CommunityInitial) {
      emit(CommunityLoading());
    } else if (state is CommunityLoaded) {
      final currentState = state as CommunityLoaded;
      if (currentState.isLoadingMore) return;
      
      emit(currentState.copyWith(isLoadingMore: true));
    }

    try {
      final currentState = state;
      int page = 1;
      List<MovieModel> existingMovies = [];

      if (currentState is CommunityLoaded && !refresh) {
        page = currentState.currentPage + 1;
        existingMovies = currentState.movies;
      }

      final newMovies = await _repository.getDiscoverMovies(page: page);
      
      final List<MovieModel> allMovies = refresh || currentState is! CommunityLoaded
          ? newMovies
          : [...existingMovies, ...newMovies];

      emit(CommunityLoaded(
        movies: allMovies,
        hasMoreMovies: newMovies.isNotEmpty && newMovies.length >= 20,
        currentPage: page,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(CommunityError(e.toString()));
    }
  }

  /// Load more movies
  Future<void> loadMoreMovies() async {
    final currentState = state;
    if (currentState is CommunityLoaded && 
        currentState.hasMoreMovies && 
        !currentState.isLoadingMore) {
      await loadCommunityMovies();
    }
  }

  /// Search movies
  Future<void> searchMovies(String query, {bool refresh = false}) async {
    if (query.trim().isEmpty) {
      await loadCommunityMovies(refresh: true);
      return;
    }

    if (refresh) {
      emit(CommunitySearchLoading());
    } else {
      final currentState = state;
      if (currentState is CommunitySearchLoaded && 
          currentState.query == query) {
        // Load more search results
        try {
          final nextPage = currentState.currentPage + 1;
          final newResults = await _repository.searchMovies(query, page: nextPage);
          
          emit(currentState.copyWith(
            searchResults: [...currentState.searchResults, ...newResults],
            hasMoreResults: newResults.isNotEmpty && newResults.length >= 20,
            currentPage: nextPage,
          ));
        } catch (e) {
          emit(CommunitySearchError(e.toString()));
        }
        return;
      } else {
        emit(CommunitySearchLoading());
      }
    }

    try {
      final searchResults = await _repository.searchMovies(query, page: 1);
      
      emit(CommunitySearchLoaded(
        searchResults: searchResults,
        query: query,
        hasMoreResults: searchResults.isNotEmpty && searchResults.length >= 20,
        currentPage: 1,
      ));
    } catch (e) {
      emit(CommunitySearchError(e.toString()));
    }
  }

  /// Load movies by genre
  Future<void> loadMoviesByGenre(int genreId, {bool refresh = false}) async {
    if (refresh) {
      emit(CommunityLoading());
    }

    try {
      final currentState = state;
      int page = 1;
      List<MovieModel> existingMovies = [];

      if (currentState is CommunityLoaded && !refresh) {
        page = currentState.currentPage + 1;
        existingMovies = currentState.movies;
      }

      final newMovies = await _repository.getMoviesByGenre(genreId, page: page);
      
      final List<MovieModel> allMovies = refresh || currentState is! CommunityLoaded
          ? newMovies
          : [...existingMovies, ...newMovies];

      emit(CommunityLoaded(
        movies: allMovies,
        hasMoreMovies: newMovies.isNotEmpty && newMovies.length >= 20,
        currentPage: page,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(CommunityError(e.toString()));
    }
  }

  /// Refresh the current view
  Future<void> refresh() async {
    final currentState = state;
    if (currentState is CommunitySearchLoaded) {
      await searchMovies(currentState.query, refresh: true);
    } else {
      await loadCommunityMovies(refresh: true);
    }
  }

  /// Clear search and return to main view
  Future<void> clearSearch() async {
    await loadCommunityMovies(refresh: true);
  }
}
