// lib/features/community/data/datasources/community_remote_datasource.dart

import 'package:dio/dio.dart';
import 'package:cinema_noir/core/constants/api_constants.dart';
import 'package:cinema_noir/features/home/data/models/movie_model.dart';
import 'package:cinema_noir/features/community/data/models/movie_detail_model.dart';
import 'package:cinema_noir/features/community/data/models/genre_model.dart';

class CommunityRemoteDataSource {
  final Dio _dio;

  CommunityRemoteDataSource()
      : _dio = Dio(
          BaseOptions(
            baseUrl: ApiConstants.tmdbBaseUrl,
            queryParameters: {
              'api_key': ApiConstants.tmdbApiKey,
              'language': 'en-US',
            },
          ),
        ) {
    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: false),
    );
  }

  /// Get popular movies with pagination
  Future<List<MovieModel>> getPopularMovies({int page = 1}) async {
    try {
      final response = await _dio.get(
        '/movie/popular',
        queryParameters: {'page': page},
      );
      
      final List results = response.data['results'] as List;
      return results
          .map((movieJson) => MovieModel.fromJson(movieJson))
          .toList();
    } on DioException catch (e) {
      print('Dio Error getPopularMovies: ');
      rethrow;
    } catch (e) {
      print('Error getPopularMovies: ');
      rethrow;
    }
  }

  /// Get discover movies with pagination
  Future<List<MovieModel>> getDiscoverMovies({int page = 1}) async {
    try {
      final response = await _dio.get(
        '/discover/movie',
        queryParameters: {
          'page': page,
          'sort_by': 'popularity.desc',
        },
      );
      
      final List results = response.data['results'] as List;
      return results
          .map((movieJson) => MovieModel.fromJson(movieJson))
          .toList();
    } on DioException catch (e) {
      print('Dio Error getDiscoverMovies: ');
      rethrow;
    } catch (e) {
      print('Error getDiscoverMovies: ');
      rethrow;
    }
  }

  /// Get movie details with additional info
  Future<MovieDetailModel> getMovieDetails(int movieId) async {
    try {
      // Get basic movie details
      final movieResponse = await _dio.get('/movie/$movieId');
      MovieDetailModel movieDetail = MovieDetailModel.fromJson(movieResponse.data);

      // Get trailer
      String? trailerKey;
      try {
        final videoResponse = await _dio.get('/movie/$movieId/videos');
        final List videoResults = videoResponse.data['results'] as List;
        
        for (var video in videoResults) {
          if (video['site'] == 'YouTube' && video['type'] == 'Trailer') {
            trailerKey = video['key'] as String;
            break;
          }
        }
        
        // If no trailer found, get first YouTube video
        if (trailerKey == null) {
          for (var video in videoResults) {
            if (video['site'] == 'YouTube') {
              trailerKey = video['key'] as String;
              break;
            }
          }
        }
      } catch (e) {
        print('Error getting trailer: $e');
      }

      // Get cast
      List<CastModel> cast = [];
      try {
        final creditsResponse = await _dio.get('/movie/$movieId/credits');
        final List castList = creditsResponse.data['cast'] as List;
        cast = castList
            .take(10) // Limit to top 10 cast members
            .map((castJson) => CastModel.fromJson(castJson))
            .toList();
      } catch (e) {
        print('Error getting cast: $e');
      }

      // Get reviews
      List<ReviewModel> reviews = [];
      try {
        final reviewsResponse = await _dio.get('/movie/$movieId/reviews');
        final List reviewsList = reviewsResponse.data['results'] as List;
        reviews = reviewsList
            .take(5) // Limit to top 5 reviews
            .map((reviewJson) => ReviewModel.fromJson(reviewJson))
            .toList();
      } catch (e) {
        print('Error getting reviews: $e');
      }

      return movieDetail.copyWith(
        trailerKey: trailerKey,
        cast: cast,
        reviews: reviews,
      );
    } on DioException catch (e) {
      print('Dio Error getMovieDetails: $e');
      rethrow;
    } catch (e) {
      print('Error getMovieDetails: $e');
      rethrow;
    }
  }

  /// Search movies
  Future<List<MovieModel>> searchMovies(String query, {int page = 1}) async {
    try {
      final response = await _dio.get(
        '/search/movie',
        queryParameters: {
          'query': query,
          'page': page,
        },
      );
      
      final List results = response.data['results'] as List;
      return results
          .map((movieJson) => MovieModel.fromJson(movieJson))
          .toList();
    } on DioException catch (e) {
      print('Dio Error searchMovies: ');
      rethrow;
    } catch (e) {
      print('Error searchMovies: ');
      rethrow;
    }
  }

  /// Get movies by genre
  Future<List<MovieModel>> getMoviesByGenre(int genreId, {int page = 1}) async {
    try {
      final response = await _dio.get(
        '/discover/movie',
        queryParameters: {
          'with_genres': genreId,
          'page': page,
          'sort_by': 'popularity.desc',
        },
      );
      
      final List results = response.data['results'] as List;
      return results
          .map((movieJson) => MovieModel.fromJson(movieJson))
          .toList();
    } on DioException catch (e) {
      print('Dio Error getMoviesByGenre: ');
      rethrow;
    } catch (e) {
      print('Error getMoviesByGenre: ');
      rethrow;
    }
  }

  /// Get top rated movies
  Future<List<MovieModel>> getTopRatedMovies({int page = 1}) async {
    try {
      final response = await _dio.get(
        '/movie/top_rated',
        queryParameters: {'page': page},
      );
      
      final List results = response.data['results'] as List;
      return results
          .map((movieJson) => MovieModel.fromJson(movieJson))
          .toList();
    } on DioException catch (e) {
      print('Dio Error getTopRatedMovies: ');
      rethrow;
    } catch (e) {
      print('Error getTopRatedMovies: ');
      rethrow;
    }
  }

  /// Get upcoming movies
  Future<List<MovieModel>> getUpcomingMovies({int page = 1}) async {
    try {
      final response = await _dio.get(
        '/movie/upcoming',
        queryParameters: {'page': page},
      );
      
      final List results = response.data['results'] as List;
      return results
          .map((movieJson) => MovieModel.fromJson(movieJson))
          .toList();
    } on DioException catch (e) {
      print('Dio Error getUpcomingMovies: ');
      rethrow;
    } catch (e) {
      print('Error getUpcomingMovies: ');
      rethrow;
    }
  }

  /// Get trending movies
  Future<List<MovieModel>> getTrendingMoviesFromAPI({int page = 1}) async {
    try {
      final response = await _dio.get(
        '/trending/movie/day',
        queryParameters: {'page': page},
      );
      
      final List results = response.data['results'] as List;
      return results
          .map((movieJson) => MovieModel.fromJson(movieJson))
          .toList();
    } on DioException catch (e) {
      print('Dio Error getTrendingMoviesFromAPI: ');
      rethrow;
    } catch (e) {
      print('Error getTrendingMoviesFromAPI: ');
      rethrow;
    }
  }

  /// Get movies with custom sorting
  Future<List<MovieModel>> getMoviesWithSorting({
    int page = 1,
    String sortBy = 'popularity.desc',
    int? genreId,
  }) async {
    try {
      Map<String, dynamic> queryParams = {
        'page': page,
        'sort_by': sortBy,
      };

      if (genreId != null) {
        queryParams['with_genres'] = genreId;
      }

      final response = await _dio.get(
        '/discover/movie',
        queryParameters: queryParams,
      );
      
      final List results = response.data['results'] as List;
      List<MovieModel> movies = results
          .map((movieJson) => MovieModel.fromJson(movieJson))
          .toList();

      // For alphabetical sorting, we need to sort locally since TMDB doesn't support title sorting
      if (sortBy == 'title.asc') {
        movies.sort((a, b) {
          final titleA = a.title.toLowerCase().trim();
          final titleB = b.title.toLowerCase().trim();
          return titleA.compareTo(titleB);
        });
      } else if (sortBy == 'title.desc') {
        movies.sort((a, b) {
          final titleA = a.title.toLowerCase().trim();
          final titleB = b.title.toLowerCase().trim();
          return titleB.compareTo(titleA);
        });
      }

      return movies;
    } on DioException catch (e) {
      print('Dio Error getMoviesWithSorting: ');
      rethrow;
    } catch (e) {
      print('Error getMoviesWithSorting: ');
      rethrow;
    }
  }

  /// Get all available genres
  Future<List<GenreModel>> getGenres() async {
    try {
      final response = await _dio.get('/genre/movie/list');
      
      final List genresList = response.data['genres'] as List;
      return genresList
          .map((genreJson) => GenreModel.fromJson(genreJson))
          .toList();
    } on DioException catch (e) {
      print('Dio Error getGenres: ');
      rethrow;
    } catch (e) {
      print('Error getGenres: ');
      rethrow;
    }
  }
}
