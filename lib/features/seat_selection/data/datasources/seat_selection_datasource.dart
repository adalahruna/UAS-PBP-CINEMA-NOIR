
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class SeatSelectionDatasource {
  Future<List<String>> getBookedSeats({
    required int movieId,
    required String date,
    required String time,
  });
}

class SeatSelectionDatasourceImpl implements SeatSelectionDatasource {
  final FirebaseFirestore _firestore;

  SeatSelectionDatasourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Future<List<String>> getBookedSeats({
    required int movieId,
    required String date,
    required String time,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('bookings')
          .where('movieId', isEqualTo: movieId)
          .where('date', isEqualTo: date)
          .where('time', isEqualTo: time)
          .where('status', isEqualTo: 'success')
          .get();

      final bookedSeats = <String>[];
      for (final doc in querySnapshot.docs) {
        final seats = List<String>.from(doc.data()['seats'] as List);
        bookedSeats.addAll(seats);
      }
      return bookedSeats;
    } catch (e) {
      // Handle potential errors, e.g., by logging or re-throwing a custom exception
      throw Exception('Failed to fetch booked seats: $e');
    }
  }
}