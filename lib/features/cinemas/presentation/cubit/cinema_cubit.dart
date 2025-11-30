import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinema_noir/features/cinemas/data/models/cinema_model.dart';
import 'package:cinema_noir/features/cinemas/presentation/cubit/cinema_state.dart';

class CinemaCubit extends Cubit<CinemaState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CinemaCubit() : super(CinemaInitial());

  Future<void> fetchCinemas() async {
    try {
      emit(CinemaLoading());

      // Check if we need to seed data
      final collection = _firestore.collection('cinemas_v5'); // Bumped version to force refresh
      final snapshot = await collection.get();

      if (snapshot.docs.isEmpty) {
        await _seedCinemas();
      }

      // Fetch fresh data
      final freshSnapshot = await collection.get();
      final cinemas = freshSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Ensure ID is set
        return CinemaModel.fromJson(data);
      }).toList();

      // Group cinemas by city
      final Map<String, List<CinemaModel>> cinemasByCity = {};
      for (var cinema in cinemas) {
        if (!cinemasByCity.containsKey(cinema.city)) {
          cinemasByCity[cinema.city] = [];
        }
        cinemasByCity[cinema.city]!.add(cinema);
      }

      final cities = cinemasByCity.keys.toList()..sort();

      emit(CinemaLoaded(
        cinemas: cinemas,
        cinemasByCity: cinemasByCity,
        cities: cities,
      ));
    } catch (e) {
      emit(CinemaError(e.toString()));
    }
  }

  Future<void> _seedCinemas() async {
    final cinemas = _getMockCinemas();
    final collection = _firestore.collection('cinemas_v5'); // Bumped version
    
    for (var cinema in cinemas) {
      // Create a new map without the ID, let Firestore generate it or use the ID as doc ID
      final data = cinema.toJson();
      data.remove('id'); 
      // Use deterministic ID for easier updates
      await collection.doc(cinema.id).set(data);
    }
  }

  List<CinemaModel> _getMockCinemas() {
    return [
      const CinemaModel(
        id: '1',
        name: 'Plaza Indonesia XXI',
        address: 'Plaza Indonesia Lt. 6, Jl. M.H. Thamrin Kav. 28-30',
        city: 'Jakarta',
        phone: '(021) 39838779',
        latitude: -6.1931,
        longitude: 106.8217,
        facilities: ['IMAX', 'Dolby Atmos', 'The Premiere', 'Cafe'],
        imageUrl: 'https://images.pexels.com/photos/7991579/pexels-photo-7991579.jpeg?auto=compress&cs=tinysrgb&w=800',
        isOpen: true,
        openingHours: '10:00 - 22:00',
        rating: 4.8,
      ),
      const CinemaModel(
        id: '2',
        name: 'Plaza Senayan XXI',
        address: 'Plaza Senayan Lt. P5, Jl. Asia Afrika No. 8',
        city: 'Jakarta',
        phone: '(021) 5725535',
        latitude: -6.2255,
        longitude: 106.7985,
        facilities: ['The Premiere', 'Dolby Atmos', 'Lounge'],
        imageUrl: 'https://images.pexels.com/photos/7991226/pexels-photo-7991226.jpeg?auto=compress&cs=tinysrgb&w=800',
        isOpen: true,
        openingHours: '10:00 - 22:00',
        rating: 4.7,
      ),
      const CinemaModel(
        id: '3',
        name: 'CGV Central Park',
        address: 'Central Park Mall Lt. 8, Jl. Letjen S. Parman Kav. 28',
        city: 'Jakarta',
        phone: '(021) 29200100',
        latitude: -6.1777,
        longitude: 106.7910,
        facilities: ['Velvet Class', '4DX', 'Satin', 'Gold Class'],
        imageUrl: 'https://images.pexels.com/photos/7991227/pexels-photo-7991227.jpeg?auto=compress&cs=tinysrgb&w=800',
        isOpen: true,
        openingHours: '10:00 - 22:00',
        rating: 4.6,
      ),
      const CinemaModel(
        id: '4',
        name: 'Summarecon Mal Serpong XXI',
        address: 'Summarecon Mal Serpong Lt. 3, Jl. Boulevard Gading Serpong',
        city: 'Tangerang',
        phone: '(021) 29310521',
        latitude: -6.2407,
        longitude: 106.6288,
        facilities: ['The Premiere', 'Dolby Atmos', 'IMAX'],
        imageUrl: 'https://images.pexels.com/photos/7991225/pexels-photo-7991225.jpeg?auto=compress&cs=tinysrgb&w=800',
        isOpen: true,
        openingHours: '10:00 - 22:00',
        rating: 4.7,
      ),
      const CinemaModel(
        id: '5',
        name: 'AEON Mall BSD City XXI',
        address: 'AEON Mall BSD City Lt. 3, Jl. BSD Raya Utama',
        city: 'Tangerang',
        phone: '(021) 29168221',
        latitude: -6.3041,
        longitude: 106.6438,
        facilities: ['The Premiere', 'Dolby Atmos'],
        imageUrl: 'https://images.pexels.com/photos/7991580/pexels-photo-7991580.jpeg?auto=compress&cs=tinysrgb&w=800',
        isOpen: true,
        openingHours: '10:00 - 22:00',
        rating: 4.5,
      ),
      const CinemaModel(
        id: '6',
        name: 'CGV Paris Van Java',
        address: 'Paris Van Java Resort Lifestyle Place, Jl. Sukajadi No. 131-139',
        city: 'Bandung',
        phone: '(022) 82063630',
        latitude: -6.8889,
        longitude: 107.5958,
        facilities: ['Velvet Class', '4DX', 'Sweetbox'],
        imageUrl: 'https://images.pexels.com/photos/7991228/pexels-photo-7991228.jpeg?auto=compress&cs=tinysrgb&w=800',
        isOpen: true,
        openingHours: '10:00 - 22:00',
        rating: 4.6,
      ),
      const CinemaModel(
        id: '7',
        name: 'Transmart Buah Batu XXI',
        address: 'Transmart Buah Batu Square, Jl. Bojongsoang Raya No. 269',
        city: 'Bandung',
        phone: '(022) 86012956',
        latitude: -6.9669,
        longitude: 107.6386,
        facilities: ['Dolby Atmos', 'Refreshments'],
        imageUrl: 'https://images.pexels.com/photos/7991581/pexels-photo-7991581.jpeg?auto=compress&cs=tinysrgb&w=800',
        isOpen: true,
        openingHours: '10:00 - 22:00',
        rating: 4.4,
      ),
      const CinemaModel(
        id: '8',
        name: 'Tunjungan 5 XXI',
        address: 'Tunjungan Plaza 5 Lt. 10, Jl. Basuki Rahmat No. 8-12',
        city: 'Surabaya',
        phone: '(031) 51164521',
        latitude: -7.2627,
        longitude: 112.7391,
        facilities: ['IMAX', 'The Premiere', 'Dolby Atmos'],
        imageUrl: 'https://images.pexels.com/photos/7991582/pexels-photo-7991582.jpeg?auto=compress&cs=tinysrgb&w=800',
        isOpen: true,
        openingHours: '10:00 - 22:00',
        rating: 4.8,
      ),
      const CinemaModel(
        id: '9',
        name: 'Pakuwon Mall XXI',
        address: 'Pakuwon Mall Lt. 2, Jl. Puncak Indah Lontar No. 2',
        city: 'Surabaya',
        phone: '(031) 7390221',
        latitude: -7.2890,
        longitude: 112.6753,
        facilities: ['IMAX', 'The Premiere', 'Dolby Atmos'],
        imageUrl: 'https://images.pexels.com/photos/7991224/pexels-photo-7991224.jpeg?auto=compress&cs=tinysrgb&w=800',
        isOpen: true,
        openingHours: '10:00 - 22:00',
        rating: 4.9,
      ),
      const CinemaModel(
        id: '10',
        name: 'Beachwalk XXI',
        address: 'Beachwalk Shopping Center Lt. 2, Jl. Pantai Kuta',
        city: 'Bali',
        phone: '(0361) 8465621',
        latitude: -8.7169,
        longitude: 115.1688,
        facilities: ['The Premiere', 'Dolby Atmos', 'Ocean View'],
        imageUrl: 'https://images.pexels.com/photos/7991229/pexels-photo-7991229.jpeg?auto=compress&cs=tinysrgb&w=800',
        isOpen: true,
        openingHours: '10:00 - 23:00',
        rating: 4.7,
      ),
    ];
  }
}
