import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinema_noir/core/api/tmdb_service.dart';
import 'package:cinema_noir/core/constants/app_colors.dart';
import 'package:cinema_noir/features/home/data/models/movie_model.dart';
import 'package:cinema_noir/features/home/presentation/widgets/trailer_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class MovieTicketPage extends StatefulWidget {
  final MovieModel? movie;
  final int? movieId;

  const MovieTicketPage({Key? key, this.movie, this.movieId}) : super(key: key);

  @override
  State<MovieTicketPage> createState() => _MovieTicketPageState();
}

class _MovieTicketPageState extends State<MovieTicketPage> {
  bool _isLoadingTrailer = false;

  int _selectedDateIndex = 0;
  int _selectedCityIndex = 0;
  String? _selectedCinema;
  String? _selectedTime;

  late final List<DateTime> _availableDates;

  final List<String> _cities = ['Jakarta', 'Bogor', 'Depok', 'Tangerang', 'Bekasi'];

  final Map<String, List<Map<String, dynamic>>> _cityCinemas = {
    'Jakarta': [
      {
        'name': 'Kelapa Gading XXI',
        'times': ['13:00', '16:00', '19:00'],
      },
      {
        'name': 'Cinema Noir XXI',
        'times': ['14:30', '17:30', '20:30'],
      },
    ],
    'Depok': [
      {
        'name': 'Depok Mall XXI',
        'times': ['12:00', '15:00', '18:00'],
      },
    ],
    'Bogor': [],
    'Tangerang': [],
    'Bekasi': [],
  };

  @override
  void initState() {
    super.initState();
    _availableDates = List.generate(
      7,
      (index) => DateTime.now().add(Duration(days: index)),
    );
  }

  DateTime get _selectedDate => _availableDates[_selectedDateIndex];

  List<Map<String, dynamic>> get _currentCinemas {
    final city = _cities[_selectedCityIndex];
    return _cityCinemas[city] != null && _cityCinemas[city]!.isNotEmpty
        ? _cityCinemas[city]!
        : _cityCinemas['Jakarta']!;
  }

  void _onSelectShowtime(String cinemaName, String time) {
    setState(() {
      _selectedCinema = cinemaName;
      _selectedTime = time;
    });
  }

  void _purchaseTicket() {
    final movie = widget.movie;
    if (movie == null) return;

    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih tanggal dan jam tayang terlebih dahulu.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final dateString =
        DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate);

    context.push(
      '/movies/${movie.id}/ticket/seats?date=$dateString&time=$_selectedTime',
      extra: movie,
    );
  }

  Future<void> _playTrailer() async {
    final movie = widget.movie;
    if (movie == null || _isLoadingTrailer) return;

    setState(() {
      _isLoadingTrailer = true;
    });

    try {
      final tmdbService = TmdbService();
      final trailerKey = await tmdbService.getMovieTrailer(movie.id);

      if (!mounted) return;

      setState(() {
        _isLoadingTrailer = false;
      });

      if (trailerKey != null) {
        showDialog(
          context: context,
          builder: (context) => TrailerDialog(
            trailerKey: trailerKey,
            movieTitle: movie.title,
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
          content: Text('Gagal memutar trailer: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),
        title: Text(
          movie?.title ?? 'Film',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A1A),
              AppColors.darkBackground,
            ],
          ),
        ),
        child: movie == null
            ? const Center(
                child: Text(
                  'Data film tidak tersedia.',
                  style: TextStyle(color: AppColors.textWhite),
                ),
              )
            : SingleChildScrollView(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + kToolbarHeight + 16,
                  left: 16,
                  right: 16,
                  bottom: 32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Movie Info Section
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Hero(
                          tag: 'movie_poster_${movie.id}',
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: CachedNetworkImage(
                                imageUrl: movie.getFullPosterUrl(),
                                width: 140,
                                height: 210,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  width: 140,
                                  height: 210,
                                  color: AppColors.darkGrey,
                                ),
                                errorWidget: (context, url, error) => Container(
                                  width: 140,
                                  height: 210,
                                  color: AppColors.darkGrey,
                                  child: const Icon(Icons.broken_image, color: AppColors.textGrey),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                movie.title,
                                style: const TextStyle(
                                  color: AppColors.textWhite,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: AppColors.gold, size: 20),
                                  const SizedBox(width: 6),
                                  Text(
                                    movie.voteAverage.toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: AppColors.textGrey,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: _isLoadingTrailer ? null : _playTrailer,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.gold,
                                  foregroundColor: AppColors.darkBackground,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                icon: _isLoadingTrailer
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            AppColors.darkBackground,
                                          ),
                                        ),
                                      )
                                    : const Icon(Icons.play_arrow_rounded),
                                label: const Text(
                                  'Play Trailer',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Schedule Section
                    _ScheduleSection(
                      selectedDateIndex: _selectedDateIndex,
                      onDateSelected: (index) {
                        setState(() {
                          _selectedDateIndex = index;
                        });
                      },
                      availableDates: _availableDates,
                      cities: _cities,
                      selectedCityIndex: _selectedCityIndex,
                      onCitySelected: (index) {
                        setState(() {
                          _selectedCityIndex = index;
                          _selectedCinema = null;
                          _selectedTime = null;
                        });
                      },
                      cinemas: _currentCinemas,
                      selectedCinema: _selectedCinema,
                      selectedTime: _selectedTime,
                      onShowtimeSelected: _onSelectShowtime,
                      onProceed: _purchaseTicket,
                    ),
                    const SizedBox(height: 32),
                    
                    // Synopsis Section
                    const Text(
                      'Synopsis',
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      movie.overview.isNotEmpty ? movie.overview : 'Synopsis not available.',
                      style: const TextStyle(
                        color: Colors.white70,
                        height: 1.6,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _ScheduleSection extends StatelessWidget {
  final int selectedDateIndex;
  final void Function(int index) onDateSelected;
  final List<DateTime> availableDates;
  final List<String> cities;
  final int selectedCityIndex;
  final void Function(int index) onCitySelected;
  final List<Map<String, dynamic>> cinemas;
  final String? selectedCinema;
  final String? selectedTime;
  final void Function(String cinemaName, String time) onShowtimeSelected;
  final VoidCallback onProceed;

  const _ScheduleSection({
    required this.selectedDateIndex,
    required this.onDateSelected,
    required this.availableDates,
    required this.cities,
    required this.selectedCityIndex,
    required this.onCitySelected,
    required this.cinemas,
    required this.selectedCinema,
    required this.selectedTime,
    required this.onShowtimeSelected,
    required this.onProceed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Schedule',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Dates
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(availableDates.length, (index) {
              final date = availableDates[index];
              final isSelected = selectedDateIndex == index;
              final dayLabel = DateFormat('E', 'id_ID').format(date);
              final dayNumber = DateFormat('dd', 'id_ID').format(date);

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => onDateSelected(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.gold : const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppColors.gold : Colors.transparent,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          dayLabel.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? AppColors.darkBackground : Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dayNumber,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? AppColors.darkBackground : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 24),
        
        // Cities
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(cities.length, (index) {
              final city = cities[index];
              final isSelected = selectedCityIndex == index;

              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: FilterChip(
                  label: Text(city),
                  selected: isSelected,
                  selectedColor: AppColors.gold,
                  backgroundColor: const Color(0xFF2C2C2C),
                  checkmarkColor: AppColors.darkBackground,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.darkBackground : Colors.white70,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? AppColors.gold : Colors.transparent,
                    ),
                  ),
                  onSelected: (_) => onCitySelected(index),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 24),
        
        // Cinemas & Times
        Column(
          children: cinemas.map((cinema) {
            final name = cinema['name'] as String;
            final times = (cinema['times'] as List).cast<String>();

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF252525),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: name == selectedCinema ? AppColors.gold.withOpacity(0.5) : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.movie_creation_outlined, color: Colors.white70, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: times.map((time) {
                      final isSelected = selectedCinema == name && selectedTime == time;
                      return GestureDetector(
                        onTap: () => onShowtimeSelected(name, time),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.gold : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? AppColors.gold : Colors.grey[700]!,
                            ),
                          ),
                          child: Text(
                            time,
                            style: TextStyle(
                              color: isSelected ? AppColors.darkBackground : Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        
        // Proceed Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: selectedTime == null ? null : onProceed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.darkBackground,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              selectedTime == null ? 'Select Seats' : 'Select Seats - $selectedTime',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}