import 'package:cinema_noir/core/constants/api_constants.dart';
import 'package:equatable/equatable.dart';

class MovieModel extends Equatable {
  final int id;
  final String title;
  final String overview;
  final String? posterPath; // Bisa null
  final double voteAverage;

  const MovieModel({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    required this.voteAverage,
  });

  // Factory untuk mengubah JSON dari TMDB menjadi object MovieModel
  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] as int,
      title: json['title'] as String,
      overview: json['overview'] as String,
      posterPath: json['poster_path'] as String?,
      voteAverage: (json['vote_average'] as num).toDouble(),
    );
  }

  // Helper untuk mendapatkan URL gambar poster lengkap
  String getFullPosterUrl() {
    if (posterPath != null) {
      return '${ApiConstants.tmdbImageBaseUrl}$posterPath';
    }
    // Return gambar placeholder jika tidak ada poster
    return 'https://via.placeholder.com/500x750.png?text=No+Image';
  }

  @override
  List<Object?> get props => [id, title, overview, posterPath, voteAverage];
}
