import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cinema_noir/core/constants/app_colors.dart';

class FoodCheckoutPage extends StatefulWidget {
  // Data cart dikirim dari halaman sebelumnya dalam bentuk List Map
  // Format: [{'id': '1', 'name': 'Popcorn', 'price': 50000, 'qty': 2, 'image': '...'}]
  final List<Map<String, dynamic>> cartItems;

  const FoodCheckoutPage({super.key, required this.cartItems});

  @override
  State<FoodCheckoutPage> createState() => _FoodCheckoutPageState();
}

class _FoodCheckoutPageState extends State<FoodCheckoutPage> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  bool _isLoading = false;

  // Data user yang akan diambil dari Firestore
  String _userName = 'Loading...';
  String _userLocation = 'Loading...';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // --- 1. AMBIL DATA USER DARI FIRESTORE ---
  Future<void> _fetchUserData() async {
    if (_currentUser != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.uid)
            .get();

        if (doc.exists) {
          final data = doc.data()!;
          setState(() {
            _userName = data['name'] ?? _currentUser!.email ?? 'User';
            // Menggabungkan Kota dan Provinsi jika ada
            String city = data['city'] ?? '';
            String prov = data['province'] ?? '';
            _userLocation = city.isNotEmpty
                ? '$city, $prov'
                : 'Lokasi belum diatur';
          });
        }
      } catch (e) {
        setState(() => _userLocation = 'Gagal memuat lokasi');
      }
    }
  }

  // --- 2. HITUNG TOTAL HARGA ---
  int _calculateTotal() {
    int total = 0;
    for (var item in widget.cartItems) {
      total += (item['price'] as int) * (item['qty'] as int);
    }
    return total;
  }

  String _formatCurrency(int amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  // --- 3. PROSES BAYAR (SIMPAN KE FIRESTORE) ---
  Future<void> _processPayment() async {
    setState(() => _isLoading = true);

    try {
      // Simpan ke collection 'orders' (atau 'transactions')
      await FirebaseFirestore.instance.collection('orders').add({
        'userId': _currentUser?.uid,
        'userName': _userName,
        'type': 'food', // Penanda tipe order (makanan)
        'items': widget.cartItems, // Simpan detail item
        'totalPrice': _calculateTotal(),
        'status': 'Paid', // Langsung anggap paid untuk simulasi
        'createdAt': FieldValue.serverTimestamp(),
        'location': _userLocation,
      });

      if (!mounted) return;

      // Tampilkan Dialog Sukses
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.darkGrey,
          title: const Icon(
            Icons.check_circle,
            color: AppColors.gold,
            size: 50,
          ),
          content: const Text(
            'Pembayaran Berhasil!\nMakananmu sedang disiapkan.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.go('/'); // Kembali ke Home (Reset navigasi)
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  color: AppColors.gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memproses pesanan: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final int totalAmount = _calculateTotal();
    // Biaya admin/pajak (dummy)
    final int tax = (totalAmount * 0.1).toInt();
    final int finalTotal = totalAmount + tax;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        title: const Text(
          'Checkout',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gold),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.gold,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SECTION 1: PENGIRIMAN (DATA USER DARI DB) ---
                  const Text(
                    'Pengantaran ke:',
                    style: TextStyle(color: AppColors.textGrey, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.darkGrey,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: AppColors.gold,
                          size: 30,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _userName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _userLocation,
                                style: const TextStyle(
                                  color: AppColors.textGrey,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Seat: A5 (Studio 1)',
                                style: TextStyle(
                                  color: AppColors.gold,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ), // Dummy Seat
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- SECTION 2: RINGKASAN PESANAN ---
                  const Text(
                    'Ringkasan Pesanan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.cartItems.length,
                    separatorBuilder: (context, index) =>
                        const Divider(color: Colors.white10),
                    itemBuilder: (context, index) {
                      final item = widget.cartItems[index];
                      return Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.gold.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${item['qty']}x',
                              style: const TextStyle(
                                color: AppColors.gold,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item['name'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Text(
                            _formatCurrency(
                              (item['price'] as int) * (item['qty'] as int),
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 24),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 16),

                  // --- SECTION 3: DETAIL PEMBAYARAN ---
                  _buildSummaryRow('Subtotal', _formatCurrency(totalAmount)),
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    'Pajak & Layanan (10%)',
                    _formatCurrency(tax),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Bayar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatCurrency(finalTotal),
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

      // --- TOMBOL BAYAR ---
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.darkGrey,
          border: Border(top: BorderSide(color: Colors.white10)),
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _processPayment,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.black,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Bayar Sekarang',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textGrey)),
        Text(value, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}
