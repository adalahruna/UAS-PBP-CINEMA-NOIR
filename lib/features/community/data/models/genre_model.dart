// lib/features/community/data/models/genre_model.dart

import 'package:equatable/equatable.dart';

class GenreModel extends Equatable {
  final int id;
  final String name;

  const GenreModel({
    required this.id,
    required this.name,
  });

  factory GenreModel.fromJson(Map<String, dynamic> json) {
    return GenreModel(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  List<Object?> get props => [id, name];
}

enum SortType {
  popular('Popular', 'popularity.desc'),
  topRated('Top Rated', 'vote_average.desc'),
  trending('Trending', 'popularity.desc'), // Similar to popular but can be distinguished
  upcoming('Upcoming', 'release_date.desc'),
  alphabetAZ('A-Z', 'title.asc'),
  alphabetZA('Z-A', 'title.desc');

  const SortType(this.displayName, this.apiValue);

  final String displayName;
  final String apiValue;
}
