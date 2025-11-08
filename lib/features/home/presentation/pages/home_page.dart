// File: lib/features/home/presentation/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinema_noir/core/api/tmdb_service.dart';
import 'package:cinema_noir/features/home/presentation/cubit/movie_cubit.dart';
import 'package:cinema_noir/features/home/presentation/cubit/movie_state.dart';
// Import AuthCubit HANYA jika Anda membutuhkannya di halaman profil
// import 'package:cinema_noir/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:cinema_noir/core/constants/app_colors.dart';

// --- TAMBAHAN IMPORT UNTUK MOVIE MODEL ---
import 'package:cinema_noir/features/home/data/models/movie_model.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MovieCubit(TmdbService())..fetchHomeMovies(),
      child: Scaffold(
        // PERBAIKAN: Gunakan backgroundColor di Scaffold
        backgroundColor: AppColors.darkBackground, 
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<MovieCubit, MovieState>(
            builder: (context, state) {
              if (state is MovieLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.gold,
                  ),
                );
              }

              if (state is MovieError) {
                return Center(
                  child: Text(
                    'Gagal mengambil data: ${state.message}',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                );
              }

              if (state is MovieLoaded) {
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCustomHeader(context),
                      const SizedBox(height: 24.0),
                      _buildSearchBar(context),
                      const SizedBox(height: 24.0),
                      _buildIconButtons(),
                      const SizedBox(height: 24.0),
                      // const PosterCarousel(), // Iklan
                      const SizedBox(height: 24.0),

                      // --- SECTION 1: SEDANG TAYANG (AIRED MOVIES) ---
                      _buildSectionHeader(
                        title: 'Sedang Tayang', 
                        onTapSeeAll: () {},
                      ),
                      const SizedBox(height: 16.0),
                      
                      // --- PERBAIKAN: Memanggil widget list horizontal ---
                      _buildHorizontalMovieList(movies: state.nowPlayingMovies),
                      
                      const SizedBox(height: 24.0),

                      // --- SECTION 2: BARU - UPCOMING MOVIES ---
                      _buildSectionHeader(
                        title: 'Akan Tayang', 
                        onTapSeeAll: () {},
                      ),
                      const SizedBox(height: 16.0),
                      
                      // --- PERBAIKAN: Memanggil widget list horizontal ---
                      _buildHorizontalMovieList(movies: state.upcomingMovies),

                      const SizedBox(height: 24.0),

                      // --- SECTION 3: PROMO ---
                      _buildSectionHeader(
                        title: 'Promo menarik untuk kamu',
                        onTapSeeAll: () {},
                      ),
                      const SizedBox(height: 16.0),
                      _buildPromoSection(),

                      const SizedBox(height: 40.0),
                      
                      _buildFooter(),
                    ],
                  ),
                );
              }

              return const Center(child: Text('State tidak dikenal.'));
            },
          ),
        ),
      ),
    );
  }

  // --- WIDGET BARU UNTUK LIST FILM HORIZONTAL ---
  Widget _buildHorizontalMovieList({required List<MovieModel> movies}) {
    // Ambil 10 film pertama saja
    final limitedMovies = movies.take(10).toList();

    return Container(
      // Tentukan tinggi untuk list horizontal
      height: 230, // Cukup untuk poster (180) + teks (50)
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: limitedMovies.length,
        // Padding untuk list agar tidak menempel di tepi kiri/kanan
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemBuilder: (context, index) {
          // Kirim data film ke widget item
          return _MovieListItem(movie: limitedMovies[index]);
        },
      ),
    );
  }
  // --- AKHIR WIDGET BARU ---


  // --- WIDGET-WIDGET HELPER ---

  /// 1. Widget untuk Header (Responsif)
  /// --- PERBAIKAN: Mengganti Logout dengan Promo & Profil ---
  Widget _buildCustomHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              children: [
                const Text(
                  'Cinema Noir',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8.0),
                Flexible(
                  child: TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.location_on_outlined, color: AppColors.textWhite, size: 18),
                    label: const Text(
                      'JABODETABEK',
                      style: TextStyle(color: AppColors.textWhite, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      backgroundColor: AppColors.darkGrey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // --- KONTEN BARU DI KANAN ---
          Row(
            children: [
              // 1. Tombol Promo (BARU)
              IconButton(
                icon: const Icon(Icons.local_offer_outlined, color: AppColors.textWhite),
                tooltip: 'Promo',
                onPressed: () {
                  print('Promo icon pressed!');
                },
              ),
              // 2. Tombol Profil (MENGGANTIKAN LOGOUT)
              IconButton(
                icon: const Icon(Icons.person_outline, color: AppColors.gold),
                tooltip: 'Profile',
                onPressed: () {
                  // Nanti navigasi ke halaman profil
                  print('Profile icon pressed!');
                },
              ),
            ],
          ),
          // --- AKHIR KONTEN BARU ---
        ],
      ),
    );
  }

  /// 2. Widget untuk Search Bar (Responsif)
  Widget _buildSearchBar(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Center( 
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: (screenWidth * 0.85).clamp(0, 600),
        ),
        child: TextField(
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12.0, 
              horizontal: 16.0,
            ),
            hintText: 'Cari film atau bioskop',
            hintStyle: const TextStyle(color: AppColors.textGrey),
            prefixIcon: const Icon(Icons.search, color: AppColors.textGrey),
            filled: true,
            fillColor: AppColors.darkGrey,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: const BorderSide(color: AppColors.gold, width: 2),
            ),
          ),
        ),
      ),
    );
  }

  /// 3. Widget untuk Tombol Ikon Kategori (Layout 5 Ikon Sejajar)
  Widget _buildIconButtons() {
    const double iconSpacing = 12.0; 

    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _CategoryIcon(
          icon: Icons.theaters_outlined,
          label: 'Cinemas',
          onTap: null,
        ),
        SizedBox(width: iconSpacing),
        _CategoryIcon(
          icon: Icons.people_outline,
          label: 'Community',
          onTap: null,
        ),
        SizedBox(width: iconSpacing),
        _CategoryIcon(
          icon: Icons.movie_creation_outlined,
          label: 'Movies',
          onTap: null,
        ),
        SizedBox(width: iconSpacing),
        _CategoryIcon(
          icon: Icons.fastfood_outlined,
          label: 'm.food',
          onTap: null,
        ),
        SizedBox(width: iconSpacing),
        _CategoryIcon(
          icon: Icons.event_seat_outlined,
          label: 'Private Booking',
          onTap: null,
        ),
      ],
    );
  }

  /// 4. Widget untuk Judul Section
  Widget _buildSectionHeader({
    required String title,
    required VoidCallback onTapSeeAll,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.gold,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: onTapSeeAll,
            child: const Text(
              'See all >',
              style: TextStyle(color: AppColors.textGrey, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  /// 5. Section Promo
  Widget _buildPromoSection() {
    final List<String> promoImageUrls = [
      'https://i.imgur.com/gCaq3aJ.png',
      'https://i.imgur.com/c4Y2K0P.png',
      'https://i.imgur.com/kS5x87H.png',
    ];

    const double promoHeight = 140.0;
    const double promoAspectRatio = 16 / 9;

    return Container(
      height: promoHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: promoImageUrls.length,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemBuilder: (context, index) {
          return Container(
            width: promoHeight * promoAspectRatio,
            margin: const EdgeInsets.only(right: 12.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: promoImageUrls[index],
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: AppColors.darkGrey),
                errorWidget: (context, url, error) => Container(color: AppColors.darkGrey),
              ),
            ),
          );
        },
      ),
    );
  }
  
  /// 6. Footer
  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      color: AppColors.darkGrey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cinema Noir',
            style: TextStyle(
              color: AppColors.gold,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24.0),
          
          Wrap(
            spacing: 40.0,
            runSpacing: 24.0,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Profile', style: TextStyle(color: AppColors.textWhite, fontSize: 16)),
                  SizedBox(height: 12.0),
                  Text('Careers', style: TextStyle(color: AppColors.textWhite, fontSize: 16)),
                  SizedBox(height: 12.0),
                  Text('Contact Us', style: TextStyle(color: AppColors.textWhite, fontSize: 16)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Follow Us', style: TextStyle(color: AppColors.textWhite, fontSize: 16)),
                  SizedBox(height: 12.0),
                  Text('Facebook', style: TextStyle(color: AppColors.textGrey, fontSize: 14)),
                  SizedBox(height: 8.0),
                  Text('Instagram', style: TextStyle(color: AppColors.textGrey, fontSize: 14)),
                  SizedBox(height: 8.0),
                  Text('X (Twitter)', style: TextStyle(color: AppColors.textGrey, fontSize: 14)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32.0),
          const Divider(color: AppColors.textGrey),
          const SizedBox(height: 16.0),
          const Text(
            '© 2025 Cinema Noir. All rights reserved.',
            style: TextStyle(color: AppColors.textGrey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// --- WIDGET IKON KATEGORI (Stateful untuk Hover) ---
class _CategoryIcon extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _CategoryIcon({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  State<_CategoryIcon> createState() => _CategoryIconState();
}

class _CategoryIconState extends State<_CategoryIcon> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final Color iconColor = _isHovered ? AppColors.darkGrey : AppColors.gold;
    final Color containerColor = _isHovered ? AppColors.gold : AppColors.darkGrey;
    final Color textColor = _isHovered ? AppColors.gold : AppColors.textGrey;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        onHover: (isHovering) {
          setState(() {
            _isHovered = isHovering;
          });
        },
        splashColor: AppColors.gold.withOpacity(0.1),
        highlightColor: AppColors.gold.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: containerColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(widget.icon, color: iconColor, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              widget.label,
              style: TextStyle(color: textColor, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// --- WIDGET BARU UNTUK SATU ITEM FILM ---
// (Saya letakkan di luar class HomePage agar rapi)
class _MovieListItem extends StatelessWidget {
  final MovieModel movie;
  const _MovieListItem({required this.movie});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Nanti: Navigasi ke detail
        print('Navigasi ke film ${movie.title}');
      },
      child: Container(
        width: 140, // Lebar tetap untuk setiap item
        margin: const EdgeInsets.only(right: 12.0), // Jarak antar item
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                // Asumsi MovieModel punya method getFullPosterUrl()
                // Jika tidak, ganti dengan: '${ApiConstants.tmdbImageBaseUrl}${movie.posterPath}'
                imageUrl: movie.getFullPosterUrl(), 
                fit: BoxFit.cover,
                height: 180, // Tinggi poster
                width: 140, // Lebar poster
                placeholder: (context, url) => Container(
                  height: 180,
                  width: 140,
                  color: AppColors.darkGrey,
                ),
                errorWidget: (context, url, error) => Container(
                  height: 180,
                  width: 140,
                  color: AppColors.darkGrey,
                  child: const Icon(Icons.error, color: AppColors.textGrey),
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            // Judul
            Text(
              movie.title, // Asumsi MovieModel punya properti title
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}