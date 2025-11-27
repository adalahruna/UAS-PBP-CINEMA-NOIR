import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:cinema_noir/core/constants/app_colors.dart';
import '../../data/datasources/seat_selection_datasource.dart';
import '../../data/repositories/seat_selection_repository.dart';
import '../../domain/usecases/get_booked_seats.dart';
import '../cubit/seat_selection_cubit.dart';
import '../widgets/checkout.dart';
import '../widgets/seat_layout.dart';

class SeatSelectionPage extends StatelessWidget {
  final int movieId;
  final String date;
  final String time;
  final String? movieTitle;
  final String? posterUrl;

  const SeatSelectionPage({
    super.key,
    required this.movieId,
    required this.date,
    required this.time,
    this.movieTitle,
    this.posterUrl,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SeatSelectionCubit>(
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
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Container(
            margin: const EdgeInsets.only(left: 16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ),
          title: const Text(
            'Select Seats',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1A1A1A),
                AppColors.darkBackground,
              ],
            ),
          ),
          child: BlocConsumer<SeatSelectionCubit, SeatSelectionState>(
            listener: (context, state) {
              if (state is SeatSelectionCheckoutSuccess) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: AppColors.darkGrey,
                    title: const Text('Booking Confirmed', style: TextStyle(color: AppColors.gold)),
                    content: const Text('Your seats have been successfully booked.', style: TextStyle(color: Colors.white70)),
                    actions: [
                      TextButton(
                        onPressed: () {
                          context.go('/my-orders');
                        },
                        child: const Text('View Ticket', style: TextStyle(color: AppColors.gold)),
                      ),
                    ],
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is SeatSelectionLoading) {
                return const Center(child: CircularProgressIndicator(color: AppColors.gold));
              } else if (state is SeatSelectionError) {
                return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
              } else if (state is SeatSelectionLoaded) {
                return Stack(
                  children: [
                    Column(
                      children: [
                        SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight),
                        _SeatSelectionHeader(
                          title: movieTitle ?? 'Movie',
                          posterUrl: posterUrl,
                          date: date,
                          time: time,
                        ),
                        Expanded(
                          child: SeatLayout(
                            bookedSeats: state.bookedSeats,
                            selectedSeats: state.selectedSeats,
                            onSeatSelected: (seat) {
                              context.read<SeatSelectionCubit>().selectSeat(seat);
                            },
                          ),
                        ),
                        // Add padding at bottom for checkout widget
                        const SizedBox(height: 100), 
                      ],
                    ),
                    if (state.selectedSeats.isNotEmpty)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Checkout(
                          selectedSeats: state.selectedSeats,
                          movieId: movieId,
                          date: date,
                          time: time,
                          movieTitle: movieTitle,
                          posterUrl: posterUrl,
                        ),
                      ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

class _SeatSelectionHeader extends StatelessWidget {
  final String title;
  final String? posterUrl;
  final String date;
  final String time;

  const _SeatSelectionHeader({
    required this.title,
    required this.posterUrl,
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: AppColors.gold),
                    const SizedBox(width: 6),
                    Text(
                      '$date • $time',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: AppColors.gold),
                    SizedBox(width: 6),
                    Text(
                      'Cinema Noir XXI',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}