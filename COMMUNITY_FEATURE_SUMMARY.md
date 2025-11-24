# 🎬 Cinema Noir - Community Feature Implementation

## ✅ Fitur Community yang Berhasil Dibuat

### 📱 **1. Community Page**
**Location:** `lib/features/community/presentation/pages/community_page.dart`

**Features:**
- Grid layout responsif untuk menampilkan movie posters (2 kolom)
- Search bar untuk mencari film berdasarkan judul
- Pagination dengan "Load More Movies" button
- Pull-to-refresh functionality
- Shimmer loading effects
- Error handling dengan retry functionality
- Empty state handling

**Navigation:** Dari HomePage → klik button "Community"

### 🎭 **2. Movie Detail Page**
**Location:** `lib/features/community/presentation/pages/movie_detail_page.dart`

**Features:**
- **Header Section:**
  - Backdrop image dengan gradient overlay
  - Floating play button untuk trailer
  - Back navigation

- **Movie Info Section:**
  - Movie poster dan basic info (title, rating, release date, runtime)
  - Genre tags dengan styling
  - Action buttons (Rate & Review, Delete Review)

- **Content Sections:**
  - Overview/Synopsis
  - Cast horizontal scroll list
  - Community rating statistics
  - User's personal review (jika ada)
  - All reviews (TMDB + User reviews)

### ⭐ **3. Rating & Review System**
**Location:** `lib/features/community/presentation/widgets/rating_dialog.dart`

**Features:**
- Interactive star rating (1-5 stars)
- Text review input dengan character counter (max 500)
- Submit/Cancel buttons dengan loading states
- Edit existing review functionality
- Delete review functionality
- Review validation

### 🗂️ **4. Data Models**

**MovieDetailModel:** Extended movie information
```dart
- Basic info (title, overview, poster, etc.)
- Cast list (actors dengan photos dan characters)
- Reviews (TMDB + user reviews)
- Trailer key untuk YouTube
- Runtime, genres, release date
```

**UserReviewModel:** User-generated reviews
```dart
- User info (name, email)
- Movie reference
- Rating (1-5)
- Review text
- Timestamps
```

### 🌐 **5. Data Sources**

**CommunityRemoteDataSource:** TMDB API integration
- Get popular/discover movies dengan pagination
- Search movies
- Get detailed movie info (cast, reviews, trailer)
- Get movies by genre

**ReviewLocalDataSource:** Firestore integration
- Add/Update user reviews
- Get user reviews for movies
- Delete reviews
- Get rating statistics
- Get trending movies berdasarkan user activity

### 🔄 **6. State Management**

**CommunityCubit:** Manages community page
- Load movies dengan pagination
- Search functionality
- Error handling
- Loading states

**MovieDetailCubit:** Manages movie detail
- Load movie details dari multiple sources
- Handle review submissions
- Manage loading states untuk reviews

### 🛣️ **7. Navigation & Routing**
Updated `AppRouter` dengan routes:
- `/community` → CommunityPage
- `/community/movie/:id` → MovieDetailPage
- Custom slide transitions
- Deep linking support

## 🚀 Cara Menjalankan Fitur Community

### **1. Setup Dependencies**
Pastikan dependencies ini ada di `pubspec.yaml`:
```yaml
dependencies:
  flutter_bloc: ^9.1.1
  equatable: ^2.0.5
  dio: ^5.3.3
  go_router: ^16.3.0
  sizer: ^2.0.15
  cached_network_image: ^3.3.0
  firebase_core: ^4.2.1
  firebase_auth: ^6.1.2
  cloud_firestore: ^6.1.0
  shimmer: ^3.0.0
  url_launcher: ^6.2.2  # ← Baru ditambahkan
```

### **2. Navigation Flow**
```
HomePage
  ↓ (klik button "Community")
CommunityPage
  ↓ (klik movie poster)
MovieDetailPage
  ↓ (klik "Rate & Review")
RatingDialog
```

### **3. Testing Steps**

**A. Test Community Page:**
1. Buka app → HomePage
2. Klik button "Community" 
3. Verify: Grid movies muncul dengan loading shimmer
4. Test search: ketik nama film di search bar
5. Scroll ke bawah → klik "Load More Movies"
6. Pull down untuk refresh

**B. Test Movie Detail:**
1. Di Community page, klik salah satu movie poster
2. Verify: Movie detail page terbuka dengan semua info
3. Klik play button (🎮) untuk buka trailer di YouTube
4. Scroll untuk lihat cast, overview, reviews

**C. Test Rating & Review:**
1. Pastikan user sudah login dengan Firebase Auth
2. Di Movie Detail page, klik "Rate & Review"
3. Pilih rating (1-5 stars)
4. Tulis review (max 500 characters)
5. Klik "Submit"
6. Verify: Review muncul di movie detail dengan highlight

### **4. Firebase Setup**
Pastikan Firestore collection `movie_reviews` sudah setup dengan structure:
```
movie_reviews/
  └── {userId}_{movieId}/
      ├── id: string
      ├── userId: string  
      ├── userName: string
      ├── userEmail: string
      ├── movieId: number
      ├── movieTitle: string
      ├── rating: number (1-5)
      ├── review: string
      ├── createdAt: timestamp
      └── updatedAt: timestamp
```

## 🔧 Troubleshooting

### **Common Issues:**

**1. "url_launcher not found"**
- Run: `flutter pub get`
- Restart IDE

**2. "Firebase not initialized"**
- Check `main.dart` has `Firebase.initializeApp()`
- Check `google-services.json` (Android) / `GoogleService-Info.plist` (iOS)

**3. "TMDB API not working"**
- Check API key di `lib/core/constants/api_constants.dart`
- Verify internet connection

**4. "Reviews tidak muncul"**
- Check Firebase Auth user logged in
- Check Firestore rules allow read/write
- Check network connection

### **5. File Structure yang Dibuat:**
```
lib/features/community/
├── data/
│   ├── models/
│   │   ├── movie_detail_model.dart
│   │   └── user_review_model.dart
│   ├── datasources/
│   │   ├── community_remote_datasource.dart
│   │   └── review_local_datasource.dart
│   └── repositories/
│       └── community_repository.dart
└── presentation/
    ├── cubit/
    │   ├── community_cubit.dart
    │   ├── community_state.dart
    │   └── movie_detail_cubit.dart
    ├── pages/
    │   ├── community_page.dart
    │   └── movie_detail_page.dart
    └── widgets/
        └── rating_dialog.dart
```

## ✨ Key Features Implemented

1. ✅ **List film dengan poster** - Grid layout di Community Page
2. ✅ **Pagination** - Load More button dengan infinite scroll detection
3. ✅ **Search functionality** - Real-time search dengan debouncing
4. ✅ **Movie detail page** - Comprehensive movie information
5. ✅ **Trailer integration** - YouTube trailer dengan url_launcher
6. ✅ **Cast information** - Horizontal scrolling cast list
7. ✅ **Reviews display** - TMDB + User reviews combined
8. ✅ **Rating system** - 5-star rating dengan visual feedback
9. ✅ **User reviews** - Firebase Firestore integration
10. ✅ **CRUD reviews** - Create, Read, Update, Delete reviews
11. ✅ **Community stats** - Average rating dan review count
12. ✅ **Responsive design** - Works on mobile dan desktop

## 🎯 Next Development Steps

1. **Favorites System** - Add movies to user favorites
2. **Advanced Filters** - Genre, year, rating filters
3. **Social Features** - Like reviews, follow users
4. **Offline Support** - Cache popular movies
5. **Push Notifications** - New reviews, trending movies

---

**🎉 Fitur Community Cinema Noir siap digunakan!**

Untuk testing, pastikan:
- Firebase Auth sudah setup dan user bisa login
- Internet connection tersedia untuk TMDB API
- All dependencies terinstall dengan `flutter pub get`