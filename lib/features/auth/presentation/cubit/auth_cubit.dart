import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Instance Firestore

  AuthCubit() : super(AuthInitial());

  // --- FUNGSI LOGIN --- (Biarkan)
  Future<void> login(String email, String password) async {
    // ... (kode login Anda yang sudah ada, biarkan saja)
  }

  // --- TAMBAHKAN FUNGSI REGISTER BARU ---
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      emit(AuthLoading());

      // 1. Buat user di Firebase Auth
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        // 2. Simpan data tambahan (nama) ke Firestore
        await _saveUserToFirestore(
          user: userCredential.user!,
          fullName: fullName,
        );

        // 3. Update state
        emit(Authenticated(userCredential.user!));
      } else {
        emit(const Unauthenticated(message: 'Gagal membuat akun.'));
      }
    } on FirebaseAuthException catch (e) {
      // Tangani error spesifik (misal: email sudah dipakai)
      emit(Unauthenticated(message: e.message ?? 'Terjadi error'));
    } catch (e) {
      emit(Unauthenticated(message: e.toString()));
    }
  }

  // --- TAMBAHKAN FUNGSI HELPER UNTUK FIRESTORE ---
  Future<void> _saveUserToFirestore({
    required User user,
    required String fullName,
  }) async {
    try {
      // Buat dokumen baru di koleksi 'users' dengan ID unik dari user
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'fullName': fullName,
        'createdAt': FieldValue.serverTimestamp(), // Simpan waktu pendaftaran
      });
    } catch (e) {
      // Jika gagal simpan ke firestore, kita hanya print error-nya
      // tapi login tetap dianggap berhasil.
      print('Gagal menyimpan user ke Firestore: $e');
    }
  }

  // --- FUNGSI LOGOUT --- (Biarkan)
  Future<void> logout() async {
    await _auth.signOut();
    emit(const Unauthenticated());
  }
}
