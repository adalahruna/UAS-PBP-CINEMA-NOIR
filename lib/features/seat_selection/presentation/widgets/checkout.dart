import 'package:flutter/material.dart';

class Checkout extends StatelessWidget {
  final List<String> selectedSeats;
  final int pricePerSeat;

  const Checkout({
    Key? key,
    required this.selectedSeats,
    this.pricePerSeat = 50000, // Assuming a fixed price per seat
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalPrice = selectedSeats.length * pricePerSeat;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Selected Seats',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          Text(
            selectedSeats.join(', '),
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Price',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'Rp $totalPrice',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              // Handle checkout logic
            },
            child: const Text('Checkout'),
          ),
        ],
      ),
    );
  }
}