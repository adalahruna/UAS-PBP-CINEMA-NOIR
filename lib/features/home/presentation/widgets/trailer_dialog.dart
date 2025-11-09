// File: lib/features/home/presentation/widgets/trailer_dialog.dart

import 'package:cinema_noir/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class TrailerDialog extends StatefulWidget {
  final String trailerKey;
  final String movieTitle;

  const TrailerDialog({
    super.key,
    required this.trailerKey,
    required this.movieTitle,
  });

  @override
  State<TrailerDialog> createState() => _TrailerDialogState();
}

class _TrailerDialogState extends State<TrailerDialog> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();

    // Untuk debug di console (opsional, tapi bagus untuk cek)
    print("Mencoba memutar YouTube Key: ${widget.trailerKey}");

    _controller = YoutubePlayerController(
      initialVideoId: widget.trailerKey,
      flags: const YoutubePlayerFlags(
        autoPlay: true, 
        mute: false,
        loop: true,     
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.darkBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      title: Text(
        widget.movieTitle,
        style: const TextStyle(
          color: AppColors.gold,
          fontWeight: FontWeight.bold,
        ),
      ),
      contentPadding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0), 
      content: AspectRatio(
        aspectRatio: 16 / 9,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          
          // ========================================================
          // --- PERBAIKAN OVERFLOW DI SINI ---
          // Bungkus YoutubePlayer dengan ClipRect
          // ========================================================
          child: ClipRect(
            child: YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: true,
              progressIndicatorColor: AppColors.gold,
              progressColors: const ProgressBarColors(
                playedColor: AppColors.gold,
                handleColor: AppColors.gold,
              ),
            ),
          ),
          // ========================================================
          // --- AKHIR PERBAIKAN ---
          // ========================================================

        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'Tutup',
            style: TextStyle(color: AppColors.textWhite),
          ),
        ),
      ],
    );
  }
}