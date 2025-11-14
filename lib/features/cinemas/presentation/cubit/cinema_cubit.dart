import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinema_noir/features/cinemas/data/models/cinema_model.dart';
import 'package:cinema_noir/features/cinemas/presentation/cubit/cinema_state.dart';

class CinemaCubit extends Cubit<CinemaState> {
  CinemaCubit() : super(CinemaInitial());

  Future<void> fetchCinemas() async {
    try {
      emit(CinemaLoading());

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock data - In real app, this would come from API
      final cinemas = _getMockCinemas();

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

  List<CinemaModel> _getMockCinemas() {
    return [
      const CinemaModel(
        id: '1',
        name: 'Cinema XXI Grand Indonesia',
        address: 'Grand Indonesia Shopping Town, Jl. MH Thamrin No.1',
        city: 'Jakarta',
        phone: '021-23588021',
        latitude: -6.195396,
        longitude: 106.822746,
        facilities: ['IMAX', 'Dolby Atmos', 'Premiere', 'Food Court'],
        imageUrl: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=800',
        isOpen: true,
        openingHours: '10:00 - 22:00',
      ),
      const CinemaModel(
        id: '2',
        name: 'Cinema XXI Plaza Senayan',
        address: 'Plaza Senayan, Jl. Asia Afrika No.8',
        city: 'Jakarta',
        phone: '021-5725555',
        latitude: -6.226464,
        longitude: 106.799324,
        facilities: ['4DX', 'Dolby Atmos', 'VIP Lounge'],
        imageUrl: 'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?w=800',
        isOpen: true,
        openingHours: '10:00 - 22:00',
      ),
      const CinemaModel(
        id: '3',
        name: 'Cinema XXI Central Park',
        address: 'Central Park Mall, Jl. Letjen S. Parman',
        city: 'Jakarta',
        phone: '021-29345555',
        latitude: -6.177799,
        longitude: 106.790428,
        facilities: ['IMAX', 'Velvet Class', 'Parking'],
        imageUrl: 'https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=800',
        isOpen: true,
        openingHours: '10:00 - 22:00',
      ),
      const CinemaModel(
        id: '4',
        name: 'Cinema XXI Summarecon Mall Serpong',
        address: 'Summarecon Mall Serpong, Gading Serpong',
        city: 'Tangerang',
        phone: '021-29388888',
        latitude: -6.242181,
        longitude: 106.625626,
        facilities: ['Premiere', 'Dolby Atmos', 'Food Court', 'Kids Play Area'],
        imageUrl: 'https://images.unsplash.com/photo-1594909122845-11baa439b7bf?w=800',
        isOpen: true,
        openingHours: '10:00 - 22:00',
      ),
      const CinemaModel(
        id: '5',
        name: 'Cinema XXI AEON Mall BSD',
        address: 'AEON Mall BSD City, BSD City',
        city: 'Tangerang',
        phone: '021-50818888',
        latitude: -6.302103,
        longitude: 106.652306,
        facilities: ['IMAX', '4DX', 'VIP'],
        imageUrl: 'https://images.unsplash.com/photo-1478720568477-152d9b164e26?w=800',
        isOpen: true,
        openingHours: '10:00 - 22:00',
      ),
      const CinemaModel(
        id: '6',
        name: 'Cinema XXI Paris Van Java',
        address: 'Paris Van Java Mall, Jl. Sukajadi No.137-139',
        city: 'Bandung',
        phone: '022-82062121',
        latitude: -6.896654,
        longitude: 107.590118,
        facilities: ['Premiere', 'Dolby Atmos', 'Cafe'],
        imageUrl: 'https://images.unsplash.com/photo-1598899134739-24c46f58b8c0?w=800',
        isOpen: true,
        openingHours: '10:00 - 22:00',
      ),
      const CinemaModel(
        id: '7',
        name: 'Cinema XXI Transmart Buah Batu',
        address: 'Transmart Buah Batu, Jl. Soekarno Hatta No.446',
        city: 'Bandung',
        phone: '022-87242121',
        latitude: -6.943313,
        longitude: 107.638197,
        facilities: ['IMAX', 'Parking', 'Food Court'],
        imageUrl: 'https://images.unsplash.com/photo-1617944743084-2a0e4e3c9e79?w=800',
        isOpen: true,
        openingHours: '10:00 - 22:00',
      ),
      const CinemaModel(
        id: '8',
        name: 'Cinema XXI Tunjungan Plaza',
        address: 'Tunjungan Plaza, Jl. Basuki Rahmat No.8-12',
        city: 'Surabaya',
        phone: '031-5318888',
        latitude: -7.263055,
        longitude: 112.739028,
        facilities: ['Premiere', 'Dolby Atmos', 'VIP Lounge'],
        imageUrl: 'https://images.unsplash.com/photo-1568876694728-451bbf694b83?w=800',
        isOpen: true,
        openingHours: '10:00 - 22:00',
      ),
      const CinemaModel(
        id: '9',
        name: 'Cinema XXI Pakuwon Mall',
        address: 'Pakuwon Mall, Jl. Puncak Indah Lontar No.2',
        city: 'Surabaya',
        phone: '031-73999888',
        latitude: -7.298603,
        longitude: 112.671623,
        facilities: ['IMAX', '4DX', 'Velvet Class'],
        imageUrl: 'https://images.unsplash.com/photo-1595769816263-9b910be24d5f?w=800',
        isOpen: true,
        openingHours: '10:00 - 22:00',
      ),
      const CinemaModel(
        id: '10',
        name: 'Cinema XXI Beachwalk',
        address: 'Beachwalk Shopping Center, Jl. Pantai Kuta',
        city: 'Bali',
        phone: '0361-8464777',
        latitude: -8.718060,
        longitude: 115.173714,
        facilities: ['Premiere', 'Dolby Atmos', 'Ocean View'],
        imageUrl: 'https://images.unsplash.com/photo-1635805737707-575885ab0b4d?w=800',
        isOpen: true,
        openingHours: '10:00 - 23:00',
      ),
    ];
  }
}
