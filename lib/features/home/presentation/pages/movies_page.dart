import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinema_noir/core/api/tmdb_service.dart';
import 'package:cinema_noir/core/constants/app_colors.dart';
import 'package:cinema_noir/features/home/data/models/movie_model.dart';
import 'package:cinema_noir/features/home/presentation/cubit/movie_cubit.dart';
import 'package:cinema_noir/features/home/presentation/cubit/movie_state.dart';
import 'package:cinema_noir/features/home/presentation/widgets/trailer_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class MoviesPage extends StatefulWidget {
  final bool showNowPlaying;

  const MoviesPage({
    super.key,
    this.showNowPlaying = true,
  });

  @override
  State<MoviesPage> createState() => _MoviesPageState();
}

class _MoviesPageState extends State<MoviesPage> {
  String _searchQuery = '';
  late bool _showNowPlaying;

  @override
  void initState() {
    super.initState();
    _showNowPlaying = widget.showNowPlaying;
  }

  @override
  void didUpdateWidget(covariant MoviesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showNowPlaying != widget.showNowPlaying) {
      setState(() {
        _showNowPlaying = widget.showNowPlaying;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MovieCubit(TmdbService())..fetchHomeMovies(),
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        appBar: AppBar(
          backgroundColor: AppColors.darkBackground,
          elevation: 0,
          title: const Text(
            'Movies',
            style: TextStyle(
              color: AppColors.gold,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: const IconThemeData(color: AppColors.gold),
        ),
        body: SafeArea(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.darkBackground,
                  Color(0xFF1C1B19),
                ],
              ),
            ),
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
                      'Gagal memuat film: ${state.message}',
                      style: const TextStyle(color: Colors.redAccent),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                if (state is MovieLoaded) {
                  final movies = _showNowPlaying
                      ? state.nowPlayingMovies
                      : state.upcomingMovies;
                  final filteredMovies = _filterMovies(movies);
                  final sectionTitle =
                      _showNowPlaying ? 'Sedang Tayang' : 'Akan Tayang';

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        const Text(
                          'Film',
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildCategoryToggle(),
                        const SizedBox(height: 20),
                        _buildSearchField(context),
                        const SizedBox(height: 24),
                        Text(
                          sectionTitle,
                          style: const TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (filteredMovies.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            decoration: BoxDecoration(
                              color: AppColors.darkGrey,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Text(
                                'Tidak ada film yang cocok.',
                                style: TextStyle(color: AppColors.textGrey),
                              ),
                            ),
                          )
                        else
                          _MovieGrid(movies: filteredMovies),
                      ],
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _CategoryToggleButton(
          label: 'Lagi tayang',
          isActive: _showNowPlaying,
          onTap: () {
            if (!_showNowPlaying) {
              setState(() {
                _showNowPlaying = true;
              });
            }
          },
        ),
        const SizedBox(width: 12),
        _CategoryToggleButton(
          label: 'Akan tayang',
          isActive: !_showNowPlaying,
          onTap: () {
            if (_showNowPlaying) {
              setState(() {
                _showNowPlaying = false;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildSearchField(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double width = screenWidth < 400 ? screenWidth * 0.85 : 320;

    return Center(
      child: SizedBox(
        width: width,
        child: TextField(
          onChanged: (value) {
            setState(() {
              _searchQuery = value.trim().toLowerCase();
            });
          },
          decoration: InputDecoration(
            hintText: 'Cari film',
            hintStyle: const TextStyle(color: AppColors.textGrey),
            prefixIcon: const Icon(Icons.search, color: AppColors.textGrey),
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            filled: true,
            fillColor: AppColors.darkGrey,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: const BorderSide(color: AppColors.gold, width: 2),
            ),
          ),
          style: const TextStyle(color: AppColors.textWhite),
        ),
      ),
    );
  }

  List<MovieModel> _filterMovies(List<MovieModel> movies) {
    if (_searchQuery.isEmpty) {
      return movies;
    }

    return movies
        .where((movie) => movie.title.toLowerCase().contains(_searchQuery))
        .toList();
  }
}

class _MovieGrid extends StatelessWidget {
  final List<MovieModel> movies;

  const _MovieGrid({required this.movies});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _resolveCrossAxisCount(constraints.maxWidth);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: movies.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.6,
          ),
          itemBuilder: (context, index) {
            return _MovieCard(movie: movies[index]);
          },
        );
      },
    );
  }

  int _resolveCrossAxisCount(double maxWidth) {
    if (maxWidth >= 1200) return 5;
    if (maxWidth >= 992) return 4;
    if (maxWidth >= 768) return 3;
    return 2;
  }
}

class _CategoryToggleButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _CategoryToggleButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _MovieCard extends StatelessWidget {
  final MovieModel movie;

  const _MovieCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    return _MovieCardBody(movie: movie);
  }
}

class _MovieCardBody extends StatefulWidget {
  final MovieModel movie;

  const _MovieCardBody({required this.movie});

  @override
  State<_MovieCardBody> createState() => _MovieCardBodyState();
}

class _MovieCardBodyState extends State<_MovieCardBody> {
  bool _isHovered = false;
  bool _isLoadingTrailer = false;

  Future<void> _showTrailer() async {
    if (_isLoadingTrailer) return;

    setState(() {
      _isLoadingTrailer = true;
    });

    try {
      final tmdbService = TmdbService();
      final trailerKey = await tmdbService.getMovieTrailer(widget.movie.id);

      if (!mounted) return;

      setState(() {
        _isLoadingTrailer = false;
      });

      if (trailerKey != null) {
        showDialog(
          context: context,
          builder: (context) => TrailerDialog(
            trailerKey: trailerKey,
            movieTitle: widget.movie.title,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Trailer tidak tersedia untuk film ini'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingTrailer = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat trailer: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: _showTrailer,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.darkGrey,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: CachedNetworkImage(
                        imageUrl: widget.movie.getFullPosterUrl(),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (context, url) => Container(color: AppColors.darkBackground),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.broken_image,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ),
                    if (_isHovered || _isLoadingTrailer)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.black.withOpacity(0.65),
                          ),
                          child: Center(
                            child: _isLoadingTrailer
                                ? const CircularProgressIndicator(
                                    color: AppColors.gold,
                                  )
                                : Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: _showTrailer,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.gold,
                                          foregroundColor: AppColors.darkBackground,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                        ),
                                        icon: const Icon(Icons.play_arrow),
                                        label: const Text(
                                          'Nonton Trailer',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      OutlinedButton.icon(
                                        onPressed: () => context.push(
                                          '/movies/${widget.movie.id}/ticket',
                                          extra: widget.movie,
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColors.gold,
                                          side: const BorderSide(color: AppColors.gold, width: 2),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                          backgroundColor: Colors.black.withOpacity(0.4),
                                        ),
                                        icon: const Icon(Icons.confirmation_number_outlined),
                                        label: const Text(
                                          'Beli Tiket',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.movie.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: AppColors.gold, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          widget.movie.voteAverage.toStringAsFixed(1),
                          style: const TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

