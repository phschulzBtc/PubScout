import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';

import '../core/constants.dart';
import '../core/theme.dart';
import '../models/venue.dart';
import '../providers/location_provider.dart';
import '../providers/venue_provider.dart';
import '../widgets/activity_filter_bar.dart';
import '../widgets/radius_selector.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/venue_detail_sheet.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();
  Timer? _debounceTimer;
  bool _initialLocationSet = false;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  void _onMapEvent(MapEvent event) {
    if (event is MapEventMoveEnd) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        final center = _mapController.camera.center;
        ref.read(venueFilterProvider.notifier).update(
              lat: center.latitude,
              lng: center.longitude,
            );
      });
    }
  }

  void _goToUserLocation() {
    final userLocation = ref.read(userLocationProvider);
    userLocation.whenData((location) {
      _mapController.move(location, _mapController.camera.zoom);
      ref.read(venueFilterProvider.notifier).update(
            lat: location.latitude,
            lng: location.longitude,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final venues = ref.watch(venueProvider);
    final userLocation = ref.watch(userLocationProvider);

    if (!_initialLocationSet) {
      userLocation.whenData((location) {
        _initialLocationSet = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _mapController.move(location, defaultZoomLevel);
          ref.read(venueFilterProvider.notifier).update(
                lat: location.latitude,
                lng: location.longitude,
              );
        });
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SvgPicture.asset('assets/logo.svg', height: 32, width: 32),
            const SizedBox(width: 10),
            const Text(appName),
          ],
        ),
        actions: [
          _buildVenueCount(context, venues),
        ],
      ),
      body: Column(
        children: [
          // Search + Filters area with subtle background
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                SearchBarWidget(
                  onLocationSelected: (lat, lng, name) {
                    _mapController.move(LatLng(lat, lng), defaultZoomLevel);
                    ref
                        .read(venueFilterProvider.notifier)
                        .update(lat: lat, lng: lng);
                  },
                ),
                Row(
                  children: [
                    const Expanded(child: ActivityFilterBar()),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: const RadiusSelector(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Map
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter:
                        const LatLng(defaultLatitude, defaultLongitude),
                    initialZoom: defaultZoomLevel,
                    onMapEvent: _onMapEvent,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.pubscout.app',
                    ),
                    CircleLayer(
                      circles: [
                        CircleMarker(
                          point: LatLng(
                            ref.watch(venueFilterProvider).lat,
                            ref.watch(venueFilterProvider).lng,
                          ),
                          radius:
                              ref.watch(venueFilterProvider).radiusKm * 1000,
                          useRadiusInMeter: true,
                          color: pubScoutGreen.withValues(alpha: 0.06),
                          borderColor: pubScoutGreen.withValues(alpha: 0.25),
                          borderStrokeWidth: 2,
                        ),
                      ],
                    ),
                    venues.when(
                      data: (list) =>
                          MarkerLayer(markers: _buildMarkers(list)),
                      loading: () => const MarkerLayer(markers: []),
                      error: (_, _) => const MarkerLayer(markers: []),
                    ),
                  ],
                ),
                // Loading pill
                if (venues.isLoading)
                  Positioned(
                    top: 12,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: pubScoutGreenDark,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                offset: Offset(0, 2)),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            ),
                            SizedBox(width: 8),
                            Text('Venues laden...',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                  ),
                // Error
                if (venues.hasError)
                  Positioned(
                    top: 12,
                    left: 16,
                    right: 16,
                    child: Card(
                      color: Theme.of(context).colorScheme.errorContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          'Fehler beim Laden: ${venues.error}',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onErrorContainer,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToUserLocation,
        tooltip: 'Mein Standort',
        child: const Icon(Icons.my_location),
      ),
    );
  }

  Widget _buildVenueCount(BuildContext context, AsyncValue<List<Venue>> venues) {
    return venues.when(
      data: (list) {
        final filter = ref.watch(venueFilterProvider);
        final filterCount = filter.activities.length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.place, size: 14, color: pubScoutCream),
              const SizedBox(width: 4),
              Text(
                filterCount > 0
                    ? '${list.length} ($filterCount Filter)'
                    : '${list.length}',
                style: const TextStyle(
                    color: pubScoutCream,
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Center(
            child: SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(strokeWidth: 2, color: pubScoutCream),
        )),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  List<Marker> _buildMarkers(List<Venue> venues) {
    return venues.map((venue) {
      return Marker(
        point: LatLng(venue.latitude, venue.longitude),
        width: 44,
        height: 52,
        child: GestureDetector(
          onTap: () => _showVenuePopup(venue),
          child: const _VenueMarkerIcon(),
        ),
      );
    }).toList();
  }

  void _showVenuePopup(Venue venue) {
    final userLocation = ref.read(userLocationProvider);
    double? userLat;
    double? userLng;
    userLocation.whenData((loc) {
      userLat = loc.latitude;
      userLng = loc.longitude;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VenueDetailSheet(
        venue: venue,
        userLat: userLat,
        userLng: userLng,
      ),
    );
  }
}

class _VenueMarkerIcon extends StatelessWidget {
  const _VenueMarkerIcon();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [pubScoutGreen, pubScoutGreenDark],
            ),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(Icons.sports_bar, color: Colors.white, size: 20),
        ),
        // Pin triangle
        CustomPaint(
          size: const Size(12, 8),
          painter: _PinTrianglePainter(),
        ),
      ],
    );
  }
}

class _PinTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = pubScoutGreenDark
      ..style = PaintingStyle.fill;
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
