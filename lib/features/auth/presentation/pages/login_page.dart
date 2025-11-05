import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controller untuk mengambil data dari text field
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Kunci untuk validasi Form
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // Selalu dispose controller Anda
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    // Nanti, kita akan panggil BLoC/Cubit dari sini
    // if (_formKey.currentState!.validate()) {
    //   String email = _emailController.text;
    //   String password = _passwordController.text;
    //   print('Mencoba login dengan Email: $email, Password: $password');
    //   // context.read<AuthCubit>().login(email, password);
    // }
    print('Tombol login diklik!');
  }

  @override
  Widget build(BuildContext context) {
    // Ambil warna emas dari tema
    final Color goldColor = Theme.of(context).primaryColor;

    return Scaffold(
      // Kita pakai SingleChildScrollView agar tidak error
      // jika keyboard muncul di layar kecil
      body: Center(
        child: SingleChildScrollView(
          // Padding responsif menggunakan Sizer
          padding: EdgeInsets.symmetric(horizontal: 10.w),
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
                    fontSize: 24.sp, // Font responsif
                    fontWeight: FontWeight.bold,
                    color: goldColor, // Warna emas
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'The show is about to begin.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),
                SizedBox(height: 5.h), // Jarak responsif
                // --- EMAIL FIELD ---
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  // Nanti kita tambahkan validator
                ),
                SizedBox(height: 2.h),

                // --- PASSWORD FIELD ---
                TextFormField(
                  controller: _passwordController,
                  obscureText: true, // Menyembunyikan password
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                    // Nanti kita tambahkan ikon untuk show/hide password
                  ),
                  // Nanti kita tambahkan validator
                ),
                SizedBox(height: 4.h),

                // --- LOGIN BUTTON ---
                // Tombol ini otomatis mengambil style dari tema
                ElevatedButton(
                  onPressed: _login, // Panggil fungsi _login
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 3.h),

                // --- LINK KE REGISTER ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: TextStyle(fontSize: 11.sp),
                    ),
                    TextButton(
                      onPressed: () {
                        // Pergi ke halaman register menggunakan GoRouter
                        context.push('/register');
                      },
                      child: Text(
                        'Register Now',
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
    );
  }
}
