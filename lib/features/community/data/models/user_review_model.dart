// lib/features/community/data/models/user_review_model.dart

import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserReviewModel extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final int movieId;
  final String movieTitle;
  final double rating;
  final String review;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserReviewModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.movieId,
    required this.movieTitle,
    required this.rating,
    required this.review,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserReviewModel.fromJson(Map<String, dynamic> json) {
    return UserReviewModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userEmail: json['userEmail'] as String,
      movieId: json['movieId'] as int,
      movieTitle: json['movieTitle'] as String,
      rating: (json['rating'] as num).toDouble(),
      review: json['review'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'movieId': movieId,
      'movieTitle': movieTitle,
      'rating': rating,
      'review': review,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserReviewModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    int? movieId,
    String? movieTitle,
    double? rating,
    String? review,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserReviewModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      movieId: movieId ?? this.movieId,
      movieTitle: movieTitle ?? this.movieTitle,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String getCreatedAtFormatted() {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  String getShortReview() {
    if (review.length > 100) {
      return '${review.substring(0, 100)}...';
    }
    return review;
  }

  @override
  List<Object?> get props => [
    id, userId, userName, userEmail, movieId, movieTitle, 
    rating, review, createdAt, updatedAt
  ];
}