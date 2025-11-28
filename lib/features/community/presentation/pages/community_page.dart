// lib/features/community/presentation/pages/community_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cinema_noir/core/constants/app_colors.dart';
import 'package:cinema_noir/features/home/data/models/movie_model.dart';
import 'package:cinema_noir/features/community/presentation/cubit/community_cubit.dart';
import 'package:cinema_noir/features/community/presentation/cubit/community_state.dart';
import 'package:cinema_noir/features/community/presentation/widgets/enhanced_sort_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final ScrollController _scrollController = ScrollController();
  Timer? _debounceTimer;
  String _searchQuery = '';
  bool _isSearchMode = false;
  List<MovieModel> _searchResults = [];
  bool _showBackToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    // Pagination logic
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      if (_isSearchMode) {
        final state = context.read<CommunityCubit>().state;
        if (state is CommunitySearchLoaded && state.hasMoreResults) {
          context.read<CommunityCubit>().searchMovies(state.query);
        }
      } else {
        context.read<CommunityCubit>().loadMoreSortedMovies();
      }
    }

    // Back to Top visibility logic
    if (_scrollController.offset >= 400) {
      if (!_showBackToTop) setState(() => _showBackToTop = true);
    } else {
      if (_showBackToTop) setState(() => _showBackToTop = false);
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.trim();
    });

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (_searchQuery.isEmpty) {
        if (_isSearchMode) {
          setState(() {
            _isSearchMode = false;
            _searchResults.clear();
          });
          context.read<CommunityCubit>().clearSearch();
        }
      } else {
        setState(() => _isSearchMode = true);
        context.read<CommunityCubit>().searchMovies(_searchQuery, refresh: true);
      }
    });
  }

  void _onMovieSelected(MovieModel movie) {
    context.push('/community/movie/${movie.id}', extra: movie);
  }

  void _onClearSearch() {
    setState(() {
      _searchQuery = '';
      _isSearchMode = false;
      _searchResults.clear();
    });
    context.read<CommunityCubit>().clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      floatingActionButton: _showBackToTop
          ? FloatingActionButton(
              onPressed: _scrollToTop,
              backgroundColor: AppColors.gold,
              child: const Icon(Icons.arrow_upward, color: AppColors.darkBackground),
            )
          : null,
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // AppBar, Search, and Filters in Slivers so they scroll away
            SliverToBoxAdapter(child: _buildAppBar()),
            SliverToBoxAdapter(child: _buildSearchSection()),
            SliverToBoxAdapter(child: _buildFiltersSection()),
            // The Grid
            _buildMoviesGridSliver(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final titleFontSize = isSmallScreen ? 20.0 : 24.0;
    final iconSize = isSmallScreen ? 24.0 : 28.0;
    final padding = isSmallScreen ? 12.0 : 16.0;
    final user = FirebaseAuth.instance.currentUser;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: padding, 
        vertical: padding * 0.75,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.gold,
              size: iconSize,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Community',
            style: TextStyle(
              color: AppColors.gold,
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          // IconButton(
          //   onPressed: () {
          //     final cubit = context.read<CommunityCubit>();
          //     if (_isSearchMode) {
          //       cubit.clearSearch();
          //     } else {
          //       cubit.initialize();
          //     }
          //   },
          //   icon: Icon(
          //     Icons.refresh,
          //     color: AppColors.gold,
          //     size: iconSize,
          //   ),
          // ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => context.push('/profile'),
            child: CircleAvatar(
              radius: 25,
              backgroundColor: AppColors.darkGrey,
              backgroundImage: user?.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : null,
              child: user?.photoURL == null
                  ? const Icon(Icons.person, color: AppColors.gold, size: 30)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final double width = screenWidth < 600 ? screenWidth * 0.9 : 500;

    return Center(
      child: Container(
        width: width,
        margin: const EdgeInsets.symmetric(vertical: 12),
        child: TextField(
          onChanged: _onSearchChanged,
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

  Widget _buildFiltersSection() {
    return BlocBuilder<CommunityCubit, CommunityState>(
      builder: (context, state) {
        if (state is CommunityLoaded && !_isSearchMode) {
          final padding = 10.0;
          
          return Container(
            padding: EdgeInsets.symmetric(vertical: padding),
            child: EnhancedSortWidget(
              selectedSort: state.currentSort,
              selectedGenreId: state.currentGenreId,
              genres: state.genres,
              onSortChanged: (sortType) {
                try {
                  context.read<CommunityCubit>().changeSorting(sortType);
                } catch (e) {
                  debugPrint('Error changing sort: ');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to change sorting: '),
                      backgroundColor: Colors.red.shade700,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              onGenreChanged: (genreId) {
                try {
                  context.read<CommunityCubit>().changeGenre(genreId);
                } catch (e) {
                  debugPrint('Error changing genre: ');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to change genre: '),
                      backgroundColor: Colors.red.shade700,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              isLoadingGenres: state.genres.isEmpty,
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMoviesGridSliver() {
    return BlocBuilder<CommunityCubit, CommunityState>(
      builder: (context, state) {
        if (state is CommunityLoading) {
          return _buildLoadingGridSliver();
        }

        if (state is CommunityError) {
          return SliverToBoxAdapter(child: _buildErrorWidget(state.message));
        }

        if (state is CommunitySearchLoading) {
          return _buildLoadingGridSliver();
        }

        if (state is CommunitySearchError) {
          return SliverToBoxAdapter(child: _buildErrorWidget(state.message));
        }

        List<MovieModel> movies = [];
        bool hasMore = false;
        bool isLoadingMore = false;

        if (state is CommunityLoaded && !_isSearchMode) {
          movies = state.movies;
          hasMore = state.hasMoreMovies;
          isLoadingMore = state.isLoadingMore;
        } else if (state is CommunitySearchLoaded && _isSearchMode) {
          movies = state.searchResults;
          hasMore = state.hasMoreResults;
        }

        if (movies.isEmpty) {
          return SliverToBoxAdapter(child: _buildEmptyState());
        }

        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenWidth < 600;
        final gridPadding = isSmallScreen ? 12.0 : 16.0;
        final gridSpacing = isSmallScreen ? 12.0 : 16.0;
        
        return SliverPadding(
          padding: EdgeInsets.all(gridPadding),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _getCrossAxisCount(),
              mainAxisSpacing: gridSpacing,
              crossAxisSpacing: gridSpacing,
              childAspectRatio: 0.65,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index >= movies.length) {
                   // Loading indicator at bottom
                   return const Center(
                      child: CircularProgressIndicator(color: AppColors.gold),
                   );
                }
                return _buildMovieCard(movies[index]);
              },
              childCount: movies.length + (isLoadingMore || hasMore ? 1 : 0),
            ),
          ),
        );
      },
    );
  }

  int _getCrossAxisCount() {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) return 5;
    if (screenWidth > 800) return 4;
    if (screenWidth > 600) return 3;
    return 2;
  }

  Widget _buildMovieCard(MovieModel movie) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final cardPadding = isSmallScreen ? 6.0 : 8.0;
    final titleFontSize = isSmallScreen ? 11.0 : 12.0;
    final metaFontSize = isSmallScreen ? 9.0 : 10.0;
    final starSize = isSmallScreen ? 12.0 : 14.0;
    final iconSize = isSmallScreen ? 20.0 : 24.0;
    
    return GestureDetector(
      onTap: () => _onMovieSelected(movie),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.darkGrey,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: CachedNetworkImage(
                  imageUrl: movie.getFullPosterUrl(),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: AppColors.darkGrey,
                    highlightColor: AppColors.darkGrey.withOpacity(0.7),
                    child: Container(color: AppColors.darkGrey),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.darkGrey,
                    child: Icon(
                      Icons.broken_image,
                      color: AppColors.textGrey,
                      size: iconSize,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(cardPadding),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textWhite,
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: AppColors.gold,
                            size: starSize,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            movie.voteAverage.toStringAsFixed(1),
                            style: TextStyle(
                              color: AppColors.textGrey,
                              fontSize: metaFontSize,
                            ),
                          ),
                          const Spacer(),
                          if (movie.releaseDate != null &&
                              movie.releaseDate!.isNotEmpty)
                            Text(
                              movie.releaseDate!.substring(0, 4),
                              style: TextStyle(
                                color: AppColors.textGrey,
                                fontSize: metaFontSize,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingGridSliver() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final gridPadding = isSmallScreen ? 12.0 : 16.0;
    final gridSpacing = isSmallScreen ? 12.0 : 16.0;
    
    return SliverPadding(
      padding: EdgeInsets.all(gridPadding),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _getCrossAxisCount(),
          mainAxisSpacing: gridSpacing,
          crossAxisSpacing: gridSpacing,
          childAspectRatio: 0.65,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Shimmer.fromColors(
              baseColor: AppColors.darkGrey,
              highlightColor: AppColors.darkGrey.withOpacity(0.7),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.darkGrey,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          },
          childCount: 10,
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final padding = isSmallScreen ? 12.0 : 16.0;
    final iconSize = isSmallScreen ? 40.0 : 48.0;
    final titleFontSize = isSmallScreen ? 16.0 : 18.0;
    final bodyFontSize = isSmallScreen ? 12.0 : 14.0;
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.textGrey,
              size: iconSize,
            ),
            SizedBox(height: padding),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: titleFontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: padding * 0.5),
            Text(
              message,
              style: TextStyle(
                color: AppColors.textGrey,
                fontSize: bodyFontSize,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: padding),
            ElevatedButton(
              onPressed: () {
                context.read<CommunityCubit>().initialize();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.darkBackground,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final padding = isSmallScreen ? 12.0 : 16.0;
    final iconSize = isSmallScreen ? 40.0 : 48.0;
    final titleFontSize = isSmallScreen ? 16.0 : 18.0;
    final bodyFontSize = isSmallScreen ? 12.0 : 14.0;
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie_outlined,
              color: AppColors.textGrey,
              size: iconSize,
            ),
            SizedBox(height: padding),
            Text(
              _isSearchMode ? 'No movies found' : 'No movies available',
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: titleFontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: padding * 0.5),
            Text(
              _isSearchMode 
                  ? 'Try searching with different keywords'
                  : 'Check back later for more content',
              style: TextStyle(
                color: AppColors.textGrey,
                fontSize: bodyFontSize,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
