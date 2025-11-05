import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_state.dart'; // Import state yang kita buat tadi

class AuthCubit extends Cubit<AuthState> {
  // Ambil instance dari Firebase Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthCubit() : super(AuthInitial()); // State awalnya adalah Initial

  // --- FUNGSI LOGIN ---
  Future<void> login(String email, String password) async {
    try {
      // 1. Beri tahu UI bahwa kita sedang loading
      emit(AuthLoading());

      // 2. Coba login ke Firebase
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 3. Jika berhasil, beri tahu UI dan kirim data User-nya
      if (userCredential.user != null) {
        emit(Authenticated(userCredential.user!));
      } else {
        emit(
          const Unauthenticated(message: 'Gagal login, user tidak ditemukan.'),
        );
      }
    } on FirebaseAuthException catch (e) {
      // 4. Jika Firebase memberi error (misal: password salah)
      emit(Unauthenticated(message: e.message ?? 'Terjadi error'));
    } catch (e) {
      // 5. Jika ada error lain
      emit(Unauthenticated(message: e.toString()));
    }
  }

  // --- FUNGSI LOGOUT ---
  Future<void> logout() async {
    await _auth.signOut();
    emit(const Unauthenticated()); // Kembalikan ke state Unauthenticated
  }

  // Nanti kita tambahkan fungsi register di sini
}
