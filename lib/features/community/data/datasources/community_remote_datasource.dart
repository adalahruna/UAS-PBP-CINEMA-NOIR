// lib/features/community/data/datasources/community_remote_datasource.dart

import 'package:dio/dio.dart';
import 'package:cinema_noir/core/constants/api_constants.dart';
import 'package:cinema_noir/features/home/data/models/movie_model.dart';
import 'package:cinema_noir/features/community/data/models/movie_detail_model.dart';

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
      print('Dio Error getPopularMovies: $e');
      rethrow;
    } catch (e) {
      print('Error getPopularMovies: $e');
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
      print('Dio Error getDiscoverMovies: $e');
      rethrow;
    } catch (e) {
      print('Error getDiscoverMovies: $e');
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
      print('Dio Error searchMovies: $e');
      rethrow;
    } catch (e) {
      print('Error searchMovies: $e');
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
      print('Dio Error getMoviesByGenre: $e');
      rethrow;
    } catch (e) {
      print('Error getMoviesByGenre: $e');
      rethrow;
    }
  }
}