// Helper function untuk validasi waktu showtime
class ShowtimeValidator {
  /// Check if a showtime has already passed
  /// Returns true if the showtime is in the past
  static bool isShowtimePast(DateTime selectedDate, String timeString) {
    final now = DateTime.now();
    
    // If selected date is not today, showtime is not past
    if (selectedDate.year != now.year || 
        selectedDate.month != now.month || 
        selectedDate.day != now.day) {
      return false;
    }
    
    // Parse time string (format: "HH:mm")
    final timeParts = timeString.split(':');
    if (timeParts.length != 2) return false;
    
    final hour = int.tryParse(timeParts[0]);
    final minute = int.tryParse(timeParts[1]);
    
    if (hour == null || minute == null) return false;
    
    final showtime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      hour,
      minute,
    );
    
    return showtime.isBefore(now);
  }
}
