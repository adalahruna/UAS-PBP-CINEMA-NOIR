import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cinema_noir/features/cinemas/data/models/showtime_model.dart';

abstract class ShowtimeRepository {
  Future<List<ShowtimeModel>> getShowtimesByMovie(int movieId);
  Future<List<ShowtimeModel>> getShowtimesByCinema(String cinemaId);
  Future<List<ShowtimeModel>> getShowtimesByMovieAndCinema(int movieId, String cinemaId);
}

class ShowtimeRepositoryImpl implements ShowtimeRepository {
  final FirebaseFirestore firestore;

  ShowtimeRepositoryImpl({required this.firestore});

  @override
  Future<List<ShowtimeModel>> getShowtimesByMovie(int movieId) async {
    try {
      final snapshot = await firestore
          .collection('showtimes')
          .where('movieId', isEqualTo: movieId)
          .where('dateTime', isGreaterThanOrEqualTo: DateTime.now())
          .orderBy('dateTime')
          .get();

      return snapshot.docs
          .map((doc) => ShowtimeModel.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to load showtimes: $e');
    }
  }

  @override
  Future<List<ShowtimeModel>> getShowtimesByCinema(String cinemaId) async {
    try {
      final snapshot = await firestore
          .collection('showtimes')
          .where('cinemaId', isEqualTo: cinemaId)
          .where('dateTime', isGreaterThanOrEqualTo: DateTime.now())
          .orderBy('dateTime')
          .get();

      return snapshot.docs
          .map((doc) => ShowtimeModel.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to load showtimes: $e');
    }
  }

  @override
  Future<List<ShowtimeModel>> getShowtimesByMovieAndCinema(
      int movieId, String cinemaId) async {
    try {
      final snapshot = await firestore
          .collection('showtimes')
          .where('movieId', isEqualTo: movieId)
          .where('cinemaId', isEqualTo: cinemaId)
          .where('dateTime', isGreaterThanOrEqualTo: DateTime.now())
          .orderBy('dateTime')
          .get();

      return snapshot.docs
          .map((doc) => ShowtimeModel.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to load showtimes: $e');
    }
  }
}
