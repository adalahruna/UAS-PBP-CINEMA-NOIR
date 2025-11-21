// File: lib/features/home/presentation/pages/my_orders_page.dart

import 'package:flutter/material.dart';
import 'package:cinema_noir/core/constants/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MyOrdersPage extends StatelessWidget {
  const MyOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        appBar: AppBar(
          backgroundColor: AppColors.darkBackground,
          title: const Text(
            'Pesanan Saya',
            style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold),
          ),
          iconTheme: const IconThemeData(color: AppColors.textWhite),
          bottom: const TabBar(
            indicatorColor: AppColors.gold,
            labelColor: AppColors.gold,
            unselectedLabelColor: AppColors.textGrey,
            tabs: [
              Tab(icon: Icon(Icons.movie_outlined), text: 'Tiket Film'),
              Tab(icon: Icon(Icons.fastfood_outlined), text: 'Makanan'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _TicketHistoryList(),
            _FoodOrderList(),
          ],
        ),
      ),
    );
  }
}

// --- WIDGET LIST RIWAYAT TIKET ---
class _TicketHistoryList extends StatelessWidget {
  const _TicketHistoryList();

  @override
  Widget build(BuildContext context) {
    // Data Dummy untuk simulasi
    final tickets = [
      {
        'title': 'Oppenheimer',
        'date': '20 Nov 2025, 19:00',
        'cinema': 'Cinema Noir XXI - Studio 1',
        'seats': 'E4, E5',
        'status': 'Aktif',
        'poster': 'https://image.tmdb.org/t/p/w500/8Gxv8gSFCU0XGDykEGv7zR1n2ua.jpg',
      },
      {
        'title': 'Barbie',
        'date': '15 Okt 2025, 14:30',
        'cinema': 'Cinema Noir XXI - Studio 3',
        'seats': 'F10, F11',
        'status': 'Selesai',
        'poster': 'https://image.tmdb.org/t/p/w500/iuFNMS8U5cb6xfzi51Dbkovj7vM.jpg',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        final ticket = tickets[index];
        final isActive = ticket['status'] == 'Aktif';

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.darkGrey,
            borderRadius: BorderRadius.circular(12),
            border: isActive ? Border.all(color: AppColors.gold, width: 1) : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Poster
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: ticket['poster'] as String,
                    width: 70,
                    height: 100,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => 
                        Container(color: Colors.grey, width: 70, height: 100),
                  ),
                ),
                const SizedBox(width: 16),
                // Detail Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket['title'] as String,
                        style: const TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ticket['cinema'] as String,
                        style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
                      ),
                      Text(
                        ticket['date'] as String,
                        style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Kursi: ${ticket['seats']}',
                            style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.w600),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isActive ? AppColors.gold : Colors.grey,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              ticket['status'] as String,
                              style: TextStyle(
                                color: isActive ? AppColors.darkBackground : Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
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
        );
      },
    );
  }
}

// --- WIDGET LIST RIWAYAT MAKANAN ---
class _FoodOrderList extends StatelessWidget {
  const _FoodOrderList();

  @override
  Widget build(BuildContext context) {
    // Data Dummy
    final foodOrders = [
      {
        'items': '1x Popcorn Large, 2x Coca Cola',
        'date': '20 Nov 2025',
        'total': 'Rp 85.000',
        'status': 'Siap Diambil',
      },
      {
        'items': '1x Nachos, 1x Mineral Water',
        'date': '15 Okt 2025',
        'total': 'Rp 55.000',
        'status': 'Selesai',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: foodOrders.length,
      itemBuilder: (context, index) {
        final order = foodOrders[index];
        final isReady = order['status'] == 'Siap Diambil';

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.darkGrey,
            borderRadius: BorderRadius.circular(12),
            border: isReady ? Border.all(color: AppColors.gold, width: 1) : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order['date'] as String,
                    style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
                  ),
                  Text(
                    order['status'] as String,
                    style: TextStyle(
                      color: isReady ? AppColors.gold : Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.grey, height: 24),
              Text(
                order['items'] as String,
                style: const TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Pembayaran',
                    style: TextStyle(color: AppColors.textGrey),
                  ),
                  Text(
                    order['total'] as String,
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}