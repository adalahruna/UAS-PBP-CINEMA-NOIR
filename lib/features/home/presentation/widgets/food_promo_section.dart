// File: lib/features/home/presentation/widgets/food_promo_section.dart

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinema_noir/core/constants/app_colors.dart';

// CARA MENGGUNAKAN:
// 1. Import widget ini di home_page.dart
// 2. Tambahkan setelah section "Akan Tayang":
//    
//    const SizedBox(height: 24.0),
//    const FoodPromoSection(),
//    const SizedBox(height: 24.0),

class FoodPromoSection extends StatelessWidget {
  const FoodPromoSection({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 768;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Yuk, nyemil di m.food',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Promo menarik untuk kamu',
                      style: TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to all promos page
                  print('Navigasi ke semua promo m.food');
                },
                child: const Text(
                  'Lihat semua >',
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16.0),

        // Carousel Promo
        _buildPromoCarousel(context, isMobile: isMobile),
        
        const SizedBox(height: 16.0),

        // CTA Button
        Center(
          child: ElevatedButton(
            onPressed: () {
              // TODO: Navigate to m.food page
              print('Navigasi ke m.food');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkGrey,
              foregroundColor: AppColors.textWhite,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
                side: const BorderSide(
                  color: AppColors.gold,
                  width: 1.5,
                ),
              ),
            ),
            child: const Text(
              'Pesen m.food',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPromoCarousel(BuildContext context, {required bool isMobile}) {
    // Data promo makanan (sesuai dengan referensi gambar)
    final List<FoodPromo> promos = [
      FoodPromo(
        title: 'GLINDA Light-Up Popcorn Bucket',
        subtitle: 'Wicked The Movie',
        imageUrl: 'https://via.placeholder.com/400x250/1B5E20/FFFFFF?text=Glinda+Popcorn+Bucket',
        badge: '450k',
        releaseDate: 'In Cinemas 19 November 2025',
      ),
      FoodPromo(
        title: 'Cashback 25%',
        subtitle: 'Pakai Kartu XXI',
        imageUrl: 'https://via.placeholder.com/400x250/0277BD/FFFFFF?text=Cashback+25%25',
        badge: 'Max 50k',
        releaseDate: null,
      ),
      FoodPromo(
        title: 'Jajan Hemat Reward Nikmat',
        subtitle: 'XXI Rewards',
        imageUrl: 'https://via.placeholder.com/400x250/6A1B9A/FFFFFF?text=XXI+Rewards',
        badge: 'Cashback',
        releaseDate: null,
      ),
    ];

    final double itemsPerView = isMobile ? 1.0 : 3.0;
    final double viewportFraction = isMobile ? 0.88 : (1.0 / itemsPerView);
    final double screenWidth = MediaQuery.of(context).size.width;

    return CarouselSlider.builder(
      itemCount: promos.length,
      itemBuilder: (context, index, realIndex) {
        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: screenWidth * (isMobile ? 0.015 : 0.008),
          ),
          child: _FoodPromoCard(promo: promos[index]),
        );
      },
      options: CarouselOptions(
        height: isMobile ? 200.0 : 180.0,
        autoPlay: true,
        viewportFraction: viewportFraction,
        enlargeCenterPage: false,
        autoPlayInterval: const Duration(seconds: 5),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
      ),
    );
  }
}

// Model untuk data promo
class FoodPromo {
  final String title;
  final String subtitle;
  final String imageUrl;
  final String badge;
  final String? releaseDate;

  FoodPromo({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.badge,
    this.releaseDate,
  });
}

// Widget untuk Card Promo
class _FoodPromoCard extends StatefulWidget {
  final FoodPromo promo;

  const _FoodPromoCard({required this.promo});

  @override
  State<_FoodPromoCard> createState() => _FoodPromoCardState();
}

class _FoodPromoCardState extends State<_FoodPromoCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          print('Promo tapped: ${widget.promo.title}');
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()
            ..scale(_isHovered ? 1.02 : 1.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Stack(
              children: [
                // Background Image
                Positioned.fill(
                  child: CachedNetworkImage(
                    imageUrl: widget.promo.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.darkGrey,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.darkGrey,
                      child: const Icon(
                        Icons.fastfood_outlined,
                        color: AppColors.textGrey,
                        size: 50,
                      ),
                    ),
                  ),
                ),

                // Gradient Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ),

                // Badge (Pojok kanan atas)
                if (widget.promo.badge.isNotEmpty)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.promo.badge,
                        style: const TextStyle(
                          color: AppColors.darkBackground,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                // Content (Bawah)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.promo.subtitle,
                        style: const TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.promo.title,
                        style: const TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.promo.releaseDate != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          widget.promo.releaseDate!,
                          style: const TextStyle(
                            color: AppColors.gold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}