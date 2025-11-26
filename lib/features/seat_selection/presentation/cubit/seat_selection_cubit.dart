import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_booked_seats.dart';

part 'seat_selection_state.dart';

class SeatSelectionCubit extends Cubit<SeatSelectionState> {
  final GetBookedSeats getBookedSeats;

  SeatSelectionCubit({required this.getBookedSeats}) : super(SeatSelectionInitial());

  void fetchBookedSeats(int movieId, String date, String time) async {
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
      final currentState = state as SeatSelectionLoaded;
      final selectedSeats = List<String>.from(currentState.selectedSeats);
      if (selectedSeats.contains(seat)) {
        selectedSeats.remove(seat);
      } else {
        selectedSeats.add(seat);
      }
      emit(currentState.copyWith(selectedSeats: selectedSeats));
    }
  }
}