# 🎬 CINEMA NOIR - COMMUNITY FEATURE 
# Instruksi Lengkap untuk Menjalankan Fitur Community

## ✅ SEMUA FILE SUDAH BERHASIL DISALIN KE:
D:\FilmPbp\UAS-PBP-CINEMA-NOIR\

## 📁 STRUKTUR FILE YANG DIBUAT:

```
lib/features/community/
├── data/
│   ├── models/
│   │   ├── movie_detail_model.dart      ✅ DONE
│   │   └── user_review_model.dart       ✅ DONE
│   ├── datasources/
│   │   ├── community_remote_datasource.dart  ✅ DONE
│   │   └── review_local_datasource.dart      ✅ DONE
│   └── repositories/
│       └── community_repository.dart    ✅ DONE
└── presentation/
    ├── cubit/
    │   ├── community_cubit.dart         ✅ DONE
    │   ├── community_state.dart         ✅ DONE
    │   └── movie_detail_cubit.dart      ✅ DONE
    ├── pages/
    │   ├── community_page.dart          ✅ DONE
    │   └── movie_detail_page.dart       ✅ DONE
    └── widgets/
        └── rating_dialog.dart           ✅ DONE
```

## 🔧 FILE YANG SUDAH DIUPDATE:

1. ✅ `lib/core/routes/app_router.dart` - Menambahkan routing Community
2. ✅ `lib/features/home/presentation/pages/home_page.dart` - Mengaktifkan button Community
3. ✅ `pubspec.yaml` - Dependency url_launcher sudah ada

## 🚀 CARA MENJALANKAN:

### 1. Install Dependencies
```bash
cd "D:\FilmPbp\UAS-PBP-CINEMA-NOIR"
flutter pub get
```

### 2. Hot Restart App
```bash
flutter run
# Atau jika sudah running, tekan 'R' untuk hot restart
```

### 3. Testing Flow:
1. **Buka App** → HomePage
2. **Klik "Community"** → Navigate ke Community Page
3. **Lihat Grid Movies** → Search, Load More, Pull Refresh
4. **Klik Movie Poster** → Buka Movie Detail Page
5. **Test Trailer** → Klik Play button (buka YouTube)
6. **Test Rating** → Klik "Rate & Review" button
7. **Submit Review** → Isi rating & review text

## 🎯 FITUR YANG TERSEDIA:

### Community Page (/community):
- ✅ Grid layout movie posters (2 kolom)
- ✅ Search movies by title
- ✅ Pagination dengan "Load More Movies"
- ✅ Pull-to-refresh
- ✅ Shimmer loading effects
- ✅ Error handling + retry

### Movie Detail Page (/community/movie/:id):
- ✅ Backdrop image + trailer button
- ✅ Movie info (poster, title, rating, date, runtime, genres)
- ✅ YouTube trailer integration
- ✅ Cast horizontal scroll
- ✅ Reviews section (TMDB + User reviews)
- ✅ Rating & Review system
- ✅ Community statistics

### Rating & Review System:
- ✅ 5-star rating dengan visual feedback
- ✅ Text review (max 500 chars)
- ✅ Firebase Firestore integration
- ✅ Edit/Delete own reviews
- ✅ Community rating statistics

## 🔥 DEPENDENCIES YANG DIBUTUHKAN:
Semua dependency sudah tersedia di pubspec.yaml:
- flutter_bloc (state management)
- dio (HTTP requests)
- go_router (navigation)
- cached_network_image (image caching)
- firebase_auth & cloud_firestore (user reviews)
- url_launcher (YouTube trailer)
- sizer (responsive design)
- shimmer (loading effects)

## 📱 TESTING CHECKLIST:

### ✅ Navigation:
- [ ] HomePage → Community button works
- [ ] Community → Movie Detail works
- [ ] Back navigation works

### ✅ Community Page:
- [ ] Movies grid loads dengan shimmer
- [ ] Search functionality works
- [ ] Load More button works
- [ ] Pull-to-refresh works
- [ ] Error handling works (turn off internet)

### ✅ Movie Detail:
- [ ] Movie info displays correctly
- [ ] Trailer button opens YouTube
- [ ] Cast list scrolls horizontally
- [ ] Reviews section shows TMDB + user reviews

### ✅ Rating System:
- [ ] Rating dialog opens
- [ ] Star rating works (1-5 stars)
- [ ] Review text input works
- [ ] Submit review works (requires login)
- [ ] Review appears in movie detail
- [ ] Edit/Delete review works

## 🐛 TROUBLESHOOTING:

### Error: Import not found
```bash
# Solution: Hot restart app
flutter run
# Tekan 'R' untuk hot restart
```

### Error: Firebase not initialized
```bash
# Pastikan Firebase sudah setup di main.dart:
await Firebase.initializeApp();
```

### Error: TMDB API tidak bekerja
```bash
# Check internet connection
# Check API key di lib/core/constants/api_constants.dart
```

### Error: Reviews tidak muncul
```bash
# Pastikan user sudah login
# Check Firestore rules
# Check Firebase configuration
```

## 🎉 SELAMAT! 
Fitur Community Cinema Noir sudah siap digunakan!

Sekarang Anda bisa:
1. Browse movies di Community page
2. Search movies dengan keyword
3. Lihat detail movie lengkap dengan trailer
4. Rate dan review movies
5. Lihat community statistics

Enjoy your Cinema Noir Community feature! 🍿🎬
