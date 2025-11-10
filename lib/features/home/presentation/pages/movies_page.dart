import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinema_noir/core/api/tmdb_service.dart';
import 'package:cinema_noir/core/constants/app_colors.dart';
import 'package:cinema_noir/features/home/data/models/movie_model.dart';
import 'package:cinema_noir/features/home/presentation/cubit/movie_cubit.dart';
import 'package:cinema_noir/features/home/presentation/cubit/movie_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MoviesPage extends StatefulWidget {
  const MoviesPage({super.key});

  @override
  State<MoviesPage> createState() => _MoviesPageState();
}

class _MoviesPageState extends State<MoviesPage> {
  String _searchQuery = '';

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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              children: [
                _buildSearchField(),
                const SizedBox(height: 16),
                Expanded(
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
                        final filteredNowPlaying = _filterMovies(state.nowPlayingMovies);
                        final filteredUpcoming = _filterMovies(state.upcomingMovies);

                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildMovieSection(
                                title: 'Sedang Tayang',
                                movies: filteredNowPlaying,
                              ),
                              const SizedBox(height: 24),
                              _buildMovieSection(
                                title: 'Akan Tayang',
                                movies: filteredUpcoming,
                              ),
                            ],
                          ),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextField _buildSearchField() {
    return TextField(
      onChanged: (value) {
        setState(() {
          _searchQuery = value.trim().toLowerCase();
        });
      },
      decoration: InputDecoration(
        hintText: 'Cari judul film...',
        hintStyle: const TextStyle(color: AppColors.textGrey),
        prefixIcon: const Icon(Icons.search, color: AppColors.textGrey),
        filled: true,
        fillColor: AppColors.darkGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.gold, width: 2),
        ),
      ),
      style: const TextStyle(color: AppColors.textWhite),
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

  Widget _buildMovieSection({
    required String title,
    required List<MovieModel> movies,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.gold,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (movies.isEmpty)
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
          _MovieGrid(movies: movies),
      ],
    );
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

class _MovieCard extends StatelessWidget {
  final MovieModel movie;

  const _MovieCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkGrey,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: movie.getFullPosterUrl(),
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (context, url) => Container(color: AppColors.darkBackground),
                errorWidget: (context, url, error) => const Icon(
                  Icons.broken_image,
                  color: AppColors.textGrey,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
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
                      movie.voteAverage.toStringAsFixed(1),
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
    );
  }
}

