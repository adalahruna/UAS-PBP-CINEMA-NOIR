import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/usecases/get_booked_seats.dart';

part 'seat_selection_state.dart';

class SeatSelectionCubit extends Cubit<SeatSelectionState> {
  final GetBookedSeats getBookedSeats;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  SeatSelectionCubit({required this.getBookedSeats}) : super(SeatSelectionInitial());

  Future<void> fetchBookedSeats(int movieId, String date, String time) async {
    emit(SeatSelectionLoading());
    try {
      final bookedSeats = await getBookedSeats(movieId: movieId, date: date, time: time);
      emit(SeatSelectionLoaded(bookedSeats: bookedSeats, selectedSeats: []));
    } catch (e) {
      emit(SeatSelectionError(message: e.toString()));
    }
  }

  void selectSeat(String seat) {
    if (state is SeatSelectionLoaded) {
      final loadedState = state as SeatSelectionLoaded;
      final selectedSeats = List<String>.from(loadedState.selectedSeats);
      if (selectedSeats.contains(seat)) {
        selectedSeats.remove(seat);
      } else {
        selectedSeats.add(seat);
      }
      emit(SeatSelectionLoaded(
        bookedSeats: loadedState.bookedSeats,
        selectedSeats: selectedSeats,
      ));
    }
  }

  Future<void> checkout(
    int movieId,
    String date,
    String time, {
    String? movieTitle,
    String? posterUrl,
  }) async {
    if (state is SeatSelectionLoaded) {
      final loadedState = state as SeatSelectionLoaded;
      final user = _auth.currentUser;

      if (user == null) {
        emit(const SeatSelectionError(message: 'User not logged in'));
        return;
      }

      if (loadedState.selectedSeats.isEmpty) {
        emit(const SeatSelectionError(message: 'No seats selected'));
        return;
      }

      try {
        await _firestore.collection('orders').add({
          'userId': user.uid,
          'userEmail': user.email,
          'type': 'ticket',
          'cinemaName': 'Cinema Noir XXI',
          'movieId': movieId,
          'movieTitle': movieTitle ?? '',
          'posterUrl': posterUrl ?? '',
          'date': date,
          'time': time,
          'schedule': FieldValue.serverTimestamp(),
          'seats': loadedState.selectedSeats,
          'totalPrice': loadedState.selectedSeats.length * 50000,
          'status': 'Paid',
          'createdAt': FieldValue.serverTimestamp(),
        });
        emit(SeatSelectionCheckoutSuccess());
      } catch (e) {
        emit(SeatSelectionError(message: e.toString()));
      }
    }
  }
}