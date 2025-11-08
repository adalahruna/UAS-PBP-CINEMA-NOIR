// File: lib/features/home/presentation/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
// Impor CarouselSlider secara penuh (bukan sebagai alias)
import 'package:carousel_slider/carousel_slider.dart'; 
import 'package:cinema_noir/core/api/tmdb_service.dart';
import 'package:cinema_noir/features/home/presentation/cubit/movie_cubit.dart';
import 'package:cinema_noir/features/home/presentation/cubit/movie_state.dart';
import 'package:cinema_noir/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:cinema_noir/core/constants/app_colors.dart';
import 'package:cinema_noir/features/home/data/models/movie_model.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MovieCubit(TmdbService())..fetchHomeMovies(),
      child: Scaffold(
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
                // --- DETEKSI UKURAN LAYAR ---
                final double screenWidth = MediaQuery.of(context).size.width;
                final bool isMobile = screenWidth < 768; // Breakpoint

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
                      
                      _buildAdsCarousel(context, isMobile: isMobile), // Kirim isMobile
                      
                      const SizedBox(height: 24.0),

                      // --- SECTION 1: SEDANG TAYANG (HOVERABLE LIST) ---
                      _buildSectionHeader(
                        title: 'Sedang Tayang',
                        onTapSeeAll: () {},
                      ),
                      const SizedBox(height: 16.0),
                      
                      // WIDGET BARU: Hoverable List
                      _buildCenteredSwipeableMovieList(
                        movies: state.nowPlayingMovies,
                        isMobile: isMobile, 
                      ),
                      
                      const SizedBox(height: 24.0),

                      // --- SECTION 2: UPCOMING MOVIES ---
                      _buildSectionHeader(
                        title: 'Akan Tayang',
                        onTapSeeAll: () {},
                      ),
                      const SizedBox(height: 16.0),

                      _buildHorizontalMovieList(movies: state.upcomingMovies),

                      const SizedBox(height: 24.0),
                      
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

  // --- WIDGET BARU: CENTERED SWIPEABLE MOVIE LIST ---
  Widget _buildCenteredSwipeableMovieList({
    required List<MovieModel> movies,
    required bool isMobile,
  }) {
    // Ambil 10 film agar bisa di-scroll
    final limitedMovies = movies.take(10).toList(); 
    return _HoverableMovieList(
      movies: limitedMovies,
      isMobile: isMobile, // Teruskan ke widget stateful
    );
  }

  // --- WIDGET ADS CAROUSEL ---
  Widget _buildAdsCarousel(BuildContext context, {required bool isMobile}) {
    final List<String> adImages = [
      'https://via.placeholder.com/600x350/9C27B0/FFFFFF?text=Iklan+Satu',
      'https://via.placeholder.com/600x350/2E7D32/FFFFFF?text=Iklan+Dua',
      'https://via.placeholder.com/600x350/9C27B0/FFFFFF?text=Iklan+Tiga',
      'https://via.placeholder.com/600x350/BF360C/FFFFFF?text=Iklan+Empat',
    ];
    
    final double itemsPerView = isMobile ? 1.0 : 3.0;
    final double viewportFraction = isMobile ? 0.85 : (1.0 / itemsPerView);
    final double screenWidth = MediaQuery.of(context).size.width;


    return CarouselSlider.builder(
      itemCount: adImages.length,
      itemBuilder: (context, index, realIndex) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: screenWidth * (isMobile ? 0.02 : 0.01)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: CachedNetworkImage(
              imageUrl: adImages[index],
              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (context, url) => Container(color: AppColors.darkGrey),
              errorWidget: (context, url, error) => Container(color: AppColors.darkGrey),
            ),
          ),
        );
      },
      options: CarouselOptions(
        height: 140.0,
        autoPlay: true,
        viewportFraction: viewportFraction,
        enlargeCenterPage: isMobile, // Hanya perbesar di mobile
        autoPlayInterval: const Duration(seconds: 30),
      ),
    );
  }

  // --- WIDGET HORIZONTAL MOVIE LIST (untuk Upcoming) ---
  Widget _buildHorizontalMovieList({required List<MovieModel> movies}) {
    final limitedMovies = movies.take(10).toList();

    return Container(
      height: 230,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: limitedMovies.length,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemBuilder: (context, index) {
          return _UpcomingMovieItem(movie: limitedMovies[index]);
        },
      ),
    );
  }

  // --- WIDGET HELPER ---
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
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.local_offer_outlined, color: AppColors.textWhite),
                tooltip: 'Promo',
                onPressed: () {
                  print('Promo icon pressed!');
                },
              ),
              IconButton(
                icon: const Icon(Icons.person_outline, color: AppColors.gold),
                tooltip: 'Profile',
                onPressed: () {
                  print('Profile icon pressed!');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

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

// --- WIDGET IKON KATEGORI ---
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

// --- WIDGET HOVERABLE MOVIE LIST DENGAN ARROW ---
class _HoverableMovieList extends StatefulWidget {
  final List<MovieModel> movies;
  final bool isMobile; 
  const _HoverableMovieList({
    required this.movies,
    required this.isMobile,
  });

  @override
  State<_HoverableMovieList> createState() => _HoverableMovieListState();
}

class _HoverableMovieListState extends State<_HoverableMovieList> {
  // Controller untuk Desktop ListView
  final ScrollController _scrollController = ScrollController();
  
  // Controller untuk Mobile Carousel
  final CarouselSliderController _mobileCarouselController = CarouselSliderController();

  bool _isHovered = false;
  bool _canScrollLeft = false;
  bool _canScrollRight = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollButtons);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScrollButtons();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollButtons);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollButtons() {
    if (!mounted) return;
    
    if (!widget.isMobile) {
      bool hasOverflow = widget.movies.length > 4; 
      setState(() {
        _canScrollLeft = hasOverflow && _scrollController.hasClients && _scrollController.offset > 0;
        _canScrollRight = hasOverflow && _scrollController.hasClients && 
                          _scrollController.offset < _scrollController.position.maxScrollExtent;
      });
    }
  }

  void _scrollLeft() {
    final double scrollAmount = 216.0; // 200 (item width) + 16 (spacing)
    _scrollController.animateTo(
      (_scrollController.offset - scrollAmount).clamp(0.0, double.infinity),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight() {
    final double scrollAmount = 216.0; // 200 (item width) + 16 (spacing)
    final double maxScroll = _scrollController.position.maxScrollExtent;
    _scrollController.animateTo(
      (_scrollController.offset + scrollAmount).clamp(0.0, maxScroll),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }


  @override
  Widget build(BuildContext context) {
    
    // ---------------------------------
    // --- TAMPILAN MOBILE ---
    // ---------------------------------
    if (widget.isMobile) {
      return SizedBox(
        height: 290, // Samakan tinggi
        child: CarouselSlider.builder(
          carouselController: _mobileCarouselController, 
          itemCount: widget.movies.length, // Tampilkan semua 10 film
          itemBuilder: (context, index, realIndex) {
            // Beri sedikit margin agar tidak terlalu mepet
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: _NowPlayingMovieItem(
                movie: widget.movies[index],
                index: index,
              ),
            );
          },
          options: CarouselOptions(
            height: 290,
            autoPlay: false,
            enlargeCenterPage: true,
            viewportFraction: 0.65, 
          ),
        ),
      );
    } 
    
    // ---------------------------------
    // --- TAMPILAN DESKTOP ---
    // ---------------------------------
    else {
      final double itemWidth = 200.0;
      final double itemSpacing = 16.0;
      final int visibleItems = 4;
      final double totalVisibleWidth = (itemWidth * visibleItems) + (itemSpacing * (visibleItems - 1));

      return Center(
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: Container(
            height: 290, 
            child: Row(
              mainAxisSize: MainAxisSize.min, 
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                
                AnimatedOpacity(
                  opacity: _isHovered && _canScrollLeft ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: _HoverArrowButton(
                    icon: Icons.arrow_back_ios,
                    onPressed: _isHovered && _canScrollLeft ? _scrollLeft : null, 
                  ),
                ),

                const SizedBox(width: 8), 

                SizedBox(
                  width: totalVisibleWidth, 
                  child: ClipRect( 
                    child: ListView.builder(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.zero, 
                      itemCount: widget.movies.length, 
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(
                            right: (index == widget.movies.length - 1) ? 0 : itemSpacing,
                          ),
                          child: SizedBox(
                            width: itemWidth, 
                            child: _NowPlayingMovieItem(
                              movie: widget.movies[index],
                              index: index,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(width: 8), 

                AnimatedOpacity(
                  opacity: _isHovered && _canScrollRight ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: _HoverArrowButton(
                    icon: Icons.arrow_forward_ios,
                    onPressed: _isHovered && _canScrollRight ? _scrollRight : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}


// --- WIDGET ARROW BUTTON UNTUK HOVER ---
class _HoverArrowButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed; 

  const _HoverArrowButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  State<_HoverArrowButton> createState() => _HoverArrowButtonState();
}

class _HoverArrowButtonState extends State<_HoverArrowButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isActive = widget.onPressed != null;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isActive 
            ? (_isHovered ? AppColors.gold : AppColors.gold.withOpacity(0.8))
            : AppColors.gold.withOpacity(0.0), // Transparan jika disabled
          shape: BoxShape.circle,
          boxShadow: isActive ? [ 
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ] : [],
        ),
        child: IconButton(
          icon: Icon(widget.icon, color: AppColors.darkBackground),
          onPressed: widget.onPressed,
          iconSize: 24,
          padding: const EdgeInsets.all(12),
          disabledColor: AppColors.darkBackground.withOpacity(0.5), 
        ),
      ),
    );
  }
}

// =========================================================================
// --- INI ADALAH WIDGET DENGAN PERBAIKAN OVERFLOW ---
// =========================================================================
class _NowPlayingMovieItem extends StatelessWidget {
  final MovieModel movie;
  final int index;
  
  const _NowPlayingMovieItem({
    required this.movie,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('Navigasi ke film ${movie.title}');
      },
      // Hapus Column, ganti dengan Container
      child: Container(
        // Bungkus langsung dengan Stack
        child: Stack(
          children: [
            // Gunakan Positioned.fill agar gambar mengisi seluruh area
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: movie.getFullPosterUrl(),
                  fit: BoxFit.cover,
                  // HAPUS height: 260
                  placeholder: (context, url) => Container(
                    // HAPUS height: 260
                    color: AppColors.darkGrey,
                  ),
                  errorWidget: (context, url, error) => Container(
                    // HAPUS height: 260
                    color: AppColors.darkGrey,
                    child: const Icon(Icons.error, color: AppColors.textGrey),
                  ),
                ),
              ),
            ),
            // Tag "Advance ticket sales"
            Positioned(
              top: 12,
              left: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: const Text(
                  'Advance ticket sales',
                  style: TextStyle(
                    color: AppColors.darkBackground,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Nomor urut di pojok kanan atas
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- WIDGET ITEM FILM (untuk Akan Tayang - UKURAN NORMAL) ---
class _UpcomingMovieItem extends StatelessWidget {
  final MovieModel movie;
  const _UpcomingMovieItem({required this.movie});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('Navigasi ke film ${movie.title}');
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: movie.getFullPosterUrl(), 
                fit: BoxFit.cover,
                height: 180,
                width: 140,
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
            Text(
              movie.title, 
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