import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// --- Import Halaman-Halaman ---
import 'package:cinema_noir/features/auth/presentation/pages/login_page.dart';
import 'package:cinema_noir/features/auth/presentation/pages/register_page.dart';
import 'package:cinema_noir/features/home/presentation/pages/home_page.dart';
import 'package:cinema_noir/features/home/presentation/pages/movies_page.dart';
import 'package:cinema_noir/features/home/presentation/pages/movie_ticket_page.dart';
import 'package:cinema_noir/features/home/data/models/movie_model.dart';
import 'package:cinema_noir/features/splash/presentation/pages/splash_screen.dart';
import 'package:cinema_noir/features/cinemas/presentation/pages/cinemas_page.dart';
import 'package:cinema_noir/features/home/presentation/pages/my_orders_page.dart';
import 'package:cinema_noir/features/home/presentation/pages/profile_page.dart';

// --- Import Halaman Food Order (PENTING UNTUK m.food) ---
import 'package:cinema_noir/features/food_order/presentation/pages/food_order_page.dart';
// ---------------------------------------------------------

import 'auth_stream_listener.dart';

class AppRouter {
  static final AuthStreamListener _authListener = AuthStreamListener();

  // Variable untuk melacak apakah splash screen sudah tampil
  static bool _splashShown = false;

  static final GoRouter router = GoRouter(
    initialLocation: '/splash', // Mulai dari splash screen
    refreshListenable: _authListener, // Dengarkan perubahan status login
    routes: [
      // --- SPLASH SCREEN ---
      GoRoute(
        path: '/splash',
        builder: (context, state) {
          return SplashScreen(
            onFinished: () {
              // 1. Tandai splash selesai
              _splashShown = true;

              // 2. Cek login manual & navigasi
              if (FirebaseAuth.instance.currentUser != null) {
                context.go('/');
              } else {
                context.go('/login');
              }
            },
          );
        },
      ),

      // --- AUTH ROUTES ---
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),

      // --- HOME ROUTE ---
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
        routes: [
          // Child routes (sub-halaman dari Home)

          // 1. MOVIES (Lihat semua film)
          GoRoute(
            path: 'movies',
            builder: (context, state) => const MoviesPage(),
          ),

          // 2. CINEMAS (Lokasi Bioskop)
          GoRoute(
            path: 'cinemas',
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: const CinemasPage(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      // Animasi Slide dari Kanan
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1.0, 0.0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      );
                    },
              );
            },
          ),

          // 3. MOVIE TICKET (Detail Pemesanan)
          GoRoute(
            path: 'movie-ticket',
            builder: (context, state) {
              // Mengambil data movie yang dikirim via 'extra'
              final movie = state.extra as MovieModel;
              return MovieTicketPage(movie: movie);
            },
          ),

          // 4. MY ORDERS (Riwayat Pesanan)
          GoRoute(
            path: 'my-orders',
            builder: (context, state) => const MyOrdersPage(),
          ),

          // 5. PROFILE (Halaman Profil User)
          GoRoute(
            path: 'profile',
            builder: (context, state) => const ProfilePage(),
          ),

          // 6. FOOD ORDER (BARU - Fitur m.food)
          GoRoute(
            path: 'food',
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: const FoodOrderPage(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      // Animasi Slide dari Bawah (Naik ke atas)
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.0, 1.0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      );
                    },
              );
            },
          ),
        ],
      ),
    ],

    // --- LOGIKA REDIRECT ---
    redirect: (BuildContext context, GoRouterState state) {
      final bool isLoggedIn = (FirebaseAuth.instance.currentUser != null);
      final String location = state.matchedLocation;

      final bool isAuthPage = (location == '/login' || location == '/register');
      final bool isSplashPage = location == '/splash';

      // 1. Selalu tampilkan splash screen dulu jika belum pernah tampil
      if (!_splashShown && !isSplashPage) {
        return '/splash';
      }

      // 2. Jika sedang di splash tapi sudah selesai (otomatis pindah),
      // cek login status
      if (_splashShown && isSplashPage) {
        return isLoggedIn ? '/' : '/login';
      }

      // 3. Jika User BELUM Login
      if (!isLoggedIn && !isSplashPage) {
        // Larang akses ke halaman selain login/register
        if (!isAuthPage) {
          return '/login';
        }
      }

      // 4. Jika User SUDAH Login
      if (isLoggedIn && !isSplashPage) {
        // Larang akses kembali ke halaman login/register
        if (isAuthPage) {
          return '/';
        }
      }

      return null; // Tidak ada redirect
    },
  );
}
