
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cinema_noir/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:cinema_noir/features/auth/presentation/cubit/auth_state.dart';
import 'package:cinema_noir/core/constants/app_colors.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPassController = TextEditingController();
  
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _showPasswordHelperText = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  // Validasi Regex: Min 8 char, minimal 1 angka
  bool _isPasswordValid(String pass) {
    final RegExp regex = RegExp(r'^(?=.*[0-9]).{8,}$');
    return regex.hasMatch(pass);
  }

  void _onRegister() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _nameController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(), // Tombol kembali ke Login
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
            );
          } else if (state is Unauthenticated) {
            // Tutup dialog loading jika ada
            if (Navigator.canPop(context)) Navigator.pop(context);
            
            final isSuccess = state.message?.toLowerCase().contains('berhasil') ?? false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message ?? 'Error'),
                backgroundColor: isSuccess ? Colors.green : Colors.red,
              ),
            );

            // Jika sukses register, arahkan kembali ke login
            if (isSuccess) context.go('/login');
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Create Account', 
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primaryColor)
                    ),
                    const SizedBox(height: 40),

                    // Nama Lengkap
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Nama Lengkap', prefixIcon: Icon(Icons.person)),
                      validator: (v) => v!.isEmpty ? 'Nama wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                      validator: (v) => (!v!.contains('@') || !v.contains('.')) ? 'Format email salah' : null,
                    ),
                    const SizedBox(height: 16),

                    // Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePass,
                      onChanged: (value) {
                        final bool shouldShow = value.isNotEmpty;
                        if (shouldShow != _showPasswordHelperText) {
                          setState(() {
                            _showPasswordHelperText = shouldShow;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePass ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _obscurePass = !_obscurePass),
                        ),
                        helperText: _showPasswordHelperText
                            ? 'Min. 8 karakter & mengandung angka'
                            : null,
                        helperMaxLines: 2,
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Password wajib diisi';
                        if (!_isPasswordValid(v)) return 'Harus min. 8 huruf & ada angka';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Konfirmasi Password
                    TextFormField(
                      controller: _confirmPassController,
                      obscureText: _obscureConfirm,
                      decoration: InputDecoration(
                        labelText: 'Ulangi Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirm ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        ),
                      ),
                      validator: (v) {
                        if (v != _passwordController.text) return 'Password tidak sama';
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    ElevatedButton(
                      onPressed: _onRegister,
                      style: ElevatedButton.styleFrom(minimumSize: const Size(0, 50)),
                      child: const Text('Register'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}