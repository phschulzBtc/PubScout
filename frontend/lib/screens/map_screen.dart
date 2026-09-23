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
            venues.when(
              data: (list) => MarkerLayer(markers: _buildMarkers(list)),
              loading: () => const MarkerLayer(markers: []),
              error: (_, _) => const MarkerLayer(markers: []),
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

    return venues.map((venue) {
      final isFav = favoriteIds.contains(venue.osmId);
      return Marker(
        point: LatLng(venue.latitude, venue.longitude),
        width: 44,
        height: 52,
        child: GestureDetector(
          onTap: () => _showVenuePopup(venue),
          child: _VenueMarkerIcon(isFavorite: isFav),
        ),
      );
    }).toList();
  }

  void _showVenuePopup(Venue venue) {
    // On wider screens, show in side panel
    final width = MediaQuery.of(context).size.width;
    if (width > 600) {
      _selectVenue(venue);
      return;
    }

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
  final bool isFavorite;

  const _VenueMarkerIcon({this.isFavorite = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 38,
          height: 38,
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
              color: isFavorite ? pubScoutAmber : Colors.white,
              width: 2.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            isFavorite ? Icons.favorite : Icons.sports_bar,
            color: Colors.white,
            size: 20,
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
