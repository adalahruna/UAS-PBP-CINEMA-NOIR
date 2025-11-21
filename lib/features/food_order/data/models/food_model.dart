class FoodModel {
  final String id;
  final String name;
  final String description;
  final int price;
  final String imageUrl;
  final String category; // 'combo', 'popcorn', 'drink', 'snack'
  final double rating;

  const FoodModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.rating = 4.5, // Default rating
  });
}
