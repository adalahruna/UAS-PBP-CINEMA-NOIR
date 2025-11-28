import 'package:cinema_noir/core/constants/api_constants.dart';
import 'package:cinema_noir/features/home/data/models/cast_member_model.dart';
import 'package:cinema_noir/features/home/data/models/crew_member_model.dart';
import 'package:equatable/equatable.dart';

class MovieModel extends Equatable {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final double voteAverage;
  final String? releaseDate;
  final String? trailerKey;
  final List<CastMemberModel>? cast;
  final List<CrewMemberModel>? crew;

  const MovieModel({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    required this.voteAverage,
    this.releaseDate,
    this.trailerKey,
    this.cast,
    this.crew,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] as int,
      title: json['title'] as String,
      overview: json['overview'] as String,
      posterPath: json['poster_path'] as String?,
      voteAverage: (json['vote_average'] as num).toDouble(),
      releaseDate: json['release_date'] as String?,
      trailerKey: null, // Akan diisi kemudian dari API videos
      cast: (json['credits']?['cast'] as List<dynamic>?)
          ?.map((e) => CastMemberModel.fromJson(e))
          .toList(),
      crew: (json['credits']?['crew'] as List<dynamic>?)
          ?.map((e) => CrewMemberModel.fromJson(e))
          .toList(),
    );
  }

  MovieModel copyWith({
    int? id,
    String? title,
    String? overview,
    String? posterPath,
    double? voteAverage,
    String? releaseDate,
    String? trailerKey,
    List<CastMemberModel>? cast,
    List<CrewMemberModel>? crew,
  }) {
    return MovieModel(
      id: id ?? this.id,
      title: title ?? this.title,
      overview: overview ?? this.overview,
      posterPath: posterPath ?? this.posterPath,
      voteAverage: voteAverage ?? this.voteAverage,
      releaseDate: releaseDate ?? this.releaseDate,
      trailerKey: trailerKey ?? this.trailerKey,
      cast: cast ?? this.cast,
      crew: crew ?? this.crew,
    );
  }

  String getFullPosterUrl() {
    if (posterPath != null) {
      return '${ApiConstants.tmdbImageBaseUrl}$posterPath';
    }
    return 'https://via.placeholder.com/500x750.png?text=No+Image';
  }

  @override
  List<Object?> get props => [
        id,
        title,
        overview,
        posterPath,
        voteAverage,
        releaseDate,
        trailerKey,
        cast,
        crew,
      ];
}