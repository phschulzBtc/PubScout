import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../core/constants.dart';
import '../models/venue.dart';
import '../providers/location_provider.dart';
import '../providers/venue_provider.dart';
import '../widgets/activity_filter_bar.dart';
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

    // Center map on user location once
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
        title: const Text(appName),
        actions: [
          venues.when(
            data: (list) {
              final filter = ref.watch(venueFilterProvider);
              final filterCount = filter.activities.length;
              final label = filterCount > 0
                  ? '${list.length} Venues ($filterCount Filter)'
                  : '${list.length} Venues';
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Center(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Center(child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )),
            ),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: Column(
        children: [
          const ActivityFilterBar(),
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
              venues.when(
                data: (list) => MarkerLayer(markers: _buildMarkers(list)),
                loading: () => const MarkerLayer(markers: []),
                error: (_, _) => const MarkerLayer(markers: []),
              ),
            ],
          ),
          // Loading overlay
          if (venues.isLoading)
            const Positioned(
              top: 8,
              left: 0,
              right: 0,
              child: Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 14,
                          height: 14,
                          child:
                              CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Venues laden...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          // Error message
          if (venues.hasError)
            Positioned(
              top: 8,
              left: 16,
              right: 16,
              child: Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Fehler beim Laden: ${venues.error}',
                    style: TextStyle(
                      color:
                          Theme.of(context).colorScheme.onErrorContainer,
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

  List<Marker> _buildMarkers(List<Venue> venues) {
    return venues.map((venue) {
      return Marker(
        point: LatLng(venue.latitude, venue.longitude),
        width: 40,
        height: 40,
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
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(Icons.sports_bar, color: Colors.white, size: 22),
    );
  }
}
