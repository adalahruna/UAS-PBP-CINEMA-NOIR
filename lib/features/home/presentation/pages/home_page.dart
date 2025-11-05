import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart'; // <-- Pastikan Sizer di-import

// Import service, cubit, dan state kita
import 'package:cinema_noir/core/api/tmdb_service.dart';
import 'package:cinema_noir/features/home/presentation/cubit/movie_cubit.dart';
import 'package:cinema_noir/features/home/presentation/cubit/movie_state.dart';

// Import AuthCubit untuk tombol Logout
import 'package:cinema_noir/features/auth/presentation/cubit/auth_cubit.dart';

// Import widget carousel yang baru kita buat
import 'package:cinema_noir/features/home/presentation/widgets/poster_carousel.dart';
// Import warna kita
import 'package:cinema_noir/core/constants/app_colors.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Sediakan MovieCubit HANYA untuk halaman ini
    return BlocProvider(
      create: (context) =>
          MovieCubit(TmdbService()) // Buat instance Cubit & Service
            ..fetchHomeMovies(), // Langsung panggil fungsi fetch data!

      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cinema Noir'),
          // Tambahkan Tombol Logout
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                // Panggil fungsi logout dari AuthCubit
                context.read<AuthCubit>().logout();
              },
            ),
          ],
        ),

        // Body akan menampilkan data berdasarkan state
        body: BlocBuilder<MovieCubit, MovieState>(
          builder: (context, state) {
            // --- KASUS 1: LOADING ---
            if (state is MovieLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.gold, // Ganti ke warna emas
                ),
              );
            }

            // --- KASUS 2: SUKSES (DATA TAMPIL) ---
            if (state is MovieLoaded) {
              // Tampilkan konten dalam SingleChildScrollView
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- 1. POSTER CAROUSEL ---
                    // Tampilkan carousel dengan data 'nowPlayingMovies'
                    PosterCarousel(movies: state.nowPlayingMovies),

                    SizedBox(height: 3.h),

                    // --- 2. JUDUL UNTUK "UPCOMING" ---
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                      child: Text(
                        'Upcoming Movies',
                        style: TextStyle(
                          color: AppColors.gold,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    SizedBox(height: 2.h),

                    // NANTI: Kita akan tambahkan daftar 'upcomingMovies' di sini
                    // Untuk sekarang, kita tampilkan teks saja
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                      child: Text(
                        'Dapat ${state.upcomingMovies.length} film upcoming. (Akan dibuat list-nya di tahap selanjutnya)',
                      ),
                    ),
                    SizedBox(height: 10.h), // Spasi di bawah
                  ],
                ),
              );
            }

            // --- KASUS 3: ERROR ---
            if (state is MovieError) {
              return Center(
                child: Text(
                  'Gagal mengambil data: ${state.message}',
                  style: const TextStyle(color: Colors.redAccent),
                ),
              );
            }

            // Default (seharusnya tidak akan sampai sini)
            return const Center(child: Text('State tidak dikenal.'));
          },
        ),
      ),
    );
  }
}
