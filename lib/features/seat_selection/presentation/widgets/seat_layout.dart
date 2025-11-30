import 'package:cinema_noir/core/constants/app_colors.dart';
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
    const rows = 8;
    const cols = 10;
    const rowLabels = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];

    return Container(
      padding: const EdgeInsets.only(bottom: 80), // Add bottom padding to prevent overlap with checkout
      child: Column(
        children: [
          // Screen
          Container(
            margin: const EdgeInsets.only(top: 20, bottom: 30), // Increased bottom margin
            height: 30,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.6),
                  blurRadius: 15,
                  spreadRadius: 1,
                  offset: const Offset(0, 8),
                ),
              ],
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.grey[800]!,
                  Colors.grey[900]!,
                ],
              ),
            ),
            child: const Center(
              child: Text(
                'S C R E E N',
                style: TextStyle(
                  color: Colors.white24,
                  letterSpacing: 8,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        
        // Seat Grid with fixed height and scrollable content
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                      minWidth: constraints.maxWidth,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 20),
                        ...List.generate(
                          rows,
                          (row) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Row label (A, B, C, etc.)
                                SizedBox(
                                  width: 30,
                                  child: Center(
                                    child: Text(
                                      rowLabels[row],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Seats
                                ...List.generate(
                                  cols,
                                  (col) {
                                    final seatId = '${rowLabels[row]}${col + 1}';
                                    final isBooked = bookedSeats.contains(seatId);
                                    final isSelected = selectedSeats.contains(seatId);
                                    return _SeatItem(
                                      key: ValueKey('seat_${row}_$col'),
                                      seatId: seatId,
                                      isBooked: isBooked,
                                      isSelected: isSelected,
                                      showLabel: col == 0,
                                      onTap: isBooked ? null : () => onSeatSelected(seatId),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Extra padding at the bottom to prevent overlap with checkout bar
                        const SizedBox(height: 120), // Increased bottom padding
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        ],
      ),
    );
  }
}

class _SeatItem extends StatelessWidget {
  final String seatId;
  final bool isBooked;
  final bool isSelected;
  final bool showLabel;
  final VoidCallback? onTap;

  const _SeatItem({
    Key? key,
    required this.seatId,
    required this.isBooked,
    required this.isSelected,
    this.showLabel = false,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Memoize colors to prevent unnecessary rebuilds
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Determine colors based on seat state
    final Color backgroundColor;
    final Color borderColor;
    
    if (isBooked) {
      backgroundColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
      borderColor = Colors.transparent;
    } else if (isSelected) {
      backgroundColor = AppColors.gold;
      borderColor = AppColors.gold;
    } else {
      backgroundColor = isDark ? const Color(0xFF333333) : Colors.grey[200]!;
      borderColor = isDark ? Colors.white24 : Colors.grey[400]!;
    }

    // Use const for static widgets and avoid rebuilding unnecessarily
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 4.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isBooked ? null : onTap,
          splashColor: isBooked ? null : AppColors.gold.withOpacity(0.3),
          borderRadius: BorderRadius.circular(4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Seat top part
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 28,
                height: 24,
                margin: const EdgeInsets.only(bottom: 2),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                    bottom: Radius.circular(2),
                  ),
                  border: Border.all(
                    color: borderColor,
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.gold.withOpacity(0.5),
                            blurRadius: 6,
                            spreadRadius: 1,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: isBooked
                    ? const Center(
                        child: Icon(
                          Icons.block,
                          color: Colors.white38,
                          size: 14,
                        ),
                      )
                    : null,
              ),
              // Seat bottom/armrest part
              Container(
                width: 24,
                height: 4,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.gold.withOpacity(0.7)
                      : (isBooked
                          ? (isDark ? Colors.grey[700]! : Colors.grey[300]!)
                          : (isDark ? Colors.grey[800]! : Colors.grey[300]!)),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: AppColors.gold.withOpacity(0.5),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      )
                  ],
                ),
              ),
              // Seat number (only show for first seat in row for better performance)
              if (showLabel)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    seatId[0],
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
