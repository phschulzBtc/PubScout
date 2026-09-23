import 'package:dio/dio.dart';

import '../core/constants.dart';
import '../models/activity.dart';
import '../models/venue.dart';
import 'api_exception.dart';

abstract class ApiClient {
  Future<List<Activity>> fetchActivities();
  Future<List<Venue>> fetchVenues({
    required double lat,
    required double lng,
    double radiusKm = defaultSearchRadiusKm,
    List<String>? activities,
  });
}

class HttpApiClient implements ApiClient {
  final Dio _dio;

  HttpApiClient({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: backendBaseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 30),
            ));

  @override
  Future<List<Activity>> fetchActivities() async {
    try {
      final response = await _dio.get('/activities');
      final data = response.data;
      if (data is! List) {
        throw const ApiException('Unexpected response format for activities');
      }
      return data
          .map((e) => Activity.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<Venue>> fetchVenues({
    required double lat,
    required double lng,
    double radiusKm = defaultSearchRadiusKm,
    List<String>? activities,
  }) async {
    final queryParams = <String, dynamic>{
      'lat': lat,
      'lng': lng,
      'radius_km': radiusKm,
    };
    if (activities != null && activities.isNotEmpty) {
      queryParams['activities'] = activities.join(',');
    }

    try {
      final response = await _dio.get('/venues', queryParameters: queryParams);
      final data = response.data;
      if (data is! List) {
        throw const ApiException('Unexpected response format for venues');
      }
      return data
          .map((e) => Venue.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
