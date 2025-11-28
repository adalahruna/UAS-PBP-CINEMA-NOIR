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
import 'package:cinema_noir/features/food_order/presentation/widgets/food_detail_bottom_sheet.dart';

class FoodOrderPage extends StatefulWidget {
  const FoodOrderPage({super.key});

  @override
  State<FoodOrderPage> createState() => _FoodOrderPageState();
}

class _FoodOrderPageState extends State<FoodOrderPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  // State
  String _selectedCategory = 'all';
  final Map<String, int> _cart = {};
  bool _isSearching = false;
  String _searchQuery = '';
  bool _isGridView = true; // Toggle untuk grid/list view

  // Data Dummy Menu
  final List<FoodModel> _allFoods = [
    const FoodModel(
      id: '1',
      name: 'Couple Date Combo',
      description: 'Large Popcorn + 2 Drinks + Nachos. Perfect for movie dates!',
      price: 85000,
      category: 'combo',
      imageUrl:
          'https://images.unsplash.com/photo-1578849278619-e73505e9610f?q=80&w=1000&auto=format&fit=crop',
      rating: 4.9,
    ),
    const FoodModel(
      id: '2',
      name: 'Caramel Popcorn XL',
      description: 'Extra large crispy popcorn with premium caramel coating.',
      price: 55000,
      category: 'popcorn',
      imageUrl:
          'https://images.unsplash.com/photo-1585647347384-2593bc35786b?q=80&w=1000&auto=format&fit=crop',
      rating: 4.8,
    ),
    const FoodModel(
      id: '3',
      name: 'Classic Salty Popcorn',
      description: 'Traditional movie theater popcorn, perfectly salted.',
      price: 40000,
      category: 'popcorn',
      imageUrl:
          'https://images.unsplash.com/photo-1505686994434-e3cc5abf1330?q=80&w=1000&auto=format&fit=crop',
      rating: 4.5,
    ),
    const FoodModel(
      id: '4',
      name: 'Coca Cola Large',
      description: 'Ice-cold refreshing carbonated drink.',
      price: 25000,
      category: 'drink',
      imageUrl:
          'https://images.unsplash.com/photo-1629203851122-3726ecdf080e?q=80&w=1000&auto=format&fit=crop',
      rating: 4.6,
    ),
    const FoodModel(
      id: '5',
      name: 'Iced Lemon Tea',
      description: 'Fresh lemon tea with ice cubes. Refreshing!',
      price: 30000,
      category: 'drink',
      imageUrl:
          'https://images.unsplash.com/photo-1556679343-c7306c1976bc?q=80&w=1000&auto=format&fit=crop',
      rating: 4.4,
    ),
    const FoodModel(
      id: '6',
      name: 'Nachos with Cheese',
      description: 'Crispy tortilla chips with melted cheese sauce.',
      price: 50000,
      category: 'snack',
      imageUrl:
          'https://images.unsplash.com/photo-1513456852971-30c0b8199d4d?q=80&w=1000&auto=format&fit=crop',
      rating: 4.9,
    ),
    const FoodModel(
      id: '7',
      name: 'Beef Hotdog',
      description: 'Grilled beef sausage in toasted bun.',
      price: 45000,
      category: 'snack',
      imageUrl:
          'https://images.unsplash.com/photo-1612392166686-ee72bc828089?q=80&w=1000&auto=format&fit=crop',
      rating: 4.3,
    ),
  ];

  List<FoodModel> _filteredFoods = [];

  @override
  void initState() {
    super.initState();
    _filteredFoods = _allFoods;
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
        _filteredFoods = _allFoods
            .where(
              (food) =>
                  food.name.toLowerCase().contains(_searchQuery.toLowerCase()),
            )
            .toList();
      } else {
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

  void _incrementItem(FoodModel food) {
    setState(() => _cart[food.id] = (_cart[food.id] ?? 0) + 1);
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

  void _showFoodDetail(BuildContext context, FoodModel food) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return FoodDetailBottomSheet(
              food: food,
              currentQty: _cart[food.id] ?? 0,
              onIncrement: () {
                _incrementItem(food);
                setModalState(() {});
              },
              onDecrement: () {
                _decrementItem(food);
                setModalState(() {});
              },
            );
          },
        );
      },
    );
  }

  // Get responsive cross axis count
  int _getCrossAxisCount(double screenWidth) {
    if (screenWidth > 1200) return 5;
    if (screenWidth > 900) return 4;
    if (screenWidth > 600) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final hasItems = _cart.isNotEmpty;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // App Bar
                SliverAppBar(
                  pinned: true,
                  floating: true,
                  backgroundColor: AppColors.darkBackground,
                  elevation: 0,
                  leading: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.darkGrey,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.gold,
                        size: 18,
                      ),
                    ),
                    onPressed: () => context.pop(),
                  ),
                  title: Text(
                    'Food',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                      letterSpacing: 2,
                      fontSize: isMobile ? 20 : 24,
                    ),
                  ),
                  centerTitle: true,
                ),

                // Search Bar (Movie-style centered with max width)
                SliverToBoxAdapter(
                  child: Center(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: (screenWidth * 0.85).clamp(0, 600),
                      ),
                      padding: EdgeInsets.fromLTRB(
                        isMobile ? 16 : 20,
                        10,
                        isMobile ? 16 : 20,
                        16,
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: AppColors.textWhite),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12.0,
                            horizontal: 16.0,
                          ),
                          hintText: 'Search food...',
                          hintStyle: const TextStyle(color: AppColors.textGrey),
                          prefixIcon: const Icon(Icons.search, color: AppColors.textGrey),
                          suffixIcon: _isSearching
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: AppColors.textGrey),
                                  onPressed: () {
                                    _searchController.clear();
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: AppColors.darkGrey,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: const BorderSide(color: AppColors.gold, width: 2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Dynamic Content
                if (_isSearching) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 20),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: AppColors.gold, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Results for "$_searchQuery"',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isMobile ? 14 : 16,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  _isGridView
                      ? _buildFoodGridSliver(isSearchResult: true, screenWidth: screenWidth)
                      : _buildFoodListSliver(isSearchResult: true, screenWidth: screenWidth),
                ] else ...[
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const FoodPromoCarousel(),
                        SizedBox(height: isMobile ? 24 : 32),
                        
                        // Hot Items Section
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 20),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.orange.shade600, Colors.red.shade600],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.local_fire_department_rounded,
                                  color: Colors.white,
                                  size: isMobile ? 18 : 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Hot Items!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isMobile ? 18 : 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        HotItemsCarousel(foods: _allFoods, onAdd: _incrementItem),
                        SizedBox(height: isMobile ? 24 : 32),
                        
                        // Browse Menu Section with View Toggle
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 20),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.gold.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.gold, width: 1.5),
                                ),
                                child: Icon(
                                  Icons.restaurant_menu_rounded,
                                  color: AppColors.gold,
                                  size: isMobile ? 18 : 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Browse Menu',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isMobile ? 18 : 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              // View Toggle Buttons
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.darkGrey,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.white10),
                                ),
                                child: Row(
                                  children: [
                                    _buildViewToggleButton(
                                      icon: Icons.grid_view_rounded,
                                      isSelected: _isGridView,
                                      onTap: () => setState(() => _isGridView = true),
                                      isMobile: isMobile,
                                    ),
                                    Container(
                                      width: 1,
                                      height: 24,
                                      color: Colors.white10,
                                    ),
                                    _buildViewToggleButton(
                                      icon: Icons.view_list_rounded,
                                      isSelected: !_isGridView,
                                      onTap: () => setState(() => _isGridView = false),
                                      isMobile: isMobile,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        FoodCategoryButtons(
                          selectedCategory: _selectedCategory,
                          onCategorySelected: (category) =>
                              setState(() => _selectedCategory = category),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                  _isGridView
                      ? _buildFoodGridSliver(isSearchResult: false, screenWidth: screenWidth)
                      : _buildFoodListSliver(isSearchResult: false, screenWidth: screenWidth),
                ],
                
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),

            // Floating Cart
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              bottom: hasItems ? 20 : -100,
              left: isMobile ? 16 : 20,
              right: isMobile ? 16 : 20,
              child: _buildFloatingCart(isMobile),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodGridSliver({required bool isSearchResult, required double screenWidth}) {
    List<FoodModel> foodsToShow;
    if (isSearchResult) {
      foodsToShow = _filteredFoods;
    } else {
      foodsToShow = _selectedCategory == 'all'
          ? _allFoods
          : _allFoods.where((f) => f.category == _selectedCategory).toList();
    }

    final isMobile = screenWidth < 768;
    final crossAxisCount = _getCrossAxisCount(screenWidth);
    final horizontalPadding = isMobile ? 16.0 : 20.0;
    final gridSpacing = isMobile ? 12.0 : 16.0;

    if (foodsToShow.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 24 : 32),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: isMobile ? 48 : 64,
                  color: AppColors.textGrey.withOpacity(0.5),
                ),
                SizedBox(height: isMobile ? 12 : 16),
                Text(
                  isSearchResult ? "No food found" : "Category is empty",
                  style: TextStyle(
                    color: AppColors.textGrey.withOpacity(0.5),
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: gridSpacing,
          crossAxisSpacing: gridSpacing,
          childAspectRatio: isMobile ? 0.7 : 0.75,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildFoodGridItem(foodsToShow[index], isMobile),
          childCount: foodsToShow.length,
        ),
      ),
    );
  }

  Widget _buildFoodGridItem(FoodModel food, bool isMobile) {
    final qty = _cart[food.id] ?? 0;
    final bool isSelected = qty > 0;

    return GestureDetector(
      onTap: () => _showFoodDetail(context, food),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.gold.withOpacity(0.08)
              : AppColors.darkGrey,
          borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
          border: isSelected
              ? Border.all(color: AppColors.gold.withOpacity(0.5), width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.gold.withOpacity(0.2)
                  : Colors.black.withOpacity(0.3),
              blurRadius: isMobile ? 8 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(isMobile ? 16 : 20),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: food.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[900],
                        child: const Center(
                          child: CircularProgressIndicator(color: AppColors.gold),
                        ),
                      ),
                    ),
                  ),
                  // Rating Badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 6 : 8,
                        vertical: isMobile ? 3 : 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: AppColors.gold, size: isMobile ? 10 : 12),
                          const SizedBox(width: 4),
                          Text(
                            food.rating.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isMobile ? 10 : 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 8 : 12),
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
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 12 : 14,
                          ),
                        ),
                        SizedBox(height: isMobile ? 2 : 4),
                        Text(
                          _formatCurrency(food.price),
                          style: TextStyle(
                            color: AppColors.gold,
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 11 : 13,
                          ),
                        ),
                      ],
                    ),
                    
                    // Add Button
                    if (qty == 0)
                      Container(
                        width: double.infinity,
                        height: isMobile ? 28 : 32,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.gold, AppColors.gold.withOpacity(0.8)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _incrementItem(food),
                            borderRadius: BorderRadius.circular(10),
                            child: Center(
                              child: Text(
                                'ADD',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: isMobile ? 10 : 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        height: isMobile ? 28 : 32,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.gold, AppColors.gold.withOpacity(0.8)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: Icon(
                                Icons.remove_rounded,
                                size: isMobile ? 16 : 18,
                                color: Colors.black,
                              ),
                              onPressed: () => _decrementItem(food),
                            ),
                            Text(
                              '$qty',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: isMobile ? 12 : 14,
                              ),
                            ),
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: Icon(
                                Icons.add_rounded,
                                size: isMobile ? 16 : 18,
                                color: Colors.black,
                              ),
                              onPressed: () => _incrementItem(food),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewToggleButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isMobile,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 8 : 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gold.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isSelected ? AppColors.gold : AppColors.textGrey,
          size: isMobile ? 18 : 20,
        ),
      ),
    );
  }

  Widget _buildFoodListSliver({required bool isSearchResult, required double screenWidth}) {
    List<FoodModel> foodsToShow;
    if (isSearchResult) {
      foodsToShow = _filteredFoods;
    } else {
      foodsToShow = _selectedCategory == 'all'
          ? _allFoods
          : _allFoods.where((f) => f.category == _selectedCategory).toList();
    }

    final isMobile = screenWidth < 768;
    final horizontalPadding = isMobile ? 16.0 : 20.0;

    if (foodsToShow.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 24 : 32),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: isMobile ? 48 : 64,
                  color: AppColors.textGrey.withOpacity(0.5),
                ),
                SizedBox(height: isMobile ? 12 : 16),
                Text(
                  isSearchResult ? "No food found" : "Category is empty",
                  style: TextStyle(
                    color: AppColors.textGrey.withOpacity(0.5),
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => Padding(
            padding: EdgeInsets.only(bottom: isMobile ? 12 : 16),
            child: _buildFoodListItem(foodsToShow[index], isMobile),
          ),
          childCount: foodsToShow.length,
        ),
      ),
    );
  }

  Widget _buildFoodListItem(FoodModel food, bool isMobile) {
    final qty = _cart[food.id] ?? 0;
    final bool isSelected = qty > 0;

    return GestureDetector(
      onTap: () => _showFoodDetail(context, food),
      child: Container(
        height: isMobile ? 120 : 140,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.gold.withOpacity(0.08)
              : AppColors.darkGrey,
          borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
          border: isSelected
              ? Border.all(color: AppColors.gold.withOpacity(0.5), width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.gold.withOpacity(0.2)
                  : Colors.black.withOpacity(0.3),
              blurRadius: isMobile ? 8 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(isMobile ? 16 : 20),
              ),
              child: CachedNetworkImage(
                imageUrl: food.imageUrl,
                width: isMobile ? 120 : 140,
                height: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[900],
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.gold),
                  ),
                ),
              ),
            ),
            
            // Details
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                food.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: isMobile ? 14 : 16,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 6 : 8,
                                vertical: isMobile ? 3 : 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star, color: AppColors.gold, size: isMobile ? 10 : 12),
                                  const SizedBox(width: 4),
                                  Text(
                                    food.rating.toString(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isMobile ? 10 : 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isMobile ? 4 : 6),
                        Text(
                          food.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textGrey,
                            fontSize: isMobile ? 11 : 12,
                          ),
                        ),
                      ],
                    ),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatCurrency(food.price),
                          style: TextStyle(
                            color: AppColors.gold,
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 14 : 16,
                          ),
                        ),
                        
                        // Add Button
                        if (qty == 0)
                          Container(
                            height: isMobile ? 32 : 36,
                            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.gold, AppColors.gold.withOpacity(0.8)],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _incrementItem(food),
                                borderRadius: BorderRadius.circular(10),
                                child: Center(
                                  child: Text(
                                    'ADD',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: isMobile ? 11 : 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        else
                          Container(
                            height: isMobile ? 32 : 36,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.gold, AppColors.gold.withOpacity(0.8)],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 10),
                                  constraints: const BoxConstraints(),
                                  icon: Icon(
                                    Icons.remove_rounded,
                                    size: isMobile ? 16 : 18,
                                    color: Colors.black,
                                  ),
                                  onPressed: () => _decrementItem(food),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 10),
                                  child: Text(
                                    '$qty',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: isMobile ? 12 : 14,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 10),
                                  constraints: const BoxConstraints(),
                                  icon: Icon(
                                    Icons.add_rounded,
                                    size: isMobile ? 16 : 18,
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
      ),
    );
  }

  Widget _buildFloatingCart(bool isMobile) {
    return GestureDetector(
      onTap: () {
        final List<Map<String, dynamic>> checkoutItems = [];
        _cart.forEach((id, qty) {
          final food = _allFoods.firstWhere((element) => element.id == id);
          checkoutItems.add({
            'id': food.id,
            'name': food.name,
            'price': food.price,
            'qty': qty,
            'image': food.imageUrl,
          });
        });
        if (checkoutItems.isNotEmpty) {
          context.push('/food/food-checkout', extra: checkoutItems);
        }
      },
      child: Container(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.gold, Color(0xFFF4D03F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(isMobile ? 20 : 25),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withOpacity(0.5),
              blurRadius: isMobile ? 20 : 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 8 : 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_bag_rounded,
                color: Colors.black,
                size: isMobile ? 20 : 24,
              ),
            ),
            SizedBox(width: isMobile ? 12 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_getTotalItems()} Items',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: isMobile ? 11 : 13,
                    ),
                  ),
                  Text(
                    _formatCurrency(_getTotalPrice()),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_rounded,
              color: Colors.black,
              size: isMobile ? 24 : 28,
            ),
          ],
        ),
      ),
    );
  }
}