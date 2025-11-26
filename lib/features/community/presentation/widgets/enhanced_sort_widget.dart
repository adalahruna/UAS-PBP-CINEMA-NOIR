// lib/features/community/presentation/widgets/enhanced_sort_widget.dart

import 'package:flutter/material.dart';
import 'package:cinema_noir/core/constants/app_colors.dart';
import 'package:cinema_noir/features/community/data/models/genre_model.dart';

class EnhancedSortWidget extends StatelessWidget {
  final SortType selectedSort;
  final int? selectedGenreId;
  final List<GenreModel> genres;
  final Function(SortType) onSortChanged;
  final Function(int?) onGenreChanged;
  final bool isLoadingGenres;

  const EnhancedSortWidget({
    super.key,
    required this.selectedSort,
    required this.selectedGenreId,
    required this.genres,
    required this.onSortChanged,
    required this.onGenreChanged,
    this.isLoadingGenres = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final padding = isSmallScreen ? 12.0 : 16.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row for Sorting (Compact)
          Row(
            children: [
              Text(
                'Sort by:',
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 12),
              // Compact Dropdown
              Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.darkGrey,
                  borderRadius: BorderRadius.circular(20), // Rounded like a chip
                  border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<SortType>(
                    value: selectedSort,
                    dropdownColor: AppColors.darkGrey,
                    icon: const Icon(Icons.arrow_drop_down, color: AppColors.gold, size: 20),
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    onChanged: (SortType? newValue) {
                      if (newValue != null) {
                        onSortChanged(newValue);
                      }
                    },
                    items: [
                      SortType.alphabetAZ,
                      SortType.alphabetZA,
                      SortType.popular,
                      SortType.topRated,
                      SortType.trending,
                    ].map<DropdownMenuItem<SortType>>((SortType value) {
                      return DropdownMenuItem<SortType>(
                        value: value,
                        child: Text(value.displayName),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 12),
          
          // Genre List
          SizedBox(
            height: 32, // Compact height for genre chips
            child: isLoadingGenres
                ? _buildLoadingGenres()
                : _buildGenreList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingGenres() {
    return Row(
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            color: AppColors.gold,
            strokeWidth: 2,
          ),
        ),
        SizedBox(width: 8),
        Text(
          'Loading genres...',
          style: TextStyle(
            color: AppColors.textGrey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildGenreList() {
    final allItems = [
      _GenreItem(id: null, name: 'All Genres'),
      ...genres.where((g) => g.name.isNotEmpty).map(
        (g) => _GenreItem(id: g.id, name: g.name),
      ),
    ];

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: allItems.length,
      separatorBuilder: (context, index) => SizedBox(width: 8),
      itemBuilder: (context, index) {
        final item = allItems[index];
        final isSelected = selectedGenreId == item.id;
        
        return _buildSortChip(
          context,
          label: item.name,
          isSelected: isSelected,
          onTap: () {
            try {
              onGenreChanged(item.id);
            } catch (e) {
              debugPrint('Error changing genre: ');
            }
          },
        );
      },
    );
  }

  Widget _buildSortChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gold : AppColors.darkGrey,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.gold : AppColors.gold.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.gold.withOpacity(0.3),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.darkBackground : AppColors.textWhite,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _GenreItem {
  final int? id;
  final String name;
  
  _GenreItem({this.id, required this.name});
}
