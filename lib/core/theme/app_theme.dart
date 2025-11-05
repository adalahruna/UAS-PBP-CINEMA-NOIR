import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cinema_noir/core/constants/app_colors.dart'; // Import file warna Anda

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      // Tentukan skema warna utama
      colorScheme: const ColorScheme.dark(
        primary: AppColors.gold,
        secondary: AppColors.gold,
        background: AppColors.darkBackground,
        surface: AppColors.darkBackground,
        onPrimary: AppColors.darkBackground, // Warna teks di atas Emas
        onSecondary: AppColors.darkBackground,
        onBackground: AppColors.textWhite, // Warna teks di atas Hitam
        onSurface: AppColors.textWhite,
        error: Colors.redAccent,
        onError: Colors.white,
      ),

      // Warna utama
      primaryColor: AppColors.gold,
      scaffoldBackgroundColor: AppColors.darkBackground,

      // Tema Teks (Pilih font elegan, misal: Montserrat)
      textTheme: GoogleFonts.montserratTextTheme(
        ThemeData.dark().textTheme.apply(
          bodyColor: AppColors.textWhite,
          displayColor: AppColors.textWhite,
        ),
      ),

      // Tema AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: AppColors.gold,
        ), // Ikon (misal: back) jadi emas
        titleTextStyle: TextStyle(
          color: AppColors.gold,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Tema Tombol
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.darkBackground, // Teks tombol
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),

      // Tema Input Field (TextFormField)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkGrey,
        hintStyle: const TextStyle(color: AppColors.textGrey),
        labelStyle: const TextStyle(color: AppColors.gold),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gold, width: 2),
        ),
      ),
    );
  }
}
