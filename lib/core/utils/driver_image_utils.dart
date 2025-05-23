/// Utility class for managing driver image assets
class DriverImageUtils {
  /// Map driver family names to their image file names
  static String? getDriverImagePath(String familyName) {
    final lowerFamilyName = familyName.toLowerCase().trim();
    
    // Map of family names to their corresponding asset image file names
    final driverImageMap = {
      // Current F1 drivers (2024-2025 season)
      'verstappen': 'assets/verstappen_min.avif',
      'hamilton': 'assets/hamilton_min.avif',
      'leclerc': 'assets/leclerc_min.avif',
      'norris': 'assets/norris_min.avif',
      'piastri': 'assets/piastri_min.avif',
      'sainz': 'assets/sainz_min.avif',
      'russell': 'assets/russel_min.avif', // Note: file is named 'russel' not 'russell'
      'gasly': 'assets/gasly_min.avif',
      'alonso': 'assets/alonso_min.avif',
      'ocon': 'assets/ocon_min.avif',
      'tsunoda': 'assets/tsunoda_min.avif',
      'albon': 'assets/albon_min.avif',
      'stroll': 'assets/stroll_min.avif',
      'hulkenberg': 'assets/hulkenberg_min.avif',
      'lawson': 'assets/lawson_min.avif',
      
      // New drivers and reserves for 2025
      'colapinto': 'assets/colapinto_min.avif',
      'bearman': 'assets/bearman_min.avif',
      'doohan': 'assets/doohan_min.avif',
      'antonelli': 'assets/antonelli_min.avif',
      'bortoleto': 'assets/bortoleto_min.avif',
      'hadjar': 'assets/hadjar_min.avif',
    };
    
    return driverImageMap[lowerFamilyName];
  }

  /// Generate consistent Hero tag for driver images
  static String getDriverHeroTag(String driverId, int year) {
    return 'driver_standings_${driverId}_$year';
  }

  /// Get list of all supported drivers
  static List<String> getSupportedDrivers() {
    return [
      'verstappen', 'hamilton', 'leclerc', 'norris', 'piastri', 'sainz',
      'russell', 'gasly', 'alonso', 'ocon', 'tsunoda', 'albon', 'stroll',
      'hulkenberg', 'lawson', 'colapinto', 'bearman', 'doohan', 'antonelli',
      'bortoleto', 'hadjar'
    ];
  }
}
