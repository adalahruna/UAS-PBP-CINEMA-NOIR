import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinema_noir/core/api/tmdb_service.dart';
import 'package:cinema_noir/core/constants/app_colors.dart';
import 'package:cinema_noir/features/home/data/models/movie_model.dart';
import 'package:cinema_noir/features/home/presentation/widgets/trailer_dialog.dart';
import 'package:flutter/material.dart';

class MovieTicketPage extends StatefulWidget {
  final MovieModel? movie;

  const MovieTicketPage({super.key, this.movie});

  @override
  State<MovieTicketPage> createState() => _MovieTicketPageState();
}

class _MovieTicketPageState extends State<MovieTicketPage> {
  bool _isLoadingTrailer = false;

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

  void _purchaseTicket() {
    final movie = widget.movie;
    if (movie == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tiket "${movie.title}" berhasil ditambahkan ke keranjang!'),
        backgroundColor: AppColors.gold,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        title: Text(movie?.title ?? 'Film'),
      ),
      body: movie == null
          ? const Center(
              child: Text(
                'Data film tidak tersedia.',
                style: TextStyle(color: AppColors.textWhite),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
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
                      const SizedBox(width: 16),
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
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.star, color: AppColors.gold),
                                const SizedBox(width: 6),
                                Text(
                                  movie.voteAverage.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: AppColors.textGrey,
                                    fontSize: 16,
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
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                              icon: _isLoadingTrailer
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: AppColors.darkBackground,
                                      ),
                                    )
                                  : const Icon(Icons.play_arrow),
                              label: Text(_isLoadingTrailer ? 'Memuat...' : 'Putar Trailer'),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: _purchaseTicket,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.gold,
                                side: const BorderSide(color: AppColors.gold, width: 2),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                              icon: const Icon(Icons.confirmation_number_outlined),
                              label: const Text('Beli Tiket'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Sinopsis',
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    movie.overview.isNotEmpty ? movie.overview : 'Sinopsis belum tersedia.',
                    style: const TextStyle(color: AppColors.textGrey, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.darkGrey,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pilih Jadwal',
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _ScheduleChip(label: 'Hari ini - 19:00'),
                            _ScheduleChip(label: 'Hari ini - 21:30'),
                            _ScheduleChip(label: 'Besok - 16:00'),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _purchaseTicket,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.gold,
                              foregroundColor: AppColors.darkBackground,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              'Konfirmasi & Bayar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ScheduleChip extends StatelessWidget {
  final String label;

  const _ScheduleChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold, width: 1.5),
        color: Colors.black.withOpacity(0.3),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.gold,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

