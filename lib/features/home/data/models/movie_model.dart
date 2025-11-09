import 'package:cinema_noir/core/constants/api_constants.dart';
import 'package:equatable/equatable.dart';

class MovieModel extends Equatable {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final double voteAverage;
  final String? trailerKey; // TAMBAHKAN INI

  const MovieModel({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    required this.voteAverage,
    this.trailerKey, // TAMBAHKAN INI
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] as int,
      title: json['title'] as String,
      overview: json['overview'] as String,
      posterPath: json['poster_path'] as String?,
      voteAverage: (json['vote_average'] as num).toDouble(),
      trailerKey: null, // Akan diisi kemudian dari API videos
    );
  }

  // TAMBAHKAN METHOD copyWith
  MovieModel copyWith({
    int? id,
    String? title,
    String? overview,
    String? posterPath,
    double? voteAverage,
    String? trailerKey,
  }) {
    return MovieModel(
      id: id ?? this.id,
      title: title ?? this.title,
      overview: overview ?? this.overview,
      posterPath: posterPath ?? this.posterPath,
      voteAverage: voteAverage ?? this.voteAverage,
      trailerKey: trailerKey ?? this.trailerKey,
    );
  }

  String getFullPosterUrl() {
    if (posterPath != null) {
      return '${ApiConstants.tmdbImageBaseUrl}$posterPath';
    }
    return 'https://via.placeholder.com/500x750.png?text=No+Image';
  }

  @override
  List<Object?> get props => [id, title, overview, posterPath, voteAverage, trailerKey];
}