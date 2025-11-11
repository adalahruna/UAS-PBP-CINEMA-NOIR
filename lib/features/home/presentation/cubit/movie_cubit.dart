// lib/features/home/presentation/cubit/movie_cubit.dart

import 'package:bloc/bloc.dart';
import 'package:cinema_noir/core/api/tmdb_service.dart';
import 'movie_state.dart';

class MovieCubit extends Cubit<MovieState> {
  // Buat instance service kita
  final TmdbService _tmdbService;

  // Kita gunakan 'Dependency Injection' sederhana di sini
  // Nanti kita akan 'supply' TmdbService saat membuat Cubit
  MovieCubit(this._tmdbService) : super(MovieLoading());

  // Fungsi untuk mengambil SEMUA data yang dibutuhkan HomePage
  Future<void> fetchHomeMovies() async {
    try {
      // 1. Set state ke Loading (walaupun sudah default)
      emit(MovieLoading());

      // 2. Ambil data secara paralel (bersamaan)
      final results = await Future.wait([
        _tmdbService.getNowPlayingMovies(),
        _tmdbService.getUpcomingMovies(),
        _tmdbService.getTopRatedMovies(), 
      ]);

      // 3. Ekstrak hasilnya
      final nowPlaying = results[0];
      final upcoming = results[1];
      final topRated = results[2]; 

      final nowPlayingIds = nowPlaying.map((movie) => movie.id).toSet();
      final filteredUpcoming = upcoming
          .where((movie) => !nowPlayingIds.contains(movie.id))
          .toList();

      // 4. Kirim state sukses beserta datanya
      emit(MovieLoaded(
        nowPlayingMovies: nowPlaying,
        upcomingMovies: filteredUpcoming,
        topRatedMovies: topRated, // <-- TAMBAHKAN INI
      ));
    } catch (e) {
      // 5. Jika ada error, kirim state error
      emit(MovieError(e.toString()));
    }
  }
}