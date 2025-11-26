import '../../data/repositories/seat_selection_repository.dart';

class GetBookedSeats {
  final SeatSelectionRepository repository;

  GetBookedSeats({required this.repository});

  Future<List<String>> call({
    required int movieId,
    required String date,
    required String time,
  }) async {
    try {
      return await repository.getBookedSeats(
        movieId: movieId,
        date: date,
        time: time,
      );
    } catch (e) {
      // Handle potential errors
      throw Exception('Failed to execute GetBookedSeats: $e');
    }
  }
}