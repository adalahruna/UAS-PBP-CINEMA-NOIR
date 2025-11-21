import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cinema_noir/core/constants/app_colors.dart';
import 'package:cinema_noir/features/food_order/data/models/food_model.dart';

// --- Import Widget Terpisah ---
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
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'all';
  final Map<String, int> _cart = {};

  // State untuk mode pencarian
  bool _isSearching = false;
  String _searchQuery = '';

  // Data Dummy Menu (Lengkap)
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

  // List untuk menampung hasil pencarian
  List<FoodModel> _filteredFoods = [];

  @override
  void initState() {
    super.initState();
    _filteredFoods = _allFoods; // Awalnya tampilkan semua
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _isSearching = _searchQuery.isNotEmpty;

      if (_isSearching) {
        // Filter berdasarkan query pencarian
        _filteredFoods = _allFoods
            .where(
              (food) =>
                  food.name.toLowerCase().contains(_searchQuery.toLowerCase()),
            )
            .toList();
      } else {
        // Jika kosong, kembalikan ke semua (tapi UI akan berubah ke mode normal)
        _filteredFoods = _allFoods;
      }
    });
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
      ),

      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. SEARCH BAR (Selalu Muncul di Atas)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.darkGrey,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: _isSearching ? AppColors.gold : Colors.white10,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Cari popcorn, minuman...',
                        hintStyle: TextStyle(
                          color: AppColors.textGrey.withOpacity(0.5),
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: _isSearching
                              ? AppColors.gold
                              : AppColors.textGrey,
                        ),
                        suffixIcon: _isSearching
                            ? IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  // FocusScope.of(context).unfocus(); // Opsional: tutup keyboard
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 2. DYNAMIC CONTENT
                // Jika sedang mencari (_isSearching == true), TAMPILKAN HASIL PENCARIAN
                // Jika tidak, TAMPILKAN CAROUSEL & KATEGORI (Normal Mode)
                if (_isSearching) ...[
                  // --- MODE PENCARIAN ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const Icon(Icons.manage_search, color: AppColors.gold),
                        const SizedBox(width: 8),
                        Text(
                          'Hasil Pencarian: "$_searchQuery"',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tampilkan List Hasil Filter
                  _buildFoodList(isSearchResult: true),
                ] else ...[
                  // --- MODE NORMAL ---

                  // Promo Carousel
                  const FoodPromoCarousel(),

                  const SizedBox(height: 24),

                  // Hot Items
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

                  // Kategori
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

                  // List Menu Normal
                  _buildFoodList(isSearchResult: false),
                ],

                const SizedBox(height: 100), // Padding Bawah untuk Cart
              ],
            ),
          ),

          // Floating Cart
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: hasItems ? 30 : -100,
            left: 20,
            right: 20,
            child: _buildFloatingCart(),
          ),
        ],
      ),
    );
  }

  // --- LIST BUILDER ---
  Widget _buildFoodList({required bool isSearchResult}) {
    // Logic pemilihan data sumber
    List<FoodModel> foodsToShow;

    if (isSearchResult) {
      // Jika mode pencarian, pakai data yang sudah difilter text
      foodsToShow = _filteredFoods;
    } else {
      // Jika mode normal, filter berdasarkan kategori tombol
      foodsToShow = _selectedCategory == 'all'
          ? _allFoods
          : _allFoods.where((f) => f.category == _selectedCategory).toList();
    }

    if (foodsToShow.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: AppColors.textGrey.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                isSearchResult ? "Menu tidak ditemukan" : "Kategori ini kosong",
                style: TextStyle(
                  color: AppColors.textGrey.withOpacity(0.5),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: foodsToShow.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final food = foodsToShow[index];
        return _buildFoodListItem(food);
      },
    );
  }

  // --- KARTU MENU VERTIKAL ---
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
