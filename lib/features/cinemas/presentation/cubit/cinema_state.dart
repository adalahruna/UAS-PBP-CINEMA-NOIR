import 'package:equatable/equatable.dart';
import 'package:cinema_noir/features/cinemas/data/models/cinema_model.dart';

abstract class CinemaState extends Equatable {
  const CinemaState();

  @override
  List<Object?> get props => [];
}

class CinemaInitial extends CinemaState {}

class CinemaLoading extends CinemaState {}

class CinemaLoaded extends CinemaState {
  final List<CinemaModel> cinemas;
  final Map<String, List<CinemaModel>> cinemasByCity;
  final List<String> cities;

  const CinemaLoaded({
    required this.cinemas,
    required this.cinemasByCity,
    required this.cities,
  });

  @override
  List<Object?> get props => [cinemas, cinemasByCity, cities];
}

class CinemaError extends CinemaState {
  final String message;

  const CinemaError(this.message);

  @override
  List<Object?> get props => [message];
}
