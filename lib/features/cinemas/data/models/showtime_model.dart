import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ShowtimeModel extends Equatable {
  final String id;
  final String cinemaId;
  final int movieId;
  final DateTime dateTime;
  final List<String> availableSeats;
  final double price;
  final String room;

  const ShowtimeModel({
    required this.id,
    required this.cinemaId,
    required this.movieId,
    required this.dateTime,
    this.availableSeats = const [],
    required this.price,
    required this.room,
  });

  factory ShowtimeModel.fromJson(Map<String, dynamic> json) {
    return ShowtimeModel(
      id: json['id'] ?? '',
      cinemaId: json['cinemaId'] ?? '',
      movieId: json['movieId'] ?? 0,
      dateTime: (json['dateTime'] as Timestamp).toDate(),
      availableSeats: json['availableSeats'] != null
          ? List<String>.from(json['availableSeats'])
          : [],
      price: (json['price'] ?? 0).toDouble(),
      room: json['room'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cinemaId': cinemaId,
      'movieId': movieId,
      'dateTime': dateTime,
      'availableSeats': availableSeats,
      'price': price,
      'room': room,
    };
  }

  @override
  List<Object?> get props => [
        id,
        cinemaId,
        movieId,
        dateTime,
        availableSeats,
        price,
        room,
      ];
}
