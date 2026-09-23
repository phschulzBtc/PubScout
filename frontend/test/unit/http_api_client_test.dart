import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pubscout/services/api_client.dart';
import 'package:pubscout/services/api_exception.dart';

/// A minimal Dio interceptor that returns canned responses without hitting the network.
class MockInterceptor extends Interceptor {
  final dynamic Function(RequestOptions) responseBuilder;

  MockInterceptor(this.responseBuilder);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final data = responseBuilder(options);
    handler.resolve(Response(
      requestOptions: options,
      data: data,
      statusCode: 200,
    ));
  }
}

class ErrorInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    handler.reject(DioException(
      requestOptions: options,
      type: DioExceptionType.connectionTimeout,
      message: 'Connection timed out',
    ));
  }
}

Dio _createMockDio(dynamic Function(RequestOptions) builder) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'));
  dio.interceptors.add(MockInterceptor(builder));
  return dio;
}

void main() {
  group('HttpApiClient', () {
    test('fetchActivities parses response correctly', () async {
      final dio = _createMockDio((_) => [
            {'name': 'Darts', 'icon': 'darts', 'osm_tags': ['leisure=darts']},
            {'name': 'Pool', 'icon': 'pool', 'osm_tags': []},
          ]);
      final client = HttpApiClient(dio: dio);

      final activities = await client.fetchActivities();
      expect(activities, hasLength(2));
      expect(activities.first.name, 'Darts');
    });

    test('fetchVenues passes correct query parameters', () async {
      late RequestOptions capturedOptions;
      final dio = _createMockDio((options) {
        capturedOptions = options;
        return [
          {
            'name': 'Bar',
            'latitude': 52.0,
            'longitude': 13.0,
            'osm_id': 'node/1',
            'activities': [],
          }
        ];
      });
      final client = HttpApiClient(dio: dio);

      await client.fetchVenues(
        lat: 52.5,
        lng: 13.4,
        radiusKm: 10.0,
        activities: ['Darts', 'Pool'],
      );

      expect(capturedOptions.queryParameters['lat'], 52.5);
      expect(capturedOptions.queryParameters['lng'], 13.4);
      expect(capturedOptions.queryParameters['radius_km'], 10.0);
      expect(capturedOptions.queryParameters['activities'], 'Darts,Pool');
    });

    test('fetchVenues omits activities param when null', () async {
      late RequestOptions capturedOptions;
      final dio = _createMockDio((options) {
        capturedOptions = options;
        return <Map<String, dynamic>>[];
      });
      final client = HttpApiClient(dio: dio);

      await client.fetchVenues(lat: 52.0, lng: 13.0);

      expect(capturedOptions.queryParameters.containsKey('activities'), isFalse);
    });

    test('throws ApiException on network error', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://test'));
      dio.interceptors.add(ErrorInterceptor());
      final client = HttpApiClient(dio: dio);

      expect(
        () => client.fetchActivities(),
        throwsA(isA<ApiException>()),
      );
    });

    test('throws ApiException on unexpected response format', () async {
      final dio = _createMockDio((_) => {'error': 'not a list'});
      final client = HttpApiClient(dio: dio);

      expect(
        () => client.fetchActivities(),
        throwsA(isA<ApiException>().having(
          (e) => e.message,
          'message',
          contains('Unexpected response format'),
        )),
      );
    });
  });
}
