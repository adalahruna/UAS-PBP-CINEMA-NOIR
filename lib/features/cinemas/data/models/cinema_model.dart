import 'package:equatable/equatable.dart';

class CinemaModel extends Equatable {
  final String id;
  final String name;
  final String address;
  final String city;
  final String phone;
  final double? latitude;
  final double? longitude;
  final List<String> facilities;
  final String? imageUrl;
  final bool isOpen;
  final String? openingHours;

  const CinemaModel({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.phone,
    this.latitude,
    this.longitude,
    this.facilities = const [],
    this.imageUrl,
    this.isOpen = true,
    this.openingHours,
  });

  factory CinemaModel.fromJson(Map<String, dynamic> json) {
    return CinemaModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      phone: json['phone'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      facilities: json['facilities'] != null
          ? List<String>.from(json['facilities'])
          : [],
      imageUrl: json['imageUrl'],
      isOpen: json['isOpen'] ?? true,
      openingHours: json['openingHours'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'city': city,
      'phone': phone,
      'latitude': latitude,
      'longitude': longitude,
      'facilities': facilities,
      'imageUrl': imageUrl,
      'isOpen': isOpen,
      'openingHours': openingHours,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        city,
        phone,
        latitude,
        longitude,
        facilities,
        imageUrl,
        isOpen,
        openingHours,
      ];
}
