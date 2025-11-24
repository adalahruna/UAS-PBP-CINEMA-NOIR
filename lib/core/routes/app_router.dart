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

// --- Import Fitur m.food ---
import 'package:cinema_noir/features/food_order/presentation/pages/food_order_page.dart';
import 'package:cinema_noir/features/food_order/presentation/pages/food_checkout_page.dart';
// ---------------------------

import 'auth_stream_listener.dart';

class AppRouter {
  static final AuthStreamListener _authListener = AuthStreamListener();
  static bool _splashShown = false;

  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: _authListener,
    routes: [
      // --- SPLASH SCREEN ---
      GoRoute(
        path: '/splash',
        builder: (context, state) {
          return SplashScreen(
            onFinished: () {
              _splashShown = true;
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
      GoRoute(path: '/register', builder: (context, state) => const RegisterPage()),

      // --- HOME ROUTE ---
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
        routes: [
          // 1. MOVIES & TICKET ROUTES (Diperbaiki)
          GoRoute(
            path: 'movies',
            builder: (context, state) => const MoviesPage(),
            // Tambahkan routes bertingkat disini
            routes: [
              // Menangani ID film: /movies/123
              GoRoute(
                path: ':id', 
                builder: (context, state) {
                  // Jika Anda punya MovieDetailPage, return di sini.
                  // Jika tidak, kita bisa redirect atau tampilkan MoviesPage lagi sementara.
                  return const MoviesPage(); 
                },
                routes: [
                  // Menangani Tiket: /movies/123/ticket
                  GoRoute(
                    path: 'ticket',
                    builder: (context, state) {
                      // Mengambil data movie dari 'extra'
                      // Pastikan saat navigasi Anda mengirim object movie: 
                      // context.go('/movies/${movie.id}/ticket', extra: movie);
                      final movie = state.extra as MovieModel;
                      return MovieTicketPage(movie: movie);
                    },
                  ),
                ],
              ),
            ],
          ),

          // 2. CINEMAS
          GoRoute(
            path: 'cinemas',
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: const CinemasPage(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
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

          // 3. MOVIE TICKET (OLD) - Hapus atau biarkan jika masih dipakai via path lama
          // Sebaiknya dihapus agar konsisten dengan struktur baru '/movies/:id/ticket'
          
          // 4. MY ORDERS
          GoRoute(
            path: 'my-orders',
            builder: (context, state) => const MyOrdersPage(),
          ),

          // 5. PROFILE
          GoRoute(
            path: 'profile',
            builder: (context, state) => const ProfilePage(),
          ),

          // 6. FOOD ORDER
          GoRoute(
            path: 'food',
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: const FoodOrderPage(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
            routes: [
              GoRoute(
                path: 'food-checkout',
                builder: (context, state) {
                  final cartItems = state.extra as List<Map<String, dynamic>>;
                  return FoodCheckoutPage(cartItems: cartItems);
                },
              ),
            ],
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

      if (!_splashShown && !isSplashPage) {
        return '/splash';
      }

      if (_splashShown && isSplashPage) {
        return isLoggedIn ? '/' : '/login';
      }

      if (!isLoggedIn && !isSplashPage) {
        if (!isAuthPage) {
          return '/login';
        }
      }

      if (isLoggedIn && !isSplashPage) {
        if (isAuthPage) {
          return '/';
        }
      }

      return null;
    },
  );
}