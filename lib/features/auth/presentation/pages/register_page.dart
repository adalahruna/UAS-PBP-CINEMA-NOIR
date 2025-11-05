import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

// Import Cubit dan State
import 'package:cinema_noir/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:cinema_noir/features/auth/presentation/cubit/auth_state.dart';
import 'package:cinema_noir/core/constants/app_colors.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController(); // Field baru
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      // Panggil fungsi register dari Cubit
      context.read<AuthCubit>().register(
        email: _emailController.text,
        password: _passwordController.text,
        fullName: _nameController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color goldColor = Theme.of(context).primaryColor;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        // Logic listener ini SAMA PERSIS dengan LoginPage
        if (state is AuthLoading) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            ),
          );
        }

        if (state is Unauthenticated) {
          if (ModalRoute.of(context)?.isCurrent != true) {
            Navigator.of(context, rootNavigator: true).pop();
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message ?? 'Registrasi Gagal.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }

        if (state is Authenticated) {
          // GoRouter akan otomatis redirect ke Home,
          // kita hanya perlu tutup dialog loading.
          if (ModalRoute.of(context)?.isCurrent != true) {
            Navigator.of(context, rootNavigator: true).pop();
          }
        }
      },
      child: Scaffold(
        // Kita tambahkan AppBar agar bisa kembali ke Login
        appBar: AppBar(
          backgroundColor: Colors.transparent, // Transparan
          elevation: 0,
          iconTheme: IconThemeData(color: goldColor), // <-- INI YANG DIPERBAIKI
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- JUDUL ---
                  Text(
                    'Create Account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: goldColor,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Join the Cinema Noir family.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                  ),
                  SizedBox(height: 5.h),

                  // --- FULL NAME FIELD ---
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 2.h),

                  // --- EMAIL FIELD ---
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
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
                  SizedBox(height: 2.h),

                  // --- PASSWORD FIELD ---
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
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
                  SizedBox(height: 4.h),

                  // --- REGISTER BUTTON ---
                  ElevatedButton(
                    onPressed: _register,
                    child: Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 3.h),

                  // --- LINK KEMBALI KE LOGIN ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: TextStyle(fontSize: 11.sp),
                      ),
                      TextButton(
                        onPressed: () {
                          // Kembali ke halaman login
                          context.pop();
                        },
                        child: Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: goldColor,
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
