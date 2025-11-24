// Test file untuk Community routing
// Simpan ini sebagai test_routing.dart di root project

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void testCommunityRouting(BuildContext context) {
  // Test navigasi ke Community
  try {
    context.go('/community');
    print('✅ Community routing berhasil!');
  } catch (e) {
    print('❌ Error Community routing: $e');
  }
}

// Cara test manual:
// 1. Hot restart app: flutter run (tekan R)
// 2. Klik button "Community" di HomePage
// 3. Harus navigate ke Community Page
// 4. Jika error, check console untuk pesan error
