class CinemaModel {
  final String id;
  final String name;
  final String location;

  const CinemaModel({
    required this.id,
    required this.name,
    required this.location,
  });

  // Data Mock Cinema
  static List<CinemaModel> get mockCinemas => [
        const CinemaModel(id: '1', name: 'Cinema XXI Grand Indonesia', location: 'Jakarta Pusat'),
        const CinemaModel(id: '2', name: 'CGV Pacific Place', location: 'Jakarta Selatan'),
        const CinemaModel(id: '3', name: 'IMAX Gandaria City', location: 'Jakarta Selatan'),
        const CinemaModel(id: '4', name: 'Cinema XXI Plaza Senayan', location: 'Jakarta Pusat'),
        const CinemaModel(id: '5', name: 'Cinépolis Pejaten Village', location: 'Jakarta Selatan'),
        const CinemaModel(id: '6', name: 'FLIX Cinema PIK Avenue', location: 'Jakarta Utara'),
        const CinemaModel(id: '7', name: 'Cinema XXI Kota Kasablanka', location: 'Jakarta Selatan'),
        const CinemaModel(id: '8', name: 'CGV Central Park', location: 'Jakarta Barat'),
      ];
}
