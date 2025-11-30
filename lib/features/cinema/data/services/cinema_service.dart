import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cinema_noir/features/cinema/data/models/cinema_model.dart';

class CinemaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<CinemaModel>> getCinemas() async {
    try {
      final snapshot = await _firestore.collection('cinemas').get();
      return snapshot.docs.map((doc) => CinemaModel.fromSnapshot(doc)).toList();
    } catch (e) {
      throw Exception('Failed to load cinemas: $e');
    }
  }

  Future<void> seedCinemas() async {
    final cinemas = [
      CinemaModel(
        id: '',
        name: 'Cinema Noir Jakarta',
        address: 'Grand Indonesia, Jakarta',
        latitude: -6.1944,
        longitude: 106.8229,
        imageUrl: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=1000&q=80',
      ),
      CinemaModel(
        id: '',
        name: 'Cinema Noir Surabaya',
        address: 'Tunjungan Plaza, Surabaya',
        latitude: -7.2629,
        longitude: 112.7416,
        imageUrl: 'https://images.unsplash.com/photo-1517604931442-710e8e929340?auto=format&fit=crop&w=1000&q=80',
      ),
       CinemaModel(
        id: '',
        name: 'Cinema Noir Bandung',
        address: 'Paris Van Java, Bandung',
        latitude: -6.8898,
        longitude: 107.5966,
        imageUrl: 'https://images.unsplash.com/photo-1517604931442-710e8e929340?auto=format&fit=crop&w=1000&q=80',
      ),
    ];

    final collection = _firestore.collection('cinemas');
    final snapshot = await collection.get();
    
    if (snapshot.docs.isEmpty) {
      for (var cinema in cinemas) {
        await collection.add(cinema.toMap());
      }
    }
  }
}
