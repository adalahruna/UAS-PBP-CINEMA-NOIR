# Cinema Noir - Community Feature Test Guide

## Fitur Community yang Telah Dibuat

### 1. **Community Page** (`/community`)
- ✅ Grid layout untuk menampilkan movie posters
- ✅ Search functionality untuk mencari film
- ✅ Infinite scroll dengan pagination (Load More button)
- ✅ Pull-to-refresh untuk memperbarui data
- ✅ Shimmer loading effects
- ✅ Error handling dengan retry button
- ✅ Responsive design (mobile & desktop)

### 2. **Movie Detail Page** (`/community/movie/:id`)
- ✅ Backdrop image dengan overlay gradient
- ✅ Movie poster, title, rating, release date, runtime
- ✅ Genre tags
- ✅ Play trailer button (opens YouTube)
- ✅ Overview/synopsis
- ✅ Cast list horizontal scroll
- ✅ Reviews section (TMDB + User reviews)
- ✅ User rating & review system
- ✅ Community rating statistics

### 3. **Rating & Review System**
- ✅ Rating dialog dengan star rating
- ✅ Text review input (max 500 characters)
- ✅ Firebase Firestore integration untuk menyimpan user reviews
- ✅ Edit/Delete review functionality
- ✅ Display user's own review dengan highlight
- ✅ Community rating statistics

### 4. **Data Models**
- ✅ `MovieDetailModel` - Extended movie info dengan cast, reviews, trailer
- ✅ `CastModel` - Actor information dengan photo dan character
- ✅ `ReviewModel` - TMDB review data
- ✅ `UserReviewModel` - User-generated reviews dari Firestore

### 5. **Data Sources & Repository**
- ✅ `CommunityRemoteDataSource` - TMDB API calls untuk popular movies, search, details
- ✅ `ReviewLocalDataSource` - Firestore operations untuk user reviews
- ✅ `CommunityRepository` - Combines remote + local data sources

### 6. **State Management**
- ✅ `CommunityCubit` - Manages community page state dengan pagination
- ✅ `MovieDetailCubit` - Manages movie detail page state
- ✅ Proper loading, success, error states
- ✅ Review submission state management

### 7. **Navigation & Routing**
- ✅ Updated `AppRouter` dengan Community routes
- ✅ Custom page transitions
- ✅ Deep linking support untuk movie details
- ✅ Back navigation handling

## Cara Testing

### 1. **Test Navigation**
```dart
// Dari HomePage, klik button "Community"
// Harus navigate ke /community
```

### 2. **Test Community Page**
```dart
// Load initial movies
// Test search functionality
// Test scroll to trigger load more
// Test pull to refresh
// Test error handling (disconnect internet)
```

### 3. **Test Movie Detail**
```dart
// Click any movie poster di Community page
// Navigate ke /community/movie/:id
// Test trailer button (harus buka YouTube)
// Test rating dialog
// Test review submission
```

### 4. **Test Review System**
```dart
// Login dengan Firebase Auth
// Buka movie detail page
// Click "Rate & Review" button
// Submit rating dan review
// Verify review appears in movie detail
// Test edit dan delete review
```

## Error Handling yang Perlu Ditest

1. **Network Errors**
   - Internet connection loss
   - TMDB API rate limiting
   - Firebase connection issues

2. **Authentication Errors**
   - User not logged in saat submit review
   - Firebase Auth token expired

3. **Data Validation**
   - Empty review submission
   - Invalid rating values
   - Network timeout handling

## Performance Considerations

1. **Image Loading**
   - Cached network images dengan placeholders
   - Error fallbacks untuk broken images

2. **Pagination**
   - Load 20 movies per page
   - Prevent duplicate API calls
   - Loading states untuk better UX

3. **Memory Management**
   - Proper disposal of controllers
   - Efficient state management

## Next Steps untuk Enhancement

1. **Favorites System**
   - Add to favorites functionality
   - User favorites page

2. **Advanced Search**
   - Filter by genre, year, rating
   - Sort options (popularity, rating, release date)

3. **Social Features**
   - Like/dislike reviews
   - Follow other users
   - Review notifications

4. **Offline Support**
   - Cache popular movies
   - Offline review drafts

5. **Analytics**
   - Track user interactions
   - Popular movies analytics
   - User engagement metrics