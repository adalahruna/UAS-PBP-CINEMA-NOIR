import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import BLoC
import 'package:sizer/sizer.dart';
import 'package:cinema_noir/core/theme/app_theme.dart';
import 'package:cinema_noir/core/routes/app_router.dart';
// Import Cubit yang baru kita buat
import 'package:cinema_noir/features/auth/presentation/cubit/auth_cubit.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Bungkus Sizer dengan BlocProvider
    return BlocProvider(
      create: (context) => AuthCubit(), // Buat instance AuthCubit
      child: Sizer(
        // Sizer sekarang ada di dalam Provider
        builder: (context, orientation, deviceType) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Cinema Noir',
            theme: AppTheme.darkTheme,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
