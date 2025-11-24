import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cinema_noir/core/constants/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class MyOrdersPage extends StatelessWidget {
  const MyOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil User ID saat ini
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

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
        body: userId == null
            ? const Center(
                child: Text("Silakan login untuk melihat pesanan",
                    style: TextStyle(color: Colors.white)))
            : TabBarView(
                children: [
                  _TicketHistoryList(userId: userId),
                  _FoodOrderList(userId: userId),
                ],
              ),
      ),
    );
  }
}

// --- FORMATTER HELPERS ---
String _formatDate(Timestamp? timestamp) {
  if (timestamp == null) return '-';
  return DateFormat('dd MMM yyyy, HH:mm').format(timestamp.toDate());
}

String _formatCurrency(num amount) {
  return NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(amount);
}

// --- WIDGET LIST RIWAYAT TIKET ---
class _TicketHistoryList extends StatelessWidget {
  final String userId;
  const _TicketHistoryList({required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: 'ticket')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.gold));
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('Belum ada riwayat tiket.', style: TextStyle(color: AppColors.textGrey)),
          );
        }

        final tickets = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tickets.length,
          itemBuilder: (context, index) {
            final data = tickets[index].data() as Map<String, dynamic>;
            
            final String title = data['movieTitle'] ?? 'Judul Tidak Tersedia';
            final String cinema = data['cinemaName'] ?? 'Bioskop';
            final String seats = (data['seats'] as List<dynamic>?)?.join(', ') ?? '-';
            final String posterUrl = data['posterUrl'] ?? '';
            final String status = data['status'] ?? 'Aktif';
            final Timestamp? schedule = data['schedule'];
            final bool isActive = status == 'Paid' || status == 'Aktif';

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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: posterUrl,
                        width: 70,
                        height: 100,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) =>
                            Container(color: Colors.grey, width: 70, height: 100, child: const Icon(Icons.movie)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: AppColors.textWhite,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            cinema,
                            style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
                          ),
                          Text(
                            _formatDate(schedule),
                            style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Kursi: $seats',
                                  style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isActive ? AppColors.gold : Colors.grey,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  status,
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
      },
    );
  }
}

// --- WIDGET LIST RIWAYAT MAKANAN ---
class _FoodOrderList extends StatelessWidget {
  final String userId;
  const _FoodOrderList({required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: 'food')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.gold));
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('Belum ada pesanan makanan.', style: TextStyle(color: AppColors.textGrey)),
          );
        }

        final orders = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final data = orders[index].data() as Map<String, dynamic>;
            
            final Timestamp? createdAt = data['createdAt'];
            final String status = data['status'] ?? 'Proses';
            final num total = data['totalPrice'] ?? 0;
            final List<dynamic> items = data['items'] ?? [];
            
            String itemsSummary = items.map((item) {
               return "${item['qty']}x ${item['name']}";
            }).join(', ');

            final bool isPaid = status == 'Paid' || status == 'Siap Diambil';

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.darkGrey,
                borderRadius: BorderRadius.circular(12),
                border: isPaid ? Border.all(color: AppColors.gold, width: 1) : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDate(createdAt),
                        style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
                      ),
                      Text(
                        status,
                        style: TextStyle(
                          color: isPaid ? AppColors.gold : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.grey, height: 24),
                  Text(
                    itemsSummary,
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
                        _formatCurrency(total),
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
      },
    );
  }
}