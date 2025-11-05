import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:cinema_noir/features/auth/presentation/pages/login_page.dart';
import 'package:cinema_noir/features/auth/presentation/pages/register_page.dart';
import 'package:cinema_noir/features/home/presentation/pages/home_page.dart';

// Import Firebase nanti untuk redirect

class AppRouter {
  // Buat router-nya
  static final GoRouter router = GoRouter(
    // Rute awal saat aplikasi dibuka
    initialLocation: '/login', // Kita set ke login dulu
    // Daftar semua rute/halaman
    routes: [
      GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginPage();
        },
      ),
      GoRoute(
        path: '/register',
        builder: (BuildContext context, GoRouterState state) {
          return const RegisterPage();
        },
      ),
      GoRoute(
        path: '/', // Rute '/' adalah untuk HomePage
        builder: (BuildContext post, GoRouterState state) {
          return const HomePage();
        },
      ),
    ],

    // Nanti kita tambahkan 'redirect' di sini
    // untuk cek status login Firebase
  );
}
