part of 'seat_selection_cubit.dart';

abstract class SeatSelectionState extends Equatable {
  const SeatSelectionState();

  @override
  List<Object> get props => [];
}

class SeatSelectionInitial extends SeatSelectionState {}

class SeatSelectionLoading extends SeatSelectionState {}

class SeatSelectionLoaded extends SeatSelectionState {
  final List<String> bookedSeats;
  final List<String> selectedSeats;

  const SeatSelectionLoaded({
    required this.bookedSeats,
    required this.selectedSeats,
  });

  SeatSelectionLoaded copyWith({
    List<String>? bookedSeats,
    List<String>? selectedSeats,
  }) {
    return SeatSelectionLoaded(
      bookedSeats: bookedSeats ?? this.bookedSeats,
      selectedSeats: selectedSeats ?? this.selectedSeats,
    );
  }

  @override
  List<Object> get props => [bookedSeats, selectedSeats];
}

class SeatSelectionError extends SeatSelectionState {
  final String message;

  const SeatSelectionError({required this.message});

  @override
  List<Object> get props => [message];
}