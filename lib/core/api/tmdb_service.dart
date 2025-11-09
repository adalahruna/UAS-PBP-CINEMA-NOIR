// lib/core/api/tmdb_service.dart

import 'package:dio/dio.dart';
import 'package:cinema_noir/core/constants/api_constants.dart';
import 'package:cinema_noir/features/home/data/models/movie_model.dart';

class TmdbService {
  final Dio _dio;

  TmdbService()
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
      LogInterceptor(requestBody: true, responseBody: true),
    );
  }

  // TAMBAHKAN FUNGSI BARU INI
  /// Mengambil trailer key untuk sebuah film
  Future<String?> getMovieTrailer(int movieId) async {
    try {
      final response = await _dio.get('/movie/$movieId/videos');
      
      final List results = response.data['results'] as List;
      
      // Cari video YouTube dengan type "Trailer"
      for (var video in results) {
        if (video['site'] == 'YouTube' && video['type'] == 'Trailer') {
          return video['key'] as String;
        }
      }
      
      // Jika tidak ada trailer, ambil video YouTube pertama
      for (var video in results) {
        if (video['site'] == 'YouTube') {
          return video['key'] as String;
        }
      }
      
      return null;
    } catch (e) {
      print('Error getMovieTrailer: $e');
      return null;
    }
  }

  Future<List<MovieModel>> getNowPlayingMovies() async {
    try {
      final response = await _dio.get('/movie/now_playing');
      final List results = response.data['results'] as List;
      final List<MovieModel> movies = results
          .map((movieJson) => MovieModel.fromJson(movieJson))
          .toList();
      return movies;
    } on DioException catch (e) {
      print('Dio Error getNowPlayingMovies: $e');
      rethrow;
    } catch (e) {
      print('Error getNowPlayingMovies: $e');
      rethrow;
    }
  }

  Future<List<MovieModel>> getUpcomingMovies() async {
    try {
      final response = await _dio.get('/movie/upcoming');
      final List results = response.data['results'] as List;
      final List<MovieModel> movies = results
          .map((movieJson) => MovieModel.fromJson(movieJson))
          .toList();
      return movies;
    } on DioException catch (e) {
      print('Dio Error getUpcomingMovies: $e');
      rethrow;
    } catch (e) {
      print('Error getUpcomingMovies: $e');
      rethrow;
    }
  }

  Future<List<MovieModel>> getTopRatedMovies() async {
    try {
      final response = await _dio.get('/movie/top_rated');
      final List results = response.data['results'] as List;
      final List<MovieModel> movies = results
          .map((movieJson) => MovieModel.fromJson(movieJson))
          .toList();
      return movies;
    } on DioException catch (e) {
      print('Dio Error getTopRatedMovies: $e');
      rethrow;
    } catch (e) {
      print('Error getTopRatedMovies: $e');
      rethrow;
    }
  }
}