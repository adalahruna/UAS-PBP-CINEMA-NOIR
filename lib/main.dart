import 'package:flutter/material.dart';
import 'package:cinema_noir/app_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cinema_noir/firebase_options.dart';

void main() async {
  // Pastikan Flutter binding sudah siap
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform);


  await Supabase.initialize(
    url: 'https://msilqepklwsdvftecdov.supabase.co', 
    anonKey:'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1zaWxxZXBrbHdzZHZmdGVjZG92Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM3MDg3NDMsImV4cCI6MjA3OTI4NDc0M30.Vo140QJzu2xr4OFwd4KOVcdkWUZIGeGat44Qi2sEqMo', 
  );

  // Jalankan aplikasi
  runApp(const AppWidget());
}
