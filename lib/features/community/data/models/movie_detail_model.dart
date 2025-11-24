// lib/features/community/data/models/movie_detail_model.dart

import 'package:equatable/equatable.dart';
import 'package:cinema_noir/core/constants/api_constants.dart';

class MovieDetailModel extends Equatable {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final int voteCount;
  final String? releaseDate;
  final int runtime;
  final List<String> genres;
  final String? trailerKey;
  final List<CastModel> cast;
  final List<ReviewModel> reviews;

  const MovieDetailModel({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.voteAverage,
    required this.voteCount,
    this.releaseDate,
    required this.runtime,
    required this.genres,
    this.trailerKey,
    required this.cast,
    required this.reviews,
  });

  factory MovieDetailModel.fromJson(Map<String, dynamic> json) {
    final List genresList = json['genres'] as List? ?? [];
    final List<String> genres = genresList
        .map((genre) => genre['name'] as String)
        .toList();

    return MovieDetailModel(
      id: json['id'] as int,
      title: json['title'] as String,
      overview: json['overview'] as String? ?? '',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: json['vote_count'] as int? ?? 0,
      releaseDate: json['release_date'] as String?,
      runtime: json['runtime'] as int? ?? 0,
      genres: genres,
      trailerKey: null, // Will be set separately
      cast: [], // Will be set separately
      reviews: [], // Will be set separately
    );
  }

  MovieDetailModel copyWith({
    int? id,
    String? title,
    String? overview,
    String? posterPath,
    String? backdropPath,
    double? voteAverage,
    int? voteCount,
    String? releaseDate,
    int? runtime,
    List<String>? genres,
    String? trailerKey,
    List<CastModel>? cast,
    List<ReviewModel>? reviews,
  }) {
    return MovieDetailModel(
      id: id ?? this.id,
      title: title ?? this.title,
      overview: overview ?? this.overview,
      posterPath: posterPath ?? this.posterPath,
      backdropPath: backdropPath ?? this.backdropPath,
      voteAverage: voteAverage ?? this.voteAverage,
      voteCount: voteCount ?? this.voteCount,
      releaseDate: releaseDate ?? this.releaseDate,
      runtime: runtime ?? this.runtime,
      genres: genres ?? this.genres,
      trailerKey: trailerKey ?? this.trailerKey,
      cast: cast ?? this.cast,
      reviews: reviews ?? this.reviews,
    );
  }

  String getFullPosterUrl() {
    if (posterPath != null) {
      return '${ApiConstants.tmdbImageBaseUrl}$posterPath';
    }
    return 'https://via.placeholder.com/500x750.png?text=No+Image';
  }

  String getFullBackdropUrl() {
    if (backdropPath != null) {
      return 'https://image.tmdb.org/t/p/w1280$backdropPath';
    }
    return 'https://via.placeholder.com/1280x720.png?text=No+Backdrop';
  }

  String getRuntimeFormatted() {
    if (runtime == 0) return 'Unknown';
    final hours = runtime ~/ 60;
    final minutes = runtime % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String getReleaseDateFormatted() {
    if (releaseDate == null || releaseDate!.isEmpty) return 'Unknown';
    try {
      final date = DateTime.parse(releaseDate!);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return releaseDate!;
    }
  }

  @override
  List<Object?> get props => [
    id, title, overview, posterPath, backdropPath, voteAverage, voteCount,
    releaseDate, runtime, genres, trailerKey, cast, reviews
  ];
}

class CastModel extends Equatable {
  final int id;
  final String name;
  final String character;
  final String? profilePath;

  const CastModel({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
  });

  factory CastModel.fromJson(Map<String, dynamic> json) {
    return CastModel(
      id: json['id'] as int,
      name: json['name'] as String,
      character: json['character'] as String? ?? '',
      profilePath: json['profile_path'] as String?,
    );
  }

  String getFullProfileUrl() {
    if (profilePath != null) {
      return '${ApiConstants.tmdbImageBaseUrl}$profilePath';
    }
    return 'https://via.placeholder.com/500x750.png?text=No+Photo';
  }

  @override
  List<Object?> get props => [id, name, character, profilePath];
}

class ReviewModel extends Equatable {
  final String id;
  final String author;
  final String content;
  final String createdAt;
  final double? rating;
  final String? avatarPath;

  const ReviewModel({
    required this.id,
    required this.author,
    required this.content,
    required this.createdAt,
    this.rating,
    this.avatarPath,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final authorDetails = json['author_details'] as Map<String, dynamic>?;
    double? rating;
    
    if (authorDetails != null && authorDetails['rating'] != null) {
      rating = (authorDetails['rating'] as num).toDouble();
    }

    return ReviewModel(
      id: json['id'] as String,
      author: json['author'] as String,
      content: json['content'] as String,
      createdAt: json['created_at'] as String,
      rating: rating,
      avatarPath: authorDetails?['avatar_path'] as String?,
    );
  }

  String getCreatedAtFormatted() {
    try {
      final date = DateTime.parse(createdAt);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return createdAt;
    }
  }

  String getShortContent() {
    if (content.length > 150) {
      return '${content.substring(0, 150)}...';
    }
    return content;
  }

  @override
  List<Object?> get props => [id, author, content, createdAt, rating, avatarPath];
}