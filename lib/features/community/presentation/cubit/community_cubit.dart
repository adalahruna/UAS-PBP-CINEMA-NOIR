// lib/features/community/presentation/cubit/community_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinema_noir/features/community/data/repositories/community_repository.dart';
import 'package:cinema_noir/features/community/presentation/cubit/community_state.dart';
import 'package:cinema_noir/features/community/data/models/genre_model.dart';
import 'package:cinema_noir/features/home/data/models/movie_model.dart';

class CommunityCubit extends Cubit<CommunityState> {
  final CommunityRepository _repository;

  CommunityCubit(this._repository) : super(CommunityInitial());

  /// Initialize community page with genres
  Future<void> initialize() async {
    emit(CommunityLoading());
    
    try {
      // Load genres first
      final genres = await _repository.getGenres();
      
      // Load initial movies
      final movies = await _repository.getMoviesWithSorting(
        page: 1,
        sortBy: SortType.popular.apiValue,
      );
      
      emit(CommunityLoaded(
        movies: movies,
        hasMoreMovies: movies.isNotEmpty && movies.length >= 20,
        currentPage: 1,
        currentSort: SortType.popular,
        genres: genres,
      ));
    } catch (e) {
      emit(CommunityError(e.toString()));
    }
  }

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
    final currentState = state;
    if (currentState is CommunityLoaded) {
      await loadMoviesWithSorting(
        currentState.currentSort,
        genreId: currentState.currentGenreId,
        refresh: true,
      );
    } else {
      await initialize();
    }
  }

  /// Load movies with custom sorting
  Future<void> loadMoviesWithSorting(
    SortType sortType, {
    int? genreId,
    bool refresh = false,
  }) async {
    final currentState = state;
    
    if (refresh || currentState is! CommunityLoaded) {
      emit(CommunityLoading());
    } else {
      final loadedState = currentState;
      if (loadedState is CommunityLoaded && loadedState.isLoadingMore) return;
      if (loadedState is CommunityLoaded) {
        emit(loadedState.copyWith(isLoadingMore: true));
      }
    }

    try {
      int page = 1;
      List<MovieModel> existingMovies = [];
      List<GenreModel> genres = [];

      if (currentState is CommunityLoaded) {
        genres = currentState.genres;
        if (!refresh && 
            currentState.currentSort == sortType && 
            currentState.currentGenreId == genreId) {
          page = currentState.currentPage + 1;
          existingMovies = currentState.movies;
        }
      }

      // Load genres if not available
      if (genres.isEmpty) {
        genres = await _repository.getGenres();
      }

      List<MovieModel> newMovies;
      
      // Handle trending separately using TMDB trending API
      if (sortType == SortType.trending && genreId == null) {
        newMovies = await _repository.getTrendingMoviesFromAPI(page: page);
      } else {
        newMovies = await _repository.getMoviesWithSorting(
          page: page,
          sortBy: sortType.apiValue,
          genreId: genreId,
        );
      }
      
      final List<MovieModel> allMovies;
      
      if (refresh || 
          currentState is! CommunityLoaded ||
          (currentState is CommunityLoaded && currentState.currentSort != sortType) ||
          (currentState is CommunityLoaded && currentState.currentGenreId != genreId)) {
        allMovies = newMovies;
      } else {
        // Safely cast and combine movies
        final existingMoviesList = existingMovies.cast<MovieModel>();
        allMovies = [...existingMoviesList, ...newMovies];
      }

      emit(CommunityLoaded(
        movies: allMovies,
        hasMoreMovies: newMovies.isNotEmpty && newMovies.length >= 20,
        currentPage: page,
        isLoadingMore: false,
        currentSort: sortType,
        currentGenreId: genreId,
        genres: genres,
      ));
    } catch (e) {
      emit(CommunityError(e.toString()));
    }
  }

  /// Change sorting method
  Future<void> changeSorting(SortType sortType) async {
    try {
      final currentState = state;
      int? currentGenreId;
      
      if (currentState is CommunityLoaded) {
        currentGenreId = currentState.currentGenreId;
      }
      
      await loadMoviesWithSorting(sortType, genreId: currentGenreId, refresh: true);
    } catch (e) {
      print('Error changing sorting: ');
      emit(CommunityError('Failed to change sorting: '));
    }
  }

  /// Change genre filter
  Future<void> changeGenre(int? genreId) async {
    try {
      final currentState = state;
      SortType currentSort = SortType.popular;
      
      if (currentState is CommunityLoaded) {
        currentSort = currentState.currentSort;
      }
      
      await loadMoviesWithSorting(currentSort, genreId: genreId, refresh: true);
    } catch (e) {
      print('Error changing genre: ');
      emit(CommunityError('Failed to change genre filter: '));
    }
  }

  /// Load more movies with current sorting and filter
  Future<void> loadMoreSortedMovies() async {
    final currentState = state;
    if (currentState is CommunityLoaded && 
        currentState.hasMoreMovies && 
        !currentState.isLoadingMore) {
      await loadMoviesWithSorting(
        currentState.currentSort,
        genreId: currentState.currentGenreId,
      );
    }
  }
}
