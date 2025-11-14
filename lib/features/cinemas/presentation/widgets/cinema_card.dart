import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinema_noir/core/constants/app_colors.dart';
import 'package:cinema_noir/features/cinemas/data/models/cinema_model.dart';
import 'package:url_launcher/url_launcher.dart';

class CinemaCard extends StatelessWidget {
  final CinemaModel cinema;
  final VoidCallback? onTap;

  const CinemaCard({
    super.key,
    required this.cinema,
    this.onTap,
  });

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cinema Image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: cinema.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: cinema.imageUrl!,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 180,
                          color: AppColors.darkGrey,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.gold,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 180,
                          color: AppColors.darkGrey,
                          child: const Icon(
                            Icons.movie,
                            size: 50,
                            color: AppColors.gold,
                          ),
                        ),
                      )
                    : Container(
                        height: 180,
                        color: AppColors.darkGrey,
                        child: const Icon(
                          Icons.movie,
                          size: 50,
                          color: AppColors.gold,
                        ),
                      ),
              ),

              // Cinema Details
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cinema Name
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            cinema.name,
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (cinema.isOpen)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.green),
                            ),
                            child: const Text(
                              'OPEN',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),

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

                    // Action Buttons
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _makePhoneCall(cinema.phone),
                            icon: const Icon(Icons.phone, size: 18),
                            label: const Text('Call'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.gold,
                              side: const BorderSide(color: AppColors.gold),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _openMaps(
                              cinema.latitude,
                              cinema.longitude,
                            ),
                            icon: const Icon(Icons.map, size: 18),
                            label: const Text('Navigate'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.gold,
                              side: const BorderSide(color: AppColors.gold),
                              padding: const EdgeInsets.symmetric(vertical: 12),
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
