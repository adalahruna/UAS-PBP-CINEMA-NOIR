import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cinema_noir/core/constants/app_colors.dart';
import 'package:cinema_noir/features/food_order/data/models/food_model.dart';
import 'package:cinema_noir/features/food_order/presentation/widgets/food_promo_carousel.dart';
import 'package:cinema_noir/features/food_order/presentation/widgets/hot_items_carousel.dart';
import 'package:cinema_noir/features/food_order/presentation/widgets/food_category_buttons.dart';

class FoodOrderPage extends StatefulWidget {
  const FoodOrderPage({super.key});

  @override
  State<FoodOrderPage> createState() => _FoodOrderPageState();
}

class _FoodOrderPageState extends State<FoodOrderPage> {
  final ScrollController _scrollController = ScrollController();

  // State Kategori Aktif (Default 'all')
  String _selectedCategory = 'all';

  // Keranjang Belanja
  // Key: Food ID, Value: Jumlah (Qty)
  final Map<String, int> _cart = {};

  // Data Dummy Menu (Lengkap & Menarik)
  final List<FoodModel> _allFoods = [
    const FoodModel(
      id: '1',
      name: 'Combo Couple Date',
      description: '1 Large Popcorn + 2 Coca Cola + 1 Nachos Cheese.',
      price: 85000,
      category: 'combo',
      imageUrl:
          'https://images.unsplash.com/photo-1585647347384-2593bc35786b?q=80&w=1000&auto=format&fit=crop',
      rating: 4.9,
    ),
    const FoodModel(
      id: '2',
      name: 'Caramel Popcorn XL',
      description: 'Popcorn renyah dengan lapisan karamel manis premium.',
      price: 55000,
      category: 'popcorn',
      imageUrl:
          'https://images.unsplash.com/photo-1578849278619-e73505e9610f?q=80&w=1000&auto=format&fit=crop',
      rating: 4.8,
    ),
    const FoodModel(
      id: '3',
      name: 'Salty Popcorn',
      description: 'Popcorn gurih original bioskop.',
      price: 40000,
      category: 'popcorn',
      imageUrl:
          'https://images.unsplash.com/photo-1605218427368-35b0121d2319?q=80&w=1000&auto=format&fit=crop',
      rating: 4.5,
    ),
    const FoodModel(
      id: '4',
      name: 'Coca Cola Large',
      description: 'Minuman bersoda dingin menyegarkan.',
      price: 25000,
      category: 'drink',
      imageUrl:
          'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?q=80&w=1000&auto=format&fit=crop',
      rating: 4.6,
    ),
    const FoodModel(
      id: '5',
      name: 'Iced Lemon Tea',
      description: 'Teh lemon segar dengan es batu.',
      price: 30000,
      category: 'drink',
      imageUrl:
          'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?q=80&w=1000&auto=format&fit=crop',
      rating: 4.4,
    ),
    const FoodModel(
      id: '6',
      name: 'Nachos Cheese',
      description: 'Keripik tortilla renyah saus keju.',
      price: 50000,
      category: 'snack',
      imageUrl:
          'https://images.unsplash.com/photo-1574315042633-5945277350cd?q=80&w=1000&auto=format&fit=crop',
      rating: 4.9,
    ),
    const FoodModel(
      id: '7',
      name: 'Hotdog Beef',
      description: 'Roti sosis sapi panggang.',
      price: 45000,
      category: 'snack',
      imageUrl:
          'https://images.unsplash.com/photo-1619740455993-9e612b1af08a?q=80&w=1000&auto=format&fit=crop',
      rating: 4.3,
    ),
  ];

  @override
  void dispose() {
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

  // --- LOGIC KERANJANG ---
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
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
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
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // TODO: Implement Search Logic Here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur pencarian segera hadir!')),
              );
            },
          ),
        ],
      ),

      body: Stack(
        children: [
          // Konten Halaman (Scrollable)
          SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // 1. PROMO CAROUSEL (Widget Terpisah)
                const FoodPromoCarousel(),

                const SizedBox(height: 24),

                // 2. HOT ITEMS (Widget Terpisah)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.local_fire_department,
                        color: Colors.orangeAccent,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Lagi Hot Nih!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                HotItemsCarousel(foods: _allFoods, onAdd: _incrementItem),

                const SizedBox(height: 24),

                // 3. KATEGORI SIMETRIS (Widget Terpisah)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Text(
                    'Jelajahi Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FoodCategoryButtons(
                  selectedCategory: _selectedCategory,
                  onCategorySelected: (category) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                ),

                const SizedBox(height: 24),

                // 4. LIST MENU VERTIKAL (Filtered)
                _buildFoodList(),

                const SizedBox(height: 100), // Padding Bawah untuk Cart
              ],
            ),
          ),

          // Floating Cart (Keranjang Melayang)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: hasItems ? 30 : -100, // Sembunyi jika kosong
            left: 20,
            right: 20,
            child: _buildFloatingCart(),
          ),
        ],
      ),
    );
  }

  // --- LIST BUILDER (Filtered by Button Category) ---
  Widget _buildFoodList() {
    final foods = _selectedCategory == 'all'
        ? _allFoods
        : _allFoods.where((f) => f.category == _selectedCategory).toList();

    if (foods.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: Text(
            "Menu kosong untuk kategori ini",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true, // Agar bisa di dalam SingleChildScrollView
      physics: const NeverScrollableScrollPhysics(), // Scroll ikut parent
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: foods.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final food = foods[index];
        return _buildFoodListItem(food);
      },
    );
  }

  // --- KARTU MENU VERTIKAL (Custom Widget di dalam file ini) ---
  Widget _buildFoodListItem(FoodModel food) {
    final qty = _cart[food.id] ?? 0;
    final bool isSelected = qty > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 110,
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.gold.withOpacity(0.05)
            : AppColors.darkGrey,
        borderRadius: BorderRadius.circular(16),
        border: isSelected
            ? Border.all(color: AppColors.gold.withOpacity(0.3), width: 1)
            : Border.all(color: Colors.transparent),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Gambar
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(16),
            ),
            child: CachedNetworkImage(
              imageUrl: food.imageUrl,
              width: 110,
              height: 110,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey[900]),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.fastfood, color: Colors.grey),
            ),
          ),

          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        food.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        food.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),

                  // Harga & Kontrol
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatCurrency(food.price),
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),

                      // Tombol ADD / Counter
                      if (qty == 0)
                        GestureDetector(
                          onTap: () => _incrementItem(food),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.gold),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'ADD',
                              style: TextStyle(
                                color: AppColors.gold,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      else
                        Container(
                          height: 30,
                          decoration: BoxDecoration(
                            color: AppColors.gold,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 30),
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
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 30),
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
          ),
        ],
      ),
    );
  }

  // --- FLOATING CART BAR ---
  Widget _buildFloatingCart() {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to Checkout
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fitur Checkout akan segera hadir!')),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.gold, Color(0xFFF4D03F)],
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
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_bag,
                color: Colors.black,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_getTotalItems()} Items',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _formatCurrency(_getTotalPrice()),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded, color: Colors.black),
          ],
        ),
      ),
    );
  }
}
