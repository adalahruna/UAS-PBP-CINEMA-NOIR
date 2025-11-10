import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:cinema_noir/features/auth/presentation/pages/login_page.dart';
import 'package:cinema_noir/features/auth/presentation/pages/register_page.dart';
import 'package:cinema_noir/features/home/presentation/pages/home_page.dart';
import 'package:cinema_noir/features/home/presentation/pages/movies_page.dart';
import 'auth_stream_listener.dart'; // Import file helper kita

class AppRouter {
  // Buat instance dari listener kita
  static final AuthStreamListener _authListener = AuthStreamListener();

  static final GoRouter router = GoRouter(
    // Ubah rute awal ke '/'
    // Biarkan redirector yang memutuskan mau dilempar ke login atau tidak
    initialLocation: '/',

    // Beri tahu GoRouter untuk mendengarkan perubahan auth
    refreshListenable: _authListener,

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
        routes: [
          GoRoute(
            path: 'movies',
            builder: (BuildContext context, GoRouterState state) {
              return const MoviesPage();
            },
          ),
        ],
      ),
    ],

    // --- LOGIKA REDIRECT ---
    // Logika ini akan berjalan SETIAP KALI ada navigasi
    // ATAU SETIAP KALI _authListener memberi tahu ada perubahan
    redirect: (BuildContext context, GoRouterState state) {
      // 1. Cek status login saat ini dari Firebase
      final bool isLoggedIn = (FirebaseAuth.instance.currentUser != null);

      // 2. Dapatkan lokasi yang dituju
      final String location = state.matchedLocation;

      // 3. Tentukan apakah dia sedang di halaman auth
      final bool isAuthPage = (location == '/login' || location == '/register');

      // --- ATURAN ---

      // KASUS 1: Pengguna BELUM login
      if (!isLoggedIn) {
        // Jika dia mencoba akses selain halaman auth, lempar ke login
        if (!isAuthPage) {
          return '/login';
        }
      }

      // KASUS 2: Pengguna SUDAH login
      if (isLoggedIn) {
        // Jika dia mencoba akses halaman auth (login/register), lempar ke home
        if (isAuthPage) {
          return '/';
        }
      }

      // 4. Jika tidak ada kasus di atas, biarkan (return null)
      return null;
    },
  );
}
