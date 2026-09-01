import 'package:dio/dio.dart';

/// Reverse-geocodes a tapped map point into a human-readable address via
/// Nominatim (OpenStreetMap's free geocoding service, no API key needed —
/// same service the web app uses). Uses its own [Dio] instance since the
/// app's shared client is wired to the local backend's base URL and auth
/// header, neither of which apply here.
class GeocodingApi {
  GeocodingApi()
      : _dio = Dio(BaseOptions(
          baseUrl: 'https://nominatim.openstreetmap.org',
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
          headers: {
            // Nominatim's usage policy requires an identifiable User-Agent.
            'User-Agent': 'EventPlannerMobile/1.0',
          },
        ));

  final Dio _dio;

  /// Returns a display address for the given point, or null if the lookup
  /// fails — this is a best-effort convenience, never required to save a
  /// location.
  Future<String?> reverseGeocode(double lat, double lng) async {
    try {
      final response = await _dio.get('/reverse', queryParameters: {
        'format': 'json',
        'lat': lat,
        'lon': lng,
        'accept-language': 'en',
      });
      final data = response.data;
      if (data is Map && data['display_name'] is String) {
        return data['display_name'] as String;
      }
    } catch (_) {
      // Ignored: the address field is left for the user to fill in by hand.
    }
    return null;
  }
}
