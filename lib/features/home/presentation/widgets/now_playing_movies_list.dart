// File: lib/features/home/presentation/widgets/now_playing_movies_list.dart
// (Ini adalah file yang SEBELUMNYA bernama upcoming_movies_carousel.dart)

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinema_noir/features/home/data/models/movie_model.dart';
import 'package:cinema_noir/core/constants/app_colors.dart';

class NowPlayingMoviesList extends StatelessWidget {
  final List<MovieModel> movies;
  const NowPlayingMoviesList({super.key, required this.movies});

  // Tentukan ukuran poster (sesuai ref image_830509.jpg)
  final double _itemHeight = 240.0;
  final double _itemWidth = 160.0;
  final double _itemMargin = 16.0;

  @override
  Widget build(BuildContext context) {
    // 1. Batasi daftar hanya 4 film
    final List<MovieModel> displayMovies = movies
        .where((m) => m.posterPath != null) 
        .take(4) 
        .toList();

    // 2. Logika untuk membuat 4 poster di tengah
    final double screenWidth = MediaQuery.of(context).size.width;
    final double contentWidth = (displayMovies.length * _itemWidth) + 
                              ((displayMovies.length - 1) * _itemMargin);
    double horizontalPadding = (screenWidth - contentWidth) / 2;
    if (horizontalPadding < 16.0) {
      horizontalPadding = 16.0;
    }

    return Container(
      height: _itemHeight, // Tinggi container = tinggi poster
      child: ListView.builder(
        scrollDirection: Axis.horizontal, 
        itemCount: displayMovies.length,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        itemBuilder: (context, index) {
          final movie = displayMovies[index];

          return Container(
            width: _itemWidth,
            height: _itemHeight,
            margin: EdgeInsets.only(right: (index == displayMovies.length - 1) ? 0 : _itemMargin),
            child: GestureDetector(
              onTap: () => print('Navigasi ke film ${movie.title}'),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: movie.getFullPosterUrl(),
                      fit: BoxFit.cover,
                      width: _itemWidth,
                      height: _itemHeight,
                      placeholder: (context, url) => Container(color: AppColors.darkGrey),
                      errorWidget: (context, url, error) => Container(color: AppColors.darkGrey),
                    ),
                  ),
                  // Tag "Advance ticket sales"
                  Positioned(
                    top: 8.0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      decoration: const BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Advance ticket sales',
                        style: TextStyle(
                          color: AppColors.darkBackground,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}