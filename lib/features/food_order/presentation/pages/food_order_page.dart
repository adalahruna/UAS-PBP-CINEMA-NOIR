import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cinema_noir/core/constants/app_colors.dart';
import 'package:cinema_noir/features/food_order/data/models/food_model.dart';

class FoodOrderPage extends StatefulWidget {
  const FoodOrderPage({super.key});

  @override
  State<FoodOrderPage> createState() => _FoodOrderPageState();
}

class _FoodOrderPageState extends State<FoodOrderPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  // Keranjang Belanja
  final Map<String, int> _cart = {};

  // Data Dummy Menu (Lengkap)
  final List<FoodModel> _allFoods = [
    const FoodModel(
      id: '1',
      name: 'Combo Couple Date',
      description:
          'Paket lengkap untuk berdua: 1 Large Popcorn + 2 Coca Cola + 1 Nachos Cheese.',
      price: 85000,
      category: 'combo',
      imageUrl:
          'https://images.unsplash.com/photo-1585647347384-2593bc35786b?q=80&w=1000&auto=format&fit=crop',
      rating: 4.9,
    ),
    const FoodModel(
      id: '2',
      name: 'Caramel Popcorn XL',
      description:
          'Popcorn renyah dengan lapisan karamel manis premium yang melimpah.',
      price: 55000,
      category: 'popcorn',
      imageUrl:
          'https://images.unsplash.com/photo-1578849278619-e73505e9610f?q=80&w=1000&auto=format&fit=crop',
      rating: 4.8,
    ),
    const FoodModel(
      id: '3',
      name: 'Salty Popcorn',
      description: 'Popcorn gurih original bioskop dengan butter asli.',
      price: 40000,
      category: 'popcorn',
      imageUrl:
          'https://images.unsplash.com/photo-1605218427368-35b0121d2319?q=80&w=1000&auto=format&fit=crop',
      rating: 4.5,
    ),
    const FoodModel(
      id: '4',
      name: 'Coca Cola Large',
      description: 'Minuman bersoda dingin ukuran besar menyegarkan dahaga.',
      price: 25000,
      category: 'drink',
      imageUrl:
          'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?q=80&w=1000&auto=format&fit=crop',
      rating: 4.6,
    ),
    const FoodModel(
      id: '5',
      name: 'Iced Lemon Tea',
      description: 'Teh lemon segar dengan irisan lemon asli dan es batu.',
      price: 30000,
      category: 'drink',
      imageUrl:
          'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?q=80&w=1000&auto=format&fit=crop',
      rating: 4.4,
    ),
    const FoodModel(
      id: '6',
      name: 'Nachos Cheese',
      description: 'Keripik tortilla renyah disiram dengan saus keju meleleh.',
      price: 50000,
      category: 'snack',
      imageUrl:
          'https://images.unsplash.com/photo-1574315042633-5945277350cd?q=80&w=1000&auto=format&fit=crop',
      rating: 4.9,
    ),
    const FoodModel(
      id: '7',
      name: 'Hotdog Beef',
      description:
          'Roti sosis sapi panggang premium dengan saus mustard dan mayones.',
      price: 45000,
      category: 'snack',
      imageUrl:
          'https://images.unsplash.com/photo-1619740455993-9e612b1af08a?q=80&w=1000&auto=format&fit=crop',
      rating: 4.3,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _formatCurrency(int amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  // --- Logic Keranjang ---
  void _incrementItem(FoodModel food) {
    setState(() {
      _cart[food.id] = (_cart[food.id] ?? 0) + 1;
    });
  }

  void _decrementItem(FoodModel food) {
    setState(() {
      if (_cart.containsKey(food.id)) {
        if (_cart[food.id]! > 1) {
          _cart[food.id] = _cart[food.id]! - 1;
        } else {
          _cart.remove(food.id);
        }
      }
    });
  }

  int _getTotalPrice() {
    int total = 0;
    _cart.forEach((key, qty) {
      final food = _allFoods.firstWhere((element) => element.id == key);
      total += (food.price * qty);
    });
    return total;
  }

  int _getTotalItems() {
    int total = 0;
    _cart.forEach((key, qty) => total += qty);
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final hasItems = _cart.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Stack(
        children: [
          // NestedScrollView untuk efek parallax header
          NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  backgroundColor: AppColors.darkBackground,
                  expandedHeight: 120.0,
                  floating: true,
                  pinned: true,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: AppColors.gold,
                      size: 20,
                    ),
                    onPressed: () => context.pop(),
                  ),
                  title: const Text(
                    'm.food',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                      letterSpacing: 1.5,
                    ),
                  ),
                  centerTitle: true,
                  bottom: TabBar(
                    controller: _tabController,
                    indicatorColor: AppColors.gold,
                    indicatorWeight: 3,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelColor: AppColors.gold,
                    unselectedLabelColor: AppColors.textGrey,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                    isScrollable: true,
                    physics: const BouncingScrollPhysics(),
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                    tabs: const [
                      Tab(text: 'All Menu'),
                      Tab(text: 'Combo'),
                      Tab(text: 'Popcorn'),
                      Tab(text: 'Drinks'),
                      Tab(text: 'Snacks'),
                    ],
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildFoodList('all'),
                _buildFoodList('combo'),
                _buildFoodList('popcorn'),
                _buildFoodList('drink'),
                _buildFoodList('snack'),
              ],
            ),
          ),

          // Floating Cart
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.elasticOut,
            bottom: hasItems ? 30 : -100,
            left: 20,
            right: 20,
            child: _buildFloatingCart(),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodList(String category) {
    final foods = category == 'all'
        ? _allFoods
        : _allFoods.where((f) => f.category == category).toList();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        120,
      ), // Padding bawah besar untuk cart
      physics: const BouncingScrollPhysics(),
      itemCount: foods.length,
      itemBuilder: (context, index) {
        final food = foods[index];
        return _buildFoodListItem(food);
      },
    );
  }

  // --- KARTU MAKANAN YANG ELEGAN ---
  Widget _buildFoodListItem(FoodModel food) {
    final qty = _cart[food.id] ?? 0;
    final bool isSelected = qty > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.gold.withOpacity(0.05)
            : AppColors.darkGrey,
        borderRadius: BorderRadius.circular(24),
        border: isSelected
            ? Border.all(color: AppColors.gold.withOpacity(0.3), width: 1)
            : Border.all(color: Colors.transparent),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. GAMBAR (Kiri)
          Stack(
            children: [
              Hero(
                tag: 'food_${food.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    imageUrl: food.imageUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: Colors.grey[900]),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[900],
                      child: const Icon(
                        Icons.fastfood,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ),
                ),
              ),
              // Rating Badge (Kecil di pojok gambar)
              if (food.rating >= 4.5)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: AppColors.gold, size: 10),
                        const SizedBox(width: 2),
                        Text(
                          food.rating.toString(),
                          style: const TextStyle(
                            color: AppColors.gold,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 16),

          // 2. INFO & KONTROL (Kanan)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama & Kategori
                Text(
                  food.category.toUpperCase(),
                  style: TextStyle(
                    color: AppColors.textGrey.withOpacity(0.7),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  food.name,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6),

                // Deskripsi
                Text(
                  food.description,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 11,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 16),

                // Harga & Tombol Add
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatCurrency(food.price),
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    // KONTROL JUMLAH (ADD / COUNTER)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 36,
                      decoration: BoxDecoration(
                        color: qty > 0 ? AppColors.gold : Colors.transparent,
                        border: Border.all(color: AppColors.gold),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: qty == 0
                          ? InkWell(
                              onTap: () => _incrementItem(food),
                              borderRadius: BorderRadius.circular(30),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Center(
                                  child: Text(
                                    'ADD',
                                    style: TextStyle(
                                      color: AppColors.gold,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 36,
                                  ),
                                  icon: const Icon(
                                    Icons.remove,
                                    size: 16,
                                    color: Colors.black,
                                  ),
                                  onPressed: () => _decrementItem(food),
                                ),
                                Text(
                                  '$qty',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 36,
                                  ),
                                  icon: const Icon(
                                    Icons.add,
                                    size: 16,
                                    color: Colors.black,
                                  ),
                                  onPressed: () => _incrementItem(food),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- FLOATING CART BAR (GLASSPHORMISM STYLE) ---
  Widget _buildFloatingCart() {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fitur Checkout akan segera hadir!')),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          // Gradient Emas Mewah
          gradient: const LinearGradient(
            colors: [Color(0xFFD4AF37), Color(0xFFFFD700)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Cart dengan Badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shopping_bag,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${_getTotalItems()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 16),

            // Info Harga
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Total Pembayaran',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _formatCurrency(_getTotalPrice()),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),

            // Tombol Checkout
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Text(
                    'Checkout',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.gold,
                    size: 16,
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
