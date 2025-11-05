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

  const MovieLoaded({
    required this.nowPlayingMovies,
    required this.upcomingMovies,
  });

  @override
  List<Object> get props => [nowPlayingMovies, upcomingMovies];
}

// 3. State Error
class MovieError extends MovieState {
  final String message;

  const MovieError(this.message);

  @override
  List<Object> get props => [message];
}
