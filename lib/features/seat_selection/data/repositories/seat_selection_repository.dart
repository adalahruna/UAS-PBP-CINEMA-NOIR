import '../datasources/seat_selection_datasource.dart';

abstract class SeatSelectionRepository {
  Future<List<String>> getBookedSeats({
    required int movieId,
    required String date,
    required String time,
  });
}

class SeatSelectionRepositoryImpl implements SeatSelectionRepository {
  final SeatSelectionDatasource datasource;

  SeatSelectionRepositoryImpl({required this.datasource});

  @override
  Future<List<String>> getBookedSeats({
    required int movieId,
    required String date,
    required String time,
  }) async {
    try {
      return await datasource.getBookedSeats(
        movieId: movieId,
        date: date,
        time: time,
      );
    } catch (e) {
      // Handle potential errors
      throw Exception('Failed to get booked seats: $e');
    }
  }
}