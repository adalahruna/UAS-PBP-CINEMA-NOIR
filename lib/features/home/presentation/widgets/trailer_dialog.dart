// File: lib/features/home/presentation/widgets/trailer_dialog.dart
// Solusi terbaik untuk Flutter Web

import 'package:cinema_noir/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

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
  late String viewId;

  @override
  void initState() {
    super.initState();
    viewId = 'youtube-${widget.trailerKey}-${DateTime.now().millisecondsSinceEpoch}';
    _registerIframe();
  }

  void _registerIframe() {
    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(
      viewId,
      (int viewId) {
        final iframe = html.IFrameElement()
          ..src = 'https://www.youtube.com/embed/${widget.trailerKey}?autoplay=1&controls=1&modestbranding=1&rel=0'
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..allow = 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture'
          ..allowFullscreen = true;
        
        return iframe;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = (screenWidth * 0.8).clamp(300.0, 1000.0);
    final dialogHeight = (dialogWidth / 16 * 9) + 120; // 16:9 ratio + header space

    return Dialog(
      backgroundColor: AppColors.darkBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Container(
        width: dialogWidth,
        height: dialogHeight,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.movieTitle,
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textWhite),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Tutup',
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Video Player (IFrame)
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: HtmlElementView(
                    viewType: viewId,
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