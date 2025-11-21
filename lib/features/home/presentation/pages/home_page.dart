import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

// --- Import Core & Cubit ---
import 'package:cinema_noir/core/constants/app_colors.dart';
import 'package:cinema_noir/core/api/tmdb_service.dart';
import 'package:cinema_noir/features/home/presentation/cubit/movie_cubit.dart';
import 'package:cinema_noir/features/home/presentation/cubit/movie_state.dart';
import 'package:cinema_noir/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:cinema_noir/features/home/data/models/movie_model.dart';

// --- IMPORT WIDGET TERPISAH (PENTING!) ---
import 'package:cinema_noir/features/home/presentation/widgets/poster_carousel.dart';
import 'package:cinema_noir/features/home/presentation/widgets/food_promo_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MovieCubit(TmdbService())..fetchHomeMovies(),
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        appBar: _buildAppBar(context),
        body: BlocBuilder<MovieCubit, MovieState>(
          builder: (context, state) {
            // 1. LOADING
            if (state is MovieLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              );
            }

            // 2. ERROR
            if (state is MovieError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<MovieCubit>().fetchHomeMovies(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                      ),
                      child: const Text(
                        'Coba Lagi',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              );
            }

            // 3. SUCCESS (LOADED)
            if (state is MovieLoaded) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // A. Search Bar
                    _buildSearchBar(),

                    // B. Menu Categories (ADA TOMBOL m.food DI SINI)
                    _buildCategories(context),

                    const SizedBox(height: 24),

                    // C. Now Playing (Poster Carousel Widget)
                    // Kita pakai widget terpisah PosterCarousel
                    PosterCarousel(movies: state.nowPlayingMovies),

                    const SizedBox(height: 24),

                    // D. Food Promo Section (Widget Terpisah)
                    const FoodPromoSection(),

                    const SizedBox(height: 24),

                    // E. Coming Soon List
                    _buildSectionHeader(
                      'Coming Soon',
                      () => context.push('/movies'),
                    ),
                    const SizedBox(height: 16),
                    _buildUpcomingList(context, state.upcomingMovies),

                    const SizedBox(height: 40), // Bottom padding
                  ],
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  // --- APP BAR ---
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: 'Cinema ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
              ),
            ),
            TextSpan(
              text: 'Noir',
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: AppColors.gold),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: AppColors.gold),
          onPressed: () {
            context.read<AuthCubit>().logout();
          },
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  // --- SEARCH BAR ---
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.darkGrey,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white10),
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Cari film, bioskop...',
            hintStyle: TextStyle(color: AppColors.textGrey),
            prefixIcon: Icon(Icons.search, color: AppColors.gold),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        ),
      ),
    );
  }

  // --- MENU CATEGORIES (DENGAN m.food) ---
  Widget _buildCategories(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _CategoryIcon(
            icon: Icons.movie_filter_outlined,
            label: 'Movies',
            onTap: () => context.push('/movies'),
          ),
          _CategoryIcon(
            icon: Icons.location_city_outlined,
            label: 'Cinemas',
            onTap: () => context.push('/cinemas'),
          ),

          // --- TOMBOL m.food (BARU) ---
          _CategoryIcon(
            icon: Icons.fastfood_outlined,
            label: 'm.food',
            onTap: () => context.push('/food'), // Arahkan ke /food
          ),

          // ---------------------------
          _CategoryIcon(
            icon: Icons.person_outline,
            label: 'Profile',
            onTap: () => context.push('/profile'),
          ),
        ],
      ),
    );
  }

  // --- SECTION HEADER ---
  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: onSeeAll,
            child: const Text(
              'See All',
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UPCOMING LIST (HORIZONTAL) ---
  Widget _buildUpcomingList(BuildContext context, List<MovieModel> movies) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 20),
        scrollDirection: Axis.horizontal,
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return GestureDetector(
            onTap: () => context.push('/movie-ticket', extra: movie),
            child: Container(
              width: 140,
              margin: const EdgeInsets.only(right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: CachedNetworkImage(
                        imageUrl: movie.getFullPosterUrl(),
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(color: AppColors.darkGrey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    movie.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Coming Soon',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
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

// --- WIDGET ICON KATEGORI ---
class _CategoryIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CategoryIcon({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.darkGrey,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppColors.gold.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: AppColors.gold, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
