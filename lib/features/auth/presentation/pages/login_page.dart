import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import BLoC
import 'package:go_router/go_router.dart'; // <-- Akan terpakai
import 'package:sizer/sizer.dart'; // <-- Akan terpakai

// Import Cubit dan State kita
import 'package:cinema_noir/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:cinema_noir/features/auth/presentation/cubit/auth_state.dart';
// Import warna kita
import 'package:cinema_noir/core/constants/app_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    // <-- Akan terpakai
    // 1. Cek apakah form valid (sesuai validator)
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text;
      String password = _passwordController.text;

      // 2. Panggil fungsi login di AuthCubit!
      context.read<AuthCubit>().login(email, password);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color goldColor = Theme.of(context).primaryColor; // <-- Akan terpakai

    // Kita bungkus SEMUA dengan BlocListener
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        // --- REAKSI TERHADAP STATE ---

        if (state is AuthLoading) {
          // Tampilkan dialog loading (tidak bisa ditutup)
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: CircularProgressIndicator(
                color: AppColors.gold, // Pakai warna emas kita
              ),
            ),
          );
        }

        if (state is Unauthenticated) {
          // 1. Tutup dialog loading
          if (ModalRoute.of(context)?.isCurrent != true) {
            Navigator.of(context, rootNavigator: true).pop();
          }

          // 2. Tampilkan pesan error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message ?? 'Login Gagal. Cek email/password.',
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
        }

        if (state is Authenticated) {
          // 1. Tutup dialog loading
          if (ModalRoute.of(context)?.isCurrent != true) {
            Navigator.of(context, rootNavigator: true).pop();
          }

          // TIDAK PERLU NAVIGASI MANUAL DI SINI.
          // GoRouter + refreshListenable akan mendeteksi
          // perubahan state login dan melakukan redirect secara otomatis.
        }
      },
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: 10.w,
            ), // <-- Sizer terpakai
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- JUDUL ---
                  Text(
                    'Cinema Noir',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24.sp, // <-- Sizer terpakai
                      fontWeight: FontWeight.bold,
                      color: goldColor, // <-- goldColor terpakai
                    ),
                  ),
                  SizedBox(height: 1.h), // <-- Sizer terpakai
                  Text(
                    'The show is about to begin.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.sp, // <-- Sizer terpakai
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 5.h), // <-- Sizer terpakai
                  // --- EMAIL FIELD ---
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    // VALIDATOR
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email tidak boleh kosong';
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Email tidak valid';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 2.h), // <-- Sizer terpakai
                  // --- PASSWORD FIELD ---
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    // VALIDATOR
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password tidak boleh kosong';
                      }
                      if (value.length < 6) {
                        return 'Password minimal 6 karakter';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 4.h), // <-- Sizer terpakai
                  // --- LOGIN BUTTON ---
                  ElevatedButton(
                    onPressed: _login, // <-- _login terpakai
                    child: Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ), // <-- Sizer terpakai
                    ),
                  ),
                  SizedBox(height: 3.h), // <-- Sizer terpakai
                  // --- LINK KE REGISTER ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: TextStyle(fontSize: 11.sp), // <-- Sizer terpakai
                      ),
                      TextButton(
                        onPressed: () {
                          context.push('/register'); // <-- GoRouter terpakai
                        },
                        child: Text(
                          'Register Now',
                          style: TextStyle(
                            fontSize: 11.sp, // <-- Sizer terpakai
                            color: goldColor, // <-- goldColor terpakai
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
