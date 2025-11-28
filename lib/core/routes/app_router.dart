import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

// --- Import Halaman-Halaman ---
import 'package:cinema_noir/features/auth/presentation/pages/login_page.dart';
import 'package:cinema_noir/features/auth/presentation/pages/register_page.dart';
import 'package:cinema_noir/features/home/presentation/pages/home_page.dart';
import 'package:cinema_noir/features/home/presentation/pages/movies_page.dart';
import 'package:cinema_noir/features/home/presentation/pages/movie_ticket_page.dart';
import 'package:cinema_noir/features/home/data/models/movie_model.dart';
import 'package:cinema_noir/features/seat_selection/presentation/pages/seat_selection_page.dart';
import 'package:cinema_noir/features/splash/presentation/pages/splash_screen.dart';
import 'package:cinema_noir/features/cinemas/presentation/pages/cinemas_page.dart';
import 'package:cinema_noir/features/home/presentation/pages/my_orders_page.dart';
import 'package:cinema_noir/features/home/presentation/pages/profile_page.dart';

// --- Import Fitur m.food ---
import 'package:cinema_noir/features/food_order/presentation/pages/food_order_page.dart';
import 'package:cinema_noir/features/food_order/presentation/pages/food_checkout_page.dart';

// --- Import Fitur Community ---
import 'package:cinema_noir/features/community/presentation/pages/community_page.dart';
import 'package:cinema_noir/features/community/presentation/pages/movie_detail_page.dart';
import 'package:cinema_noir/features/community/presentation/cubit/community_cubit.dart';
import 'package:cinema_noir/features/community/data/repositories/community_repository.dart';
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
                      final movie = state.extra as MovieModel?;
                      final movieId = int.tryParse(state.pathParameters['id'] ?? '');
                      return MovieTicketPage(movie: movie, movieId: movieId);
                    },
                    routes: [
                      GoRoute(
                        path: 'seats',
                        builder: (context, state) {
                          final movie = state.extra as MovieModel?;
                          final movieId = int.tryParse(state.pathParameters['id'] ?? '');
                          final date = state.uri.queryParameters['date'];
                          final time = state.uri.queryParameters['time'];
                          return SeatSelectionPage(
                            movieId: movieId!,
                            date: date!,
                            time: time!,
                            movieTitle: movie?.title,
                            posterUrl: movie?.getFullPosterUrl(),
                          );
                        },
                      ),
                    ],
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

          // 3. COMMUNITY - FITUR BARU
          GoRoute(
            path: 'community',
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: BlocProvider(
                  create: (context) => CommunityCubit(CommunityRepository())..initialize(),
                  child: const CommunityPage(),
                ),
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
            routes: [
              GoRoute(
                path: 'movie/:movieId',
                pageBuilder: (context, state) {
                  final extra = state.extra;
                  return CustomTransitionPage(
                    key: state.pageKey,
                    child: MovieDetailPage(
                      movie: extra is MovieModel ? extra : MovieModel(
                        id: int.parse(state.pathParameters['movieId']!),
                        title: 'Movie',
                        overview: '',
                        voteAverage: 0.0,
                      ),
                    ),
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
            ],
          ),

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
      final currentUser = FirebaseAuth.instance.currentUser;
      final bool isLoggedIn = currentUser != null;
      final bool isVerified = currentUser?.emailVerified ?? false;
      final String location = state.matchedLocation;
      final bool isAuthPage = (location == '/login' || location == '/register');
      final bool isSplashPage = location == '/splash';

      if (!_splashShown && !isSplashPage) {
        return '/splash';
      }

      if (_splashShown && isSplashPage) {
        return (isLoggedIn && isVerified) ? '/' : '/login';
      }

      if (!isLoggedIn && !isSplashPage) {
        if (!isAuthPage) {
          return '/login';
        }
      }

      // Jika user login tapi belum verifikasi, tetap di auth page
      if (isLoggedIn && !isVerified && !isSplashPage) {
        if (!isAuthPage) {
          return '/login';
        }
      }

      // Jika user sudah login dan verified, redirect dari auth page ke home
      if (isLoggedIn && isVerified && !isSplashPage) {
        if (isAuthPage) {
          return '/';
        }
      }

      return null;
    },
  );
}