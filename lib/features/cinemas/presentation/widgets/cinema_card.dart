import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinema_noir/core/constants/app_colors.dart';
import 'package:cinema_noir/features/cinemas/data/models/cinema_model.dart';
import 'package:url_launcher/url_launcher.dart';

class _CinemaImage extends StatefulWidget {
  final String imageUrl;
  final String fallbackUrl;
  final double height;

  const _CinemaImage({
    Key? key,
    required this.imageUrl,
    required this.fallbackUrl,
    required this.height,
  }) : super(key: key);

  @override
  _CinemaImageState createState() => _CinemaImageState();
}

class _CinemaImageState extends State<_CinemaImage> {
  bool _hasError = false;
  String? _currentUrl;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.imageUrl;
  }

  @override
  void didUpdateWidget(_CinemaImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _hasError = false;
      _currentUrl = widget.imageUrl;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: _currentUrl!,
      height: widget.height,
      width: double.infinity,
      fit: BoxFit.cover,
      memCacheHeight: (widget.height * MediaQuery.of(context).devicePixelRatio).round(),
      memCacheWidth: (MediaQuery.of(context).size.width * MediaQuery.of(context).devicePixelRatio).round(),
      maxHeightDiskCache: (widget.height * MediaQuery.of(context).devicePixelRatio * 1.5).round(),
      maxWidthDiskCache: (MediaQuery.of(context).size.width * MediaQuery.of(context).devicePixelRatio * 1.5).round(),
      fadeInDuration: const Duration(milliseconds: 300),
      fadeInCurve: Curves.easeInOut,
      placeholder: (context, url) => Container(
        height: widget.height,
        color: AppColors.darkGrey,
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: AppColors.gold,
              strokeWidth: 2,
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) {
        // If we haven't tried the fallback URL yet, try it
        if (!_hasError && _currentUrl != widget.fallbackUrl) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _hasError = true;
                _currentUrl = widget.fallbackUrl;
              });
            }
          });
          return Container(
            height: widget.height,
            color: AppColors.darkGrey,
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: AppColors.gold,
                  strokeWidth: 2,
                ),
              ),
            ),
          );
        }
        
        // If fallback also fails, show error icon
        return Container(
          height: widget.height,
          color: AppColors.darkGrey,
          child: const Center(
            child: Icon(
              Icons.movie,
              size: 50,
              color: AppColors.gold,
            ),
          ),
        );
      },
    );
  }
}

class CinemaCard extends StatelessWidget {
  final CinemaModel cinema;
  final VoidCallback? onTap;

  const CinemaCard({
    super.key,
    required this.cinema,
    this.onTap,
  });


  Future<void> _openMaps(double? lat, double? lng) async {
    if (lat == null || lng == null) return;
    
    final Uri launchUri = Uri(
      scheme: 'https',
      host: 'www.google.com',
      path: '/maps/search/',
      queryParameters: {'api': '1', 'query': '$lat,$lng'},
    );
    
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    }
  }

  // Fallback cinema images from Pexels (optimized and verified)
  String _getFallbackImageUrl() {
    final cinemaName = cinema.name.toLowerCase();
    
    // Use optimized image URLs with smaller size and webp format
    if (cinemaName.contains('premiere') || cinemaName.contains('plaza')) {
      return 'https://images.pexels.com/photos/1117132/pexels-photo-1117132.jpeg?auto=format&fit=crop&w=800&q=80&fm=webp';
    } else if (cinemaName.contains('imax') || cinemaName.contains('cgv')) {
      return 'https://images.pexels.com/photos/2608517/pexels-photo-2608517.jpeg?auto=format&fit=crop&w=800&q=80&fm=webp';
    } else if (cinemaName.contains('dolby') || cinemaName.contains('grand')) {
      return 'https://images.pexels.com/photos/2608519/pexels-photo-2608519.jpeg?auto=format&fit=crop&w=800&q=80&fm=webp';
    } else {
      // Default cinema image
      return 'https://images.pexels.com/photos/1117132/pexels-photo-1117132.jpeg?auto=format&fit=crop&w=800&q=80&fm=webp';
    }
  }
  
  // Get the actual image URL with fallback
  String _getImageUrl() {
    if (cinema.imageUrl?.isNotEmpty == true) {
      try {
        // Validate the URL format
        final uri = Uri.tryParse(cinema.imageUrl!);
        if (uri != null && uri.isAbsolute) {
          return cinema.imageUrl!;
        }
      } catch (e) {
        // If URL is invalid, use fallback
        return _getFallbackImageUrl();
      }
    }
    return _getFallbackImageUrl();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final imageHeight = isMobile ? 180.0 : 200.0;

    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 16 : 0),
      decoration: BoxDecoration(
        color: AppColors.darkGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cinema Image with gradient overlay
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Stack(
                  children: [
                    // Background fallback color
                    Container(
                      height: imageHeight,
                      width: double.infinity,
                      color: AppColors.darkGrey,
                    ),
                    // Optimized image with caching and error handling
                    _CinemaImage(
                      imageUrl: _getImageUrl(),
                      height: imageHeight,
                      fallbackUrl: _getFallbackImageUrl(),
                    ),
                    // Gradient overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
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
                    ),
                    // Cinema name and rating
                    Positioned(
                      left: 16,
                      bottom: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cinema.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: AppColors.gold,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${cinema.rating?.toStringAsFixed(1) ?? 'N/A'}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
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

              // Cinema Details
              Padding(
                padding: EdgeInsets.all(isMobile ? 16 : 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cinema Name
                    Text(
                      cinema.name,
                      style: TextStyle(
                        color: AppColors.gold,
                        fontSize: isMobile ? 17 : 19,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),

                    // Address
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: AppColors.textGrey,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            cinema.address,
                            style: const TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Phone
                    Row(
                      children: [
                        const Icon(
                          Icons.phone,
                          color: AppColors.textGrey,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          cinema.phone,
                          style: const TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),

                    if (cinema.openingHours != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            color: AppColors.textGrey,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            cinema.openingHours!,
                            style: const TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Facilities
                    if (cinema.facilities.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: cinema.facilities.map((facility) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.gold.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              facility,
                              style: const TextStyle(
                                color: AppColors.gold,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: onTap,
                            icon: const Icon(Icons.info_outline, size: 18),
                            label: Text(isMobile ? 'Details' : 'View Details'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.gold.withOpacity(0.15),
                              foregroundColor: AppColors.gold,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(
                                vertical: isMobile ? 12 : 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(color: AppColors.gold, width: 1.5),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _openMaps(
                              cinema.latitude,
                              cinema.longitude,
                            ),
                            icon: const Icon(Icons.navigation, size: 18),
                            label: Text(isMobile ? 'Navigate' : 'Get Directions'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.gold,
                              foregroundColor: AppColors.darkBackground,
                              elevation: 3,
                              padding: EdgeInsets.symmetric(
                                vertical: isMobile ? 12 : 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
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
