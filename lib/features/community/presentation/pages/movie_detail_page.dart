// lib/features/community/presentation/pages/movie_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cinema_noir/core/constants/app_colors.dart';
import 'package:cinema_noir/features/home/data/models/movie_model.dart';
import 'package:cinema_noir/features/community/data/models/movie_detail_model.dart';
import 'package:cinema_noir/features/community/presentation/cubit/movie_detail_cubit.dart';
import 'package:cinema_noir/features/community/data/repositories/community_repository.dart';
import 'package:cinema_noir/features/community/presentation/widgets/rating_dialog.dart';
import 'package:cinema_noir/features/community/presentation/widgets/trailer_dialog.dart';

class MovieDetailPage extends StatelessWidget {
  final MovieModel movie;

  const MovieDetailPage({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MovieDetailCubit(CommunityRepository())
        ..loadMovieDetail(movie.id),
      child: _MovieDetailView(movie: movie),
    );
  }
}

class _MovieDetailView extends StatelessWidget {
  final MovieModel movie;

  const _MovieDetailView({required this.movie});

  void _showRatingDialog(BuildContext context, MovieDetailModel movieDetail) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<MovieDetailCubit>(),
        child: RatingDialog(movieDetail: movieDetail),
      ),
    );
  }

  void _showTrailer(BuildContext context, String trailerKey, String movieTitle) {
    showDialog(
      context: context,
      builder: (context) => TrailerDialog(
        trailerKey: trailerKey,
        movieTitle: movieTitle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isLargeScreen = screenSize.width > 768;
    
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: BlocBuilder<MovieDetailCubit, MovieDetailState>(
        builder: (context, state) {
          if (state is MovieDetailLoading) {
            return _buildLoadingWidget();
          }

          if (state is MovieDetailError) {
            return _buildErrorWidget(context, state.message);
          }

          if (state is MovieDetailLoaded) {
            return _buildDetailContent(context, state, isLargeScreen);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.gold),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.grey, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Error loading movie details',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(color: AppColors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<MovieDetailCubit>().refresh(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.darkBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailContent(BuildContext context, MovieDetailLoaded state, bool isLargeScreen) {
    final movieDetail = state.movieDetail;
    
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(context, movieDetail, isLargeScreen),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(isLargeScreen ? 24.0 : 16.0),
            child: isLargeScreen 
                ? _buildLargeScreenContent(context, state)
                : _buildMobileContent(context, state),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(BuildContext context, MovieDetailModel movieDetail, bool isLargeScreen) {
    final appBarHeight = isLargeScreen ? 400.0 : 300.0;
    
    return SliverAppBar(
      expandedHeight: appBarHeight,
      pinned: true,
      backgroundColor: AppColors.darkBackground,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios, color: AppColors.white, size: 20),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: movieDetail.getFullBackdropUrl(),
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => Container(
                color: AppColors.darkGrey,
                child: const Icon(Icons.broken_image, color: AppColors.grey, size: 64),
              ),
            ),
            Container(
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
            if (movieDetail.trailerKey != null)
              Positioned(
                bottom: 24,
                right: 24,
                child: FloatingActionButton(
                  onPressed: () => _showTrailer(context, movieDetail.trailerKey!, movieDetail.title),
                  backgroundColor: AppColors.gold,
                  child: const Icon(Icons.play_arrow, color: AppColors.darkBackground, size: 32),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeScreenContent(BuildContext context, MovieDetailLoaded state) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column - Movie info
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMovieInfo(state.movieDetail, true),
              const SizedBox(height: 24),
              _buildActionButtons(context, state),
              const SizedBox(height: 24),
              _buildOverview(state.movieDetail),
            ],
          ),
        ),
        const SizedBox(width: 32),
        // Right column - Cast, reviews, etc
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCastSection(state.movieDetail),
              const SizedBox(height: 24),
              _buildUserRatingSection(state),
              const SizedBox(height: 24),
              _buildReviewsSection(state.movieDetail),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileContent(BuildContext context, MovieDetailLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMovieInfo(state.movieDetail, false),
        const SizedBox(height: 24),
        _buildActionButtons(context, state),
        const SizedBox(height: 24),
        _buildOverview(state.movieDetail),
        const SizedBox(height: 24),
        _buildCastSection(state.movieDetail),
        const SizedBox(height: 24),
        _buildUserRatingSection(state),
        const SizedBox(height: 24),
        _buildReviewsSection(state.movieDetail),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildMovieInfo(MovieDetailModel movieDetail, bool isLargeScreen) {
    final posterWidth = isLargeScreen ? 200.0 : 120.0;
    final posterHeight = isLargeScreen ? 300.0 : 180.0;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: movieDetail.getFullPosterUrl(),
            width: posterWidth,
            height: posterHeight,
            fit: BoxFit.cover,
            errorWidget: (context, url, error) => Container(
              width: posterWidth,
              height: posterHeight,
              color: AppColors.darkGrey,
              child: const Icon(Icons.broken_image, color: AppColors.grey, size: 32),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                movieDetail.title,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: isLargeScreen ? 24 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.star, color: AppColors.gold, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    movieDetail.voteAverage.toStringAsFixed(1),
                    style: const TextStyle(color: AppColors.white, fontSize: 16),
                  ),
                  Text(
                    ' (${movieDetail.voteCount} votes)',
                    style: const TextStyle(color: AppColors.grey, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (movieDetail.releaseDate != null)
                Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppColors.grey, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      movieDetail.getReleaseDateFormatted(),
                      style: const TextStyle(color: AppColors.grey, fontSize: 14),
                    ),
                  ],
                ),
              const SizedBox(height: 4),
              if (movieDetail.runtime > 0)
                Row(
                  children: [
                    const Icon(Icons.access_time, color: AppColors.grey, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      movieDetail.getRuntimeFormatted(),
                      style: const TextStyle(color: AppColors.grey, fontSize: 14),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: movieDetail.genres.map((genre) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.gold, width: 1),
                    ),
                    child: Text(
                      genre,
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, MovieDetailLoaded state) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: state.isSubmittingReview
                ? null
                : () => _showRatingDialog(context, state.movieDetail),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.darkBackground,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: Icon(
              state.userReview != null ? Icons.edit : Icons.rate_review,
              size: 20,
            ),
            label: Text(
              state.userReview != null ? 'Edit Review' : 'Rate & Review',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        if (state.userReview != null) ...[
          const SizedBox(width: 12),
          IconButton(
            onPressed: state.isSubmittingReview
                ? null
                : () => context.read<MovieDetailCubit>().deleteReview(),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.darkGrey,
              padding: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.red,
              size: 24,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOverview(MovieDetailModel movieDetail) {
    if (movieDetail.overview.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          movieDetail.overview,
          style: const TextStyle(
            color: AppColors.grey,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildCastSection(MovieDetailModel movieDetail) {
    if (movieDetail.cast.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cast',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: movieDetail.cast.length,
            itemBuilder: (context, index) {
              final cast = movieDetail.cast[index];
              return Container(
                width: 100,
                margin: const EdgeInsets.only(right: 12),
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: cast.getFullProfileUrl(),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.darkGrey,
                            child: const Icon(
                              Icons.person,
                              color: AppColors.grey,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cast.name,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      cast.character,
                      style: const TextStyle(
                        color: AppColors.grey,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUserRatingSection(MovieDetailLoaded state) {
    final stats = state.ratingStats;
    final averageRating = stats['averageRating'] as double;
    final totalReviews = stats['totalReviews'] as int;

    if (totalReviews == 0) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Community Rating',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.star, color: AppColors.gold, size: 24),
            const SizedBox(width: 8),
            Text(
              averageRating.toStringAsFixed(1),
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '($totalReviews ${totalReviews == 1 ? 'review' : 'reviews'})',
              style: const TextStyle(
                color: AppColors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
        if (state.userReview != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.darkGrey,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gold.withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Your Review',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < state.userReview!.rating
                              ? Icons.star
                              : Icons.star_border,
                          color: AppColors.gold,
                          size: 16,
                        );
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  state.userReview!.review,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReviewsSection(MovieDetailModel movieDetail) {
    if (movieDetail.reviews.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reviews',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...movieDetail.reviews.map((review) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.darkGrey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      review.author,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (review.rating != null)
                      Row(
                        children: [
                          const Icon(Icons.star, color: AppColors.gold, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            review.rating!.toStringAsFixed(1),
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  review.getCreatedAtFormatted(),
                  style: const TextStyle(
                    color: AppColors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  review.getShortContent(),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
