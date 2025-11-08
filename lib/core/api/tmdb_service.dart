// lib/core/api/tmdb_service.dart

import 'package:dio/dio.dart';
import 'package:cinema_noir/core/constants/api_constants.dart';
import 'package:cinema_noir/features/home/data/models/movie_model.dart';

class TmdbService {
  // Buat instance Dio
  final Dio _dio;

  TmdbService()
      : _dio = Dio(
          BaseOptions(
            baseUrl: ApiConstants.tmdbBaseUrl,
            queryParameters: {
              'api_key': ApiConstants.tmdbApiKey, // Selalu tambahkan API Key
              'language': 'en-US',
            },
          ),
        ) {
    // (Opsional) Tambahkan Interceptor untuk logging
    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );
  }

  // --- CONTOH FUNGSI PENGAMBILAN DATA ---

  /// Mengambil daftar film yang sedang tayang (Now Playing)
  Future<List<MovieModel>> getNowPlayingMovies() async {
    try {
      final response = await _dio.get('/movie/now_playing');

      // Ambil list 'results' dari response
      final List results = response.data['results'] as List;

      // Ubah setiap item di list menjadi MovieModel
      final List<MovieModel> movies = results
          .map((movieJson) => MovieModel.fromJson(movieJson))
          .toList();

      return movies;
    } on DioException catch (e) {
      // Tangani error
      print('Dio Error getNowPlayingMovies: $e');
      rethrow; // Lempar ulang error agar bisa ditangani UI
    } catch (e) {
      print('Error getNowPlayingMovies: $e');
      rethrow;
    }
  }

  /// Mengambil daftar film yang akan tayang (Upcoming)
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

  // --- BARU: Fungsi untuk mengambil Top Rated Movies ---
  /// Mengambil daftar film dengan rating tertinggi (Top Rated)
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