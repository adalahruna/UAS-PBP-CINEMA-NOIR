import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

// Class ini adalah "Listenable" yang GoRouter butuhkan.
// Tugasnya hanya mendengarkan stream Firebase dan memanggil notifyListeners()
// saat ada perubahan (login atau logout).
class AuthStreamListener extends ChangeNotifier {
  late final StreamSubscription<User?> _subscription;

  AuthStreamListener() {
    // Dengarkan stream authStateChanges()
    _subscription = FirebaseAuth.instance.authStateChanges().listen((
      User? user,
    ) {
      // Jika ada perubahan, beri tahu GoRouter untuk
      // menjalankan ulang logika redirect-nya.
      notifyListeners();
    });
  }

  // Jangan lupa untuk membatalkan listener-nya
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
