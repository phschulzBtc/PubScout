import 'package:dio/dio.dart';

class NominatimResult {
  final String displayName;
  final double latitude;
  final double longitude;

  const NominatimResult({
    required this.displayName,
    required this.latitude,
    required this.longitude,
  });

  factory NominatimResult.fromJson(Map<String, dynamic> json) {
    return NominatimResult(
      displayName: json['display_name'] as String,
      latitude: double.parse(json['lat'] as String),
      longitude: double.parse(json['lon'] as String),
    );
  }
}

class NominatimService {
  final Dio _dio;

  NominatimService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: 'https://nominatim.openstreetmap.org',
              headers: {'User-Agent': 'PubScout/1.0 (contact@pubscout.app)'},
              connectTimeout: const Duration(seconds: 5),
              receiveTimeout: const Duration(seconds: 10),
            ));

  Future<List<NominatimResult>> search(String query) async {
    if (query.trim().length < 2) return [];

    final response = await _dio.get('/search', queryParameters: {
      'q': query,
      'format': 'json',
      'limit': 5,
      'addressdetails': 0,
    });

    final data = response.data as List<dynamic>;
    return data
        .map((e) => NominatimResult.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
