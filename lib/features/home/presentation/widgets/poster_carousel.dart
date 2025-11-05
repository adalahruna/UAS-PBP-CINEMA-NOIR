import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sizer/sizer.dart';
import 'package:cinema_noir/features/home/data/models/movie_model.dart';
import 'package:cinema_noir/core/constants/app_colors.dart';

class PosterCarousel extends StatelessWidget {
  final List<MovieModel> movies;
  const PosterCarousel({super.key, required this.movies});

  @override
  Widget build(BuildContext context) {
    // Ambil film (misal: 5 film pertama) untuk carousel
    // Kita ambil dari 'nowPlayingMovies' yang memiliki poster
    final List<MovieModel> carouselMovies = movies
        .where((movie) => movie.posterPath != null)
        .take(5)
        .toList();

    return CarouselSlider.builder(
      itemCount: carouselMovies.length,
      itemBuilder: (context, index, realIndex) {
        final movie = carouselMovies[index];
        return _CarouselItem(movie: movie);
      },
      options: CarouselOptions(
        // Tinggi carousel
        height: 55.h,
        // Poster di tengah akan terlihat lebih besar
        enlargeCenterPage: true,
        // Rasio aspek poster film
        aspectRatio: 9 / 16,
        // Auto play (berputar otomatis)
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 4),
        // Mengisi viewport
        viewportFraction: 0.7,
      ),
    );
  }
}

// Widget internal untuk satu item di carousel
class _CarouselItem extends StatelessWidget {
  final MovieModel movie;
  const _CarouselItem({required this.movie});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Nanti: Navigasi ke halaman detail film
        // context.push('/movie/${movie.id}');
        print('Navigasi ke film ${movie.title}');
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // --- Gambar Poster ---
            // Kita pakai CachedNetworkImage agar gambar di-cache
            CachedNetworkImage(
              imageUrl: movie.getFullPosterUrl(),
              fit: BoxFit.cover,
              width: 100.w, // Ambil lebar penuh
              placeholder: (context, url) => Container(
                color: AppColors.darkGrey,
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.gold),
                ),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),

            // --- Gradient Hitam di Bawah ---
            // Untuk membuat judul terlihat jelas
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 25.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppColors.darkBackground.withOpacity(0.8),
                      AppColors.darkBackground,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // --- Judul Film ---
            Positioned(
              bottom: 4.h, // Padding dari bawah
              left: 5.w,
              right: 5.w,
              child: Text(
                movie.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
