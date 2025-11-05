import 'package:flutter/material.dart';
import 'package:cinema_noir/app_widget.dart';

// Import Firebase Core
import 'package:firebase_core/firebase_core.dart';
// Import file konfigurasi yang baru dibuat
import 'package:cinema_noir/firebase_options.dart';

void main() async {
  // Pastikan Flutter binding sudah siap
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Jalankan aplikasi
  runApp(const AppWidget());
}
