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
    const rows = 10;
    const cols = 10;

    return Column(
      children: [
        const SizedBox(height: 20),
        // Screen Indicator
        CustomPaint(
          size: const Size(300, 40),
          painter: ScreenPainter(),
        ),
        const SizedBox(height: 10),
        const Text(
          'SCREEN',
          style: TextStyle(
            color: Colors.white38,
            letterSpacing: 4,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 30),
        
        // Seat Grid
        Expanded(
          child: SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Row Labels
                Padding(
                  padding: const EdgeInsets.only(top: 6, right: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List.generate(rows, (rowIndex) {
                      final rowLetter = String.fromCharCode(65 + rowIndex);
                      return Container(
                        height: 36, // Match grid item height + spacing
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          rowLetter,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                // Seats
                SizedBox(
                  width: cols * 36.0, // Approximate width
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: rows * cols,
                    itemBuilder: (context, index) {
                      final rowIndex = index ~/ cols;
                      final colIndex = index % cols;
                      final rowLetter = String.fromCharCode(65 + rowIndex);
                      final seatNumber = colIndex + 1;
                      final seatId = '$rowLetter$seatNumber';

                      final isBooked = bookedSeats.contains(seatId);
                      final isSelected = selectedSeats.contains(seatId);

                      return _SeatItem(
                        seatId: seatId,
                        isBooked: isBooked,
                        isSelected: isSelected,
                        onTap: () => onSeatSelected(seatId),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Legend
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendItem(
                color: AppColors.darkGrey,
                borderColor: AppColors.gold.withOpacity(0.3),
                label: 'Available',
              ),
              const SizedBox(width: 20),
              _LegendItem(
                color: AppColors.gold,
                borderColor: AppColors.gold,
                label: 'Selected',
              ),
              const SizedBox(width: 20),
              _LegendItem(
                color: AppColors.lightGrey,
                borderColor: AppColors.lightGrey,
                label: 'Booked',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SeatItem extends StatelessWidget {
  final String seatId;
  final bool isBooked;
  final bool isSelected;
  final VoidCallback onTap;

  const _SeatItem({
    required this.seatId,
    required this.isBooked,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color borderColor;
    
    if (isBooked) {
      backgroundColor = AppColors.lightGrey.withOpacity(0.3);
      borderColor = Colors.transparent;
    } else if (isSelected) {
      backgroundColor = AppColors.gold;
      borderColor = AppColors.gold;
    } else {
      backgroundColor = AppColors.darkGrey;
      borderColor = AppColors.gold.withOpacity(0.3);
    }

    return GestureDetector(
      onTap: isBooked ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(8),
            bottom: Radius.circular(4),
          ),
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.gold.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: isBooked
            ? const Center(
                child: Icon(Icons.close, color: Colors.white38, size: 14),
              )
            : null,
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final Color borderColor;
  final String label;

  const _LegendItem({
    required this.color,
    required this.borderColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(6),
              bottom: Radius.circular(3),
            ),
            border: Border.all(color: borderColor),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class ScreenPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.gold.withOpacity(0),
          AppColors.gold.withOpacity(0.5),
          AppColors.gold.withOpacity(0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(size.width / 2, -20, size.width, size.height);

    canvas.drawPath(path, paint);
    
    // Glow effect
    final glowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.gold.withOpacity(0.2),
          AppColors.gold.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
      
    final glowPath = Path();
    glowPath.moveTo(0, size.height);
    glowPath.quadraticBezierTo(size.width / 2, -20, size.width, size.height);
    glowPath.close();
    
    canvas.drawPath(glowPath, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}