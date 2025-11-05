import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import User dari Firebase

// 'abstract' berarti class ini tidak bisa dibuat langsung,
// tapi harus salah satu dari turunannya (Initial, Loading, dll)
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

// 1. State Awal: Aplikasi baru dibuka
class AuthInitial extends AuthState {}

// 2. State Loading: Saat menekan tombol login/register
class AuthLoading extends AuthState {}

// 3. State Berhasil: Login/Register sukses
class Authenticated extends AuthState {
  final User user; // Bawa data User yang sedang login

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

// 4. State Gagal/Logout: Belum login atau ada error
class Unauthenticated extends AuthState {
  final String? message; // Bawa pesan error jika ada

  const Unauthenticated({this.message});

  @override
  List<Object?> get props => [message];
}
