import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinema_noir/core/constants/app_colors.dart';
import 'package:cinema_noir/features/cinemas/data/models/cinema_model.dart';
import 'package:cinema_noir/features/cinemas/presentation/cubit/cinema_cubit.dart';
import 'package:cinema_noir/features/cinemas/presentation/cubit/cinema_state.dart';
import 'package:cinema_noir/features/cinemas/presentation/widgets/cinema_card.dart';
import 'package:shimmer/shimmer.dart';

class CinemasPage extends StatefulWidget {
  const CinemasPage({super.key});

  @override
  State<CinemasPage> createState() => _CinemasPageState();
}

class _CinemasPageState extends State<CinemasPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCity;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  List<CinemaModel> _filterCinemas(List<CinemaModel> cinemas) {
    return cinemas.where((cinema) {
      final matchesSearch = _searchQuery.isEmpty ||
          cinema.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          cinema.address.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          cinema.city.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCity =
          _selectedCity == null || cinema.city == _selectedCity;

      return matchesSearch && matchesCity;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CinemaCubit()..fetchCinemas(),
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: SafeArea(
          child: Column(
            children: [
              // Custom Header
              _buildHeader(),

              // Tabs
              _buildTabs(),

              // Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCinemasTab(),
                    _buildMapTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and back button
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.gold),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              const Text(
                'CINEMAS',
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search Bar
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            style: const TextStyle(color: AppColors.textWhite),
            decoration: InputDecoration(
              hintText: 'Search cinema or location...',
              hintStyle: const TextStyle(color: AppColors.textGrey),
              prefixIcon: const Icon(Icons.search, color: AppColors.gold),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.textGrey),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.darkGrey,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),

          // City Filter
          const SizedBox(height: 12),
          BlocBuilder<CinemaCubit, CinemaState>(
            builder: (context, state) {
              if (state is CinemaLoaded) {
                return SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildCityChip('All', _selectedCity == null),
                      ...state.cities.map(
                        (city) => _buildCityChip(
                          city,
                          _selectedCity == city,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCityChip(String city, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          city,
          style: TextStyle(
            color: isSelected ? AppColors.darkBackground : AppColors.gold,
            fontWeight: FontWeight.w600,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCity = city == 'All' ? null : city;
          });
        },
        backgroundColor: AppColors.darkGrey,
        selectedColor: AppColors.gold,
        checkmarkColor: AppColors.darkBackground,
        side: BorderSide(
          color: isSelected ? AppColors.gold : AppColors.gold.withOpacity(0.3),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkBackground,
        border: Border(
          bottom: BorderSide(
            color: AppColors.darkGrey,
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.gold,
        indicatorWeight: 3,
        labelColor: AppColors.gold,
        unselectedLabelColor: AppColors.textGrey,
        labelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        tabs: const [
          Tab(
            icon: Icon(Icons.list),
            text: 'List',
          ),
          Tab(
            icon: Icon(Icons.map),
            text: 'Map',
          ),
        ],
      ),
    );
  }

  Widget _buildCinemasTab() {
    return BlocBuilder<CinemaCubit, CinemaState>(
      builder: (context, state) {
        if (state is CinemaLoading) {
          return _buildShimmerLoading();
        }

        if (state is CinemaError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.redAccent,
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error: ${state.message}',
                  style: const TextStyle(color: Colors.redAccent),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<CinemaCubit>().fetchCinemas();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is CinemaLoaded) {
          final filteredCinemas = _filterCinemas(state.cinemas);

          if (filteredCinemas.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    color: AppColors.textGrey,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No cinemas found',
                    style: TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.gold,
            backgroundColor: AppColors.darkGrey,
            onRefresh: () async {
              await context.read<CinemaCubit>().fetchCinemas();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredCinemas.length,
              itemBuilder: (context, index) {
                final cinema = filteredCinemas[index];
                return CinemaCard(
                  cinema: cinema,
                  onTap: () {
                    _showCinemaDetails(context, cinema);
                  },
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMapTab() {
    return Container(
      color: AppColors.darkBackground,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 80,
              color: AppColors.gold.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            const Text(
              'Map View',
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Interactive map view will be available soon.\nYou can use the Navigate button on each cinema card to open in Google Maps.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: AppColors.darkGrey,
          highlightColor: AppColors.darkGrey.withOpacity(0.5),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 320,
            decoration: BoxDecoration(
              color: AppColors.darkGrey,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }

  void _showCinemaDetails(BuildContext context, CinemaModel cinema) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.darkGrey,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textGrey,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Cinema name
              Text(
                cinema.name,
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Details
              _buildDetailRow(Icons.location_on, cinema.address),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.location_city, cinema.city),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.phone, cinema.phone),
              if (cinema.openingHours != null) ...[
                const SizedBox(height: 12),
                _buildDetailRow(Icons.access_time, cinema.openingHours!),
              ],

              const SizedBox(height: 24),
              
              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      color: AppColors.darkBackground,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppColors.gold,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}
