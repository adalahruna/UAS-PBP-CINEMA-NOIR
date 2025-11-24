# 🚨 COMMUNITY ROUTING DEBUG GUIDE

## ❌ MASALAH: Button Community tidak navigasi ke Community Page

### 🔍 LANGKAH DEBUGGING:

## 1. ✅ VERIFIKASI FILE SUDAH BENAR:

**A. Check app_router.dart:**
```
Path: D:\FilmPbp\UAS-PBP-CINEMA-NOIR\lib\core\routes\app_router.dart
Must contain:
- import community pages ✅
- GoRoute path: 'community' ✅  
- child: const CommunityPage() ✅
```

**B. Check home_page.dart:**
```
Path: D:\FilmPbp\UAS-PBP-CINEMA-NOIR\lib\features\home\presentation\pages\home_page.dart  
Must contain:
- _CategoryIcon for Community
- onTap: () => context.go('/community')  ← INI YANG PENTING!
- TIDAK boleh ada 'const' keyword jika ada callback
```

## 2. 🔧 MANUAL FIX HOME_PAGE.dart:

Buka file: `D:\FilmPbp\UAS-PBP-CINEMA-NOIR\lib\features\home\presentation\pages\home_page.dart`

Cari section ini (sekitar line 350):
```dart
_CategoryIcon(
  icon: Icons.people_outline,
  label: 'Community',
  onTap: null,  ← GANTI INI
),
```

Ganti dengan:
```dart
_CategoryIcon(
  icon: Icons.people_outline,
  label: 'Community',
  onTap: () => context.go('/community'),  ← JADI INI
),
```

**PENTING:** Jangan ada keyword `const` di depan _CategoryIcon jika ada callback!

## 3. 🚀 TESTING STEPS:

1. **Save file** setelah edit manual
2. **Hot restart** app: `flutter run` (tekan R)  
3. **Test navigation:** HomePage → klik "Community"
4. **Expected:** Navigate ke Community Page dengan grid movies
5. **If error:** Check console untuk error message

## 4. 🐛 COMMON ERRORS & SOLUTIONS:

**Error A:** "const constructor cannot have callback"
→ Solution: Remove `const` keyword dari _CategoryIcon Community

**Error B:** "CommunityPage not found" 
→ Solution: Check import di app_router.dart

**Error C:** "context.go not found"
→ Solution: Add `import 'package:go_router/go_router.dart';` di home_page.dart

**Error D:** "Route '/community' not found"
→ Solution: Check GoRoute path di app_router.dart

## 5. 📱 MANUAL VERIFICATION:

Buka file-file ini dan pastikan isinya benar:

**A. app_router.dart** harus punya:
```dart
GoRoute(
  path: 'community',
  pageBuilder: (context, state) {
    return CustomTransitionPage(
      child: const CommunityPage(),
      // ... transitions
    );
  },
)
```

**B. home_page.dart** harus punya:
```dart
_CategoryIcon(
  icon: Icons.people_outline,
  label: 'Community', 
  onTap: () => context.go('/community'),
),
```

## 🎯 QUICK FIX CHECKLIST:

- [ ] ✅ Community files ada di `lib/features/community/`
- [ ] ✅ app_router.dart import CommunityPage
- [ ] ✅ app_router.dart ada GoRoute path: 'community'  
- [ ] ✅ home_page.dart import go_router
- [ ] ✅ home_page.dart Community button punya onTap callback
- [ ] ✅ Tidak ada `const` di Community _CategoryIcon
- [ ] ✅ Hot restart setelah perubahan
- [ ] ✅ Test klik button Community

Jika masih error setelah semua step, copy error message dan kita debug lebih lanjut! 🔧

---
**🎬 Cinema Noir Community Feature Debug Guide**
