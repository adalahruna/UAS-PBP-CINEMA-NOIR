import 'package:flutter/material.dart';

class SeatLayout extends StatelessWidget {
  final List<String> bookedSeats;
  final List<String> selectedSeats;
  final Function(String) onSeatSelected;

  const SeatLayout({
    Key? key,
    required this.bookedSeats,
    required this.selectedSeats,
    required this.onSeatSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 10, // Adjust the number of seats per row
      ),
      itemCount: 100, // Total number of seats
      itemBuilder: (context, index) {
        final row = String.fromCharCode(65 + (index ~/ 10));
        final col = (index % 10) + 1;
        final seatId = '$row$col';

        final isBooked = bookedSeats.contains(seatId);
        final isSelected = selectedSeats.contains(seatId);

        Color seatColor;
        if (isBooked) {
          seatColor = Colors.grey;
        } else if (isSelected) {
          seatColor = Colors.blue;
        } else {
          seatColor = Colors.white;
        }

        return GestureDetector(
          onTap: () {
            if (!isBooked) {
              onSeatSelected(seatId);
            }
          },
          child: Container(
            margin: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: seatColor,
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Center(
              child: Text(seatId),
            ),
          ),
        );
      },
    );
  }
}