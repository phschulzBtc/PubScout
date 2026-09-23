import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';

import '../core/constants.dart';
import '../core/theme.dart';
import '../models/venue.dart';
import '../providers/favorites_provider.dart';
import '../providers/location_provider.dart';
import '../providers/venue_provider.dart';
import '../widgets/activity_filter_bar.dart';
import '../widgets/radius_selector.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/offline_banner.dart';
import '../widgets/venue_detail_sheet.dart';
import '../widgets/venue_list_panel.dart';
import 'favorites_screen.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();
  Timer? _debounceTimer;
  bool _initialLocationSet = false;
  Venue? _selectedVenue;
  // Tracked from map events: MapController.camera throws until FlutterMap
  // has been rendered once, but markers are built during the first build.
  double _currentZoom = defaultZoomLevel;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  void _onMapEvent(MapEvent event) {
    _currentZoom = event.camera.zoom;
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

  Future<void> _goToUserLocation() async {
    final service = ref.read(locationServiceProvider);
    final location = await service.getCurrentLocation();
    _mapController.move(location, defaultZoomLevel);
    ref.read(venueFilterProvider.notifier).update(
          lat: location.latitude,
          lng: location.longitude,
        );
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
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Favoriten',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const FavoritesScreen()),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 1024;
          final isTablet =
              constraints.maxWidth > 600 && constraints.maxWidth <= 1024;

          return Column(
            children: [
              const OfflineBanner(),
              // Search + Filters
              _buildSearchFilters(context),
              // Main content area
              Expanded(
                child: isDesktop
                    ? _buildDesktopLayout(venues)
                    : isTablet
                        ? _buildTabletLayout(venues)
                        : _buildMobileLayout(venues),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToUserLocation,
        tooltip: 'Mein Standort',
        child: const Icon(Icons.my_location),
      ),
    );
  }

  Widget _buildSearchFilters(BuildContext context) {
    return Container(
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
    );
  }

  Widget _buildMapStack(AsyncValue<List<Venue>> venues) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: const LatLng(defaultLatitude, defaultLongitude),
            initialZoom: defaultZoomLevel,
            minZoom: 10,
            maxZoom: 18,
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
                  radius: ref.watch(venueFilterProvider).radiusKm * 1000,
                  useRadiusInMeter: true,
                  color: pubScoutGreen.withValues(alpha: 0.06),
                  borderColor: pubScoutGreen.withValues(alpha: 0.25),
                  borderStrokeWidth: 2,
                ),
              ],
            ),
            MarkerLayer(
              markers: _buildMarkers(venues.value ?? []),
            ),
          ],
        ),
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
                        style:
                            TextStyle(color: Colors.white, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ),
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
                    color:
                        Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Mobile: fullscreen map, venues shown via bottom sheet on tap
  Widget _buildMobileLayout(AsyncValue<List<Venue>> venues) {
    return _buildMapStack(venues);
  }

  // Tablet: map + side panel for venue detail
  Widget _buildTabletLayout(AsyncValue<List<Venue>> venues) {
    return Row(
      children: [
        Expanded(flex: 3, child: _buildMapStack(venues)),
        if (_selectedVenue != null)
          SizedBox(
            width: 320,
            child: _buildSideDetail(),
          ),
      ],
    );
  }

  // Desktop: venue list + map
  Widget _buildDesktopLayout(AsyncValue<List<Venue>> venues) {
    return Row(
      children: [
        SizedBox(
          width: 360,
          child: venues.when(
            data: (list) => VenueListPanel(
              venues: list,
              selectedVenue: _selectedVenue,
              onVenueTap: (venue) => _selectVenue(venue),
            ),
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Fehler: $e')),
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(flex: 3, child: _buildMapStack(venues)),
        if (_selectedVenue != null)
          SizedBox(
            width: 360,
            child: _buildSideDetail(),
          ),
      ],
    );
  }

  Widget _buildSideDetail() {
    final userLocation = ref.read(userLocationProvider);
    double? userLat;
    double? userLng;
    userLocation.whenData((loc) {
      userLat = loc.latitude;
      userLng = loc.longitude;
    });

    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _selectedVenue = null),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: VenueDetailSheet.buildContent(
                context,
                ref,
                _selectedVenue!,
                userLat: userLat,
                userLng: userLng,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectVenue(Venue venue) {
    setState(() => _selectedVenue = venue);
    _mapController.move(
      LatLng(venue.latitude, venue.longitude),
      _mapController.camera.zoom,
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
    final favoriteIds = ref
            .watch(favoritesProvider)
            .value
            ?.map((v) => v.osmId)
            .toSet() ??
        {};

    final clusters = _clusterVenues(venues, _currentZoom);

    return clusters.map((cluster) {
      if (cluster.length == 1) {
        final venue = cluster.first;
        final isFav = favoriteIds.contains(venue.osmId);
        final isSelected = _selectedVenue == venue;
        return Marker(
          point: LatLng(venue.latitude, venue.longitude),
          width: isSelected ? 52 : 44,
          height: isSelected ? 60 : 52,
          child: GestureDetector(
            onTap: () => _showVenuePopup(venue),
            child: _VenueMarkerIcon(
              isFavorite: isFav,
              isSelected: isSelected,
            ),
          ),
        );
      }

      // Cluster marker
      final avgLat =
          cluster.map((v) => v.latitude).reduce((a, b) => a + b) /
              cluster.length;
      final avgLng =
          cluster.map((v) => v.longitude).reduce((a, b) => a + b) /
              cluster.length;
      return Marker(
        point: LatLng(avgLat, avgLng),
        width: 44,
        height: 44,
        child: GestureDetector(
          onTap: () {
            // Zoom into the cluster
            _mapController.move(
              LatLng(avgLat, avgLng),
              math.min(_currentZoom + 2, 18),
            );
          },
          child: _ClusterIcon(count: cluster.length),
        ),
      );
    }).toList();
  }

  /// Simple grid-based clustering: at lower zoom levels, nearby venues
  /// are grouped together based on their approximate pixel distance.
  List<List<Venue>> _clusterVenues(List<Venue> venues, double zoom) {
    if (zoom >= 16) {
      return venues.map((v) => [v]).toList();
    }

    // Grid cell size in degrees — shrinks as zoom increases
    final cellSize = 360.0 / math.pow(2, zoom + 2);
    final Map<String, List<Venue>> grid = {};

    for (final venue in venues) {
      // Selected venue never clusters
      if (venue == _selectedVenue) {
        grid[venue.osmId] = [venue];
        continue;
      }
      final cx = (venue.longitude / cellSize).floor();
      final cy = (venue.latitude / cellSize).floor();
      final key = '$cx:$cy';
      grid.putIfAbsent(key, () => []).add(venue);
    }

    return grid.values.toList();
  }

  void _showVenuePopup(Venue venue) {
    setState(() => _selectedVenue = venue);

    // Zoom to the selected venue
    final zoom = _mapController.camera.zoom < 16
        ? 16.0
        : _mapController.camera.zoom;
    _mapController.move(LatLng(venue.latitude, venue.longitude), zoom);

    // On wider screens, show in side panel
    final width = MediaQuery.of(context).size.width;
    if (width > 600) return;

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
    ).whenComplete(() => setState(() => _selectedVenue = null));
  }
}

class _VenueMarkerIcon extends StatelessWidget {
  final bool isFavorite;
  final bool isSelected;

  const _VenueMarkerIcon({this.isFavorite = false, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    final double size = isSelected ? 46 : 38;
    final double iconSize = isSelected ? 24 : 20;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isFavorite
                  ? [pubScoutAmber, pubScoutCoral]
                  : [pubScoutGreen, pubScoutGreenDark],
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected
                  ? Colors.white
                  : isFavorite
                      ? pubScoutAmber
                      : Colors.white,
              width: isSelected ? 3.5 : 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? pubScoutGreen.withValues(alpha: 0.5)
                    : Colors.black26,
                blurRadius: isSelected ? 12 : 6,
                spreadRadius: isSelected ? 2 : 0,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            isFavorite ? Icons.favorite : Icons.sports_bar,
            color: Colors.white,
            size: iconSize,
          ),
        ),
        // Pin triangle
        CustomPaint(
          size: const Size(12, 8),
          painter: _PinTrianglePainter(isFavorite: isFavorite),
        ),
      ],
    );
  }
}

class _PinTrianglePainter extends CustomPainter {
  final bool isFavorite;
  _PinTrianglePainter({this.isFavorite = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isFavorite ? pubScoutCoral : pubScoutGreenDark
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

class _ClusterIcon extends StatelessWidget {
  final int count;

  const _ClusterIcon({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: pubScoutGreenDark,
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
      child: Center(
        child: Text(
          '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
