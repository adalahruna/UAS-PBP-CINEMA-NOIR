import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/datasources/seat_selection_datasource.dart';
import '../../data/repositories/seat_selection_repository.dart';
import '../../domain/usecases/get_booked_seats.dart';
import '../cubit/seat_selection_cubit.dart';
import '../widgets/seat_layout.dart';

class SeatSelectionPage extends StatelessWidget {
  final int movieId;
  final String date;
  final String time;

  const SeatSelectionPage({
    Key? key,
    required this.movieId,
    required this.date,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SeatSelectionCubit(
        getBookedSeats: GetBookedSeats(
          repository: SeatSelectionRepositoryImpl(
            datasource: SeatSelectionDatasourceImpl(
              firestore: FirebaseFirestore.instance,
            ),
          ),
        ),
      )..fetchBookedSeats(movieId, date, time),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Select Seats'),
        ),
        body: BlocBuilder<SeatSelectionCubit, SeatSelectionState>(
          builder: (context, state) {
            if (state is SeatSelectionLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SeatSelectionError) {
              return Center(child: Text(state.message));
            } else if (state is SeatSelectionLoaded) {
              return SeatLayout(
                bookedSeats: state.bookedSeats,
                selectedSeats: state.selectedSeats,
                onSeatSelected: (seat) {
                  context.read<SeatSelectionCubit>().selectSeat(seat);
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}