import 'package:flutter/material.dart';
import 'package:cinema_noir/core/constants/app_colors.dart';

class FoodCategoryButtons extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const FoodCategoryButtons({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final List<Map<String, dynamic>> categories = const [
    {'id': 'all', 'label': 'All', 'icon': Icons.restaurant_menu},
    {'id': 'combo', 'label': 'Combo', 'icon': Icons.fastfood},
    {'id': 'popcorn', 'label': 'Popcorn', 'icon': Icons.grain},
    {'id': 'drink', 'label': 'Drinks', 'icon': Icons.local_drink},
    {'id': 'snack', 'label': 'Snacks', 'icon': Icons.lunch_dining},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      // Menggunakan Center dan SingleChildScrollView agar tombol berada di tengah
      // tapi tetap bisa di-scroll jika layar terlalu kecil/sempit.
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize:
                MainAxisSize.min, // Agar Row menyesuaikan lebar konten
            children: categories.map((cat) {
              final isSelected = selectedCategory == cat['id'];
              // Tambahkan jarak antar item (kecuali item terakhir)
              final isLast = cat == categories.last;

              return Padding(
                padding: EdgeInsets.only(right: isLast ? 0 : 16),
                child: GestureDetector(
                  onTap: () => onCategorySelected(cat['id']),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.gold
                              : AppColors.darkGrey,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: AppColors.gold.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                          ],
                          border: Border.all(
                            color: isSelected ? AppColors.gold : Colors.white10,
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          cat['icon'],
                          color: isSelected ? Colors.black : AppColors.textGrey,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cat['label'],
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.gold
                              : AppColors.textGrey,
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
