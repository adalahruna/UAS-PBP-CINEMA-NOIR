import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cinema_noir/features/auth/presentation/pages/login_page.dart';
import 'package:cinema_noir/features/auth/presentation/pages/register_page.dart';
import 'package:cinema_noir/features/home/presentation/pages/home_page.dart';
import 'package:cinema_noir/features/home/presentation/pages/movies_page.dart';
import 'package:cinema_noir/features/home/presentation/pages/movie_ticket_page.dart';
import 'package:cinema_noir/features/home/data/models/movie_model.dart';
import 'package:cinema_noir/features/splash/presentation/pages/splash_screen.dart';
import 'auth_stream_listener.dart';

class AppRouter {
  static final AuthStreamListener _authListener = AuthStreamListener();
  static bool _splashShown = false;

  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: _authListener,
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: SplashScreen(
              onFinished: () {
                _splashShown = true;
                final isLoggedIn = FirebaseAuth.instance.currentUser != null;
                context.go(isLoggedIn ? '/' : '/login');
              },
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const LoginPage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const RegisterPage(),
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
      GoRoute(
        path: '/',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const HomePage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          );
        },
        routes: [
          GoRoute(
            path: 'movies',
            builder: (BuildContext context, GoRouterState state) {
              final category = state.uri.queryParameters['category'];
              final showNowPlaying = category != 'upcoming';
              return MoviesPage(showNowPlaying: showNowPlaying);
            },
            routes: [
              GoRoute(
                path: ':id/ticket',
                builder: (BuildContext context, GoRouterState state) {
                  final extra = state.extra;
                  return MovieTicketPage(
                    movie: extra is MovieModel ? extra : null,
                  );
                },
              ),
              GoRoute(
                path: 'ticket',
                builder: (BuildContext context, GoRouterState state) {
                  final extra = state.extra;
                  return MovieTicketPage(
                    movie: extra is MovieModel ? extra : null,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final bool isLoggedIn = (FirebaseAuth.instance.currentUser != null);
      final String location = state.matchedLocation;
      final bool isAuthPage = (location == '/login' || location == '/register');
      final bool isSplashPage = location == '/splash';

      // Always show splash first
      if (!_splashShown && !isSplashPage) {
        return '/splash';
      }

      // Skip splash if already shown
      if (_splashShown && isSplashPage) {
        return isLoggedIn ? '/' : '/login';
      }

      // User not logged in
      if (!isLoggedIn && !isSplashPage) {
        if (!isAuthPage) {
          return '/login';
        }
      }

      // User logged in
      if (isLoggedIn && !isSplashPage) {
        if (isAuthPage) {
          return '/';
        }
      }

      return null;
    },
  );
}