const String appName = 'PubScout';
const String backendBaseUrl = 'http://localhost:8000';

// The backend answers after at most ~30 s (Overpass query timeout 25 s + 5 s).
// On web, Dio's connectTimeout runs until the response headers arrive
// (dio_web_adapter), and the backend only sends them once the response is
// complete — so it must outlast the slowest backend response.
const Duration backendConnectTimeout = Duration(seconds: 40);
const Duration backendReceiveTimeout = Duration(seconds: 30);
const double defaultSearchRadiusKm = 5.0;
const double defaultZoomLevel = 13.0;

// Default center: Berlin
const double defaultLatitude = 52.5200;
const double defaultLongitude = 13.4050;
