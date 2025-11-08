// lib/features/home/presentation/cubit/movie_state.dart

import 'package:cinema_noir/features/home/data/models/movie_model.dart';
import 'package:equatable/equatable.dart';

abstract class MovieState extends Equatable {
  const MovieState();

  @override
  List<Object> get props => [];
}

// 1. State Awal / Loading
class MovieLoading extends MovieState {}

// 2. State Sukses (Bawa data film)
class MovieLoaded extends MovieState {
  final List<MovieModel> nowPlayingMovies;
  final List<MovieModel> upcomingMovies;
  final List<MovieModel> topRatedMovies; // <-- TAMBAHKAN INI

  const MovieLoaded({
    required this.nowPlayingMovies,
    required this.upcomingMovies,
    required this.topRatedMovies, // <-- TAMBAHKAN INI
  });

  @override
  List<Object> get props => [
        nowPlayingMovies,
        upcomingMovies,
        topRatedMovies, // <-- TAMBAHKAN INI
      ];
}

// 3. State Error
class MovieError extends MovieState {
  final String message;

  const MovieError(this.message);

  @override
  List<Object> get props => [message];
}