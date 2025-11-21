
import 'dart:typed_data'; // PENTING: Untuk tipe data Uint8List (Bytes)
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User, AuthState;

import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  AuthCubit() : super(AuthInitial());

  // --- FUNGSI LOGIN ---
  Future<void> login(String email, String password) async {
    try {
      emit(AuthLoading());
      
      // Login ke Firebase
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );

      final user = userCredential.user;

      if (user != null) {
        // Cek apakah email sudah diverifikasi
        if (!user.emailVerified) {
           emit(const Unauthenticated(
             message: 'Email belum diverifikasi. Silakan cek inbox email Anda.'
           ));
           await _auth.signOut(); // Logout paksa jika belum verifikasi
        } else {
           emit(Authenticated(user));
        }
      }
    } on FirebaseAuthException catch (e) {
      emit(Unauthenticated(message: e.message ?? 'Login gagal'));
    } catch (e) {
      emit(Unauthenticated(message: e.toString()));
    }
  }

  // --- FUNGSI REGISTER ---
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      emit(AuthLoading());
      
      // 1. Buat User di Firebase Auth
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      
      User? user = userCredential.user;

      if (user != null) {
        // 2. Update Display Name di Auth User
        await user.updateDisplayName(fullName);

        // 3. Simpan data awal user ke Firestore
        await _saveUserToFirestore(user: user, fullName: fullName);

        // 4. Kirim Email Verifikasi
        await user.sendEmailVerification();

        // 5. Logout paksa (user harus login ulang setelah verifikasi)
        await _auth.signOut();
        
        emit(const Unauthenticated(
          message: 'Registrasi Berhasil! Silakan cek email untuk verifikasi sebelum login.',
        ));
      }
    } on FirebaseAuthException catch (e) {
      emit(Unauthenticated(message: e.message ?? 'Registrasi gagal'));
    } catch (e) {
      emit(Unauthenticated(message: e.toString()));
    }
  }

  // --- FUNGSI UPDATE PROFILE (UNIVERSAL: MOBILE & WEB) ---
  Future<void> updateProfile({
    required String uid,
    required String fullName,
    required String province,
    required String city,
    Uint8List? imageBytes, // Menggunakan Bytes, bukan File
    String? imageExtension, // Contoh: 'jpg', 'png'
  }) async {
    try {
      emit(AuthLoading());
      User? user = _auth.currentUser;

      if (user != null) {
        String? photoUrl = user.photoURL;

        // 1. Jika ada foto baru, upload ke SUPABASE STORAGE
        if (imageBytes != null) {
          try {
            // Tentukan nama file unik
            final ext = imageExtension ?? 'jpg';
            final fileName = '${user.uid}_${DateTime.now().millisecondsSinceEpoch}.$ext';
            
            // Gunakan uploadBinary (Aman untuk Web & Mobile)
            // Pastikan bucket 'user-profiles' sudah dibuat di Dashboard Supabase & Public
            await _supabase.storage.from('user_profiles').uploadBinary(
              fileName, 
              imageBytes,
              fileOptions: const FileOptions(upsert: true),
            );

            // Dapatkan Public URL dari Supabase
            photoUrl = _supabase.storage.from('user_profiles').getPublicUrl(fileName);
            
            // Update foto di Firebase Auth User object
            await user.updatePhotoURL(photoUrl);
          } catch (e) {
            print("Gagal upload ke Supabase: $e");
            throw Exception("Gagal upload foto profil.");
          }
        }

        // 2. Update Nama di Firebase Auth
        if (user.displayName != fullName) {
          await user.updateDisplayName(fullName);
        }

        // 3. Update Data Lengkap di Firestore (Merge agar data lain aman)
        await _firestore.collection('users').doc(uid).set({
          'fullName': fullName,
          'province': province,
          'city': city,
          'photoUrl': photoUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Refresh data user lokal agar UI mendapatkan update terbaru
        await user.reload(); 
        emit(Authenticated(_auth.currentUser!));
      }
    } catch (e) {
      // Kembalikan ke state Authenticated agar user tidak stuck di loading
      if (_auth.currentUser != null) {
        emit(Authenticated(_auth.currentUser!));
      } else {
        emit(Unauthenticated(message: e.toString()));
      }
      // Rethrow error agar UI (ProfilePage) bisa menangkap pesan errornya
      rethrow;
    }
  }

  // --- FUNGSI HELPER PRIVATE ---
  Future<void> _saveUserToFirestore({
    required User user,
    required String fullName,
  }) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'fullName': fullName,
        'province': '', // Default kosong
        'city': '',     // Default kosong
        'photoUrl': '', // Default kosong
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Gagal simpan ke Firestore: $e');
    }
  }

  // --- FUNGSI LOGOUT ---
  Future<void> logout() async {
    await _auth.signOut();
    emit(const Unauthenticated());
  }
}