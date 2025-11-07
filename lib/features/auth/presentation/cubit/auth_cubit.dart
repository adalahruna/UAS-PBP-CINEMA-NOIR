// File: lib/features/auth/presentation/cubit/auth_cubit.dart

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:google_sign_in/google_sign_in.dart'; // <-- DIHAPUS
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final GoogleSignIn _googleSignIn = GoogleSignIn(); // <-- DIHAPUS

  AuthCubit() : super(AuthInitial());

  // --- FUNGSI LOGIN ---
  Future<void> login(String email, String password) async {
    try {
      emit(AuthLoading());
      
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );

      // Tetap emit Authenticated agar dialog loading tertutup
      if (userCredential.user != null) {
        emit(Authenticated(userCredential.user!));
      }

    } on FirebaseAuthException catch (e) {
      emit(Unauthenticated(message: e.message ?? 'Terjadi error'));
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
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        await _saveUserToFirestore(
          user: userCredential.user!,
          fullName: fullName,
        );
        
        // Tetap emit Authenticated agar dialog loading tertutup
        emit(Authenticated(userCredential.user!));
      } else {
        emit(const Unauthenticated(message: 'Gagal membuat akun.'));
      }
    } on FirebaseAuthException catch (e) {
      emit(Unauthenticated(message: e.message ?? 'Terjadi error'));
    } catch (e) {
      emit(Unauthenticated(message: e.toString()));
    }
  }

  // --- FUNGSI LOGIN DENGAN GOOGLE DIHAPUS ---
  // Future<void> loginWithGoogle() async { ... }

  // --- FUNGSI HELPER UNTUK FIRESTORE ---
  Future<void> _saveUserToFirestore({
    required User user,
    required String fullName,
  }) async {
    try {
      final doc = _firestore.collection('users').doc(user.uid);
      final snapshot = await doc.get();

      if (!snapshot.exists) {
        await doc.set({
          'uid': user.uid,
          'email': user.email,
          'fullName': fullName,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Gagal menyimpan user ke Firestore: $e');
    }
  }

  // --- FUNGSI LOGOUT ---
  Future<void> logout() async {
    // await _googleSignIn.signOut(); // <-- DIHAPUS
    await _auth.signOut();
    emit(const Unauthenticated());
  }
}