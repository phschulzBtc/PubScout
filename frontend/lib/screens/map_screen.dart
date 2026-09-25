import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';

import '../core/constants.dart';
import '../core/geo_utils.dart';
import '../core/theme.dart';
import '../l10n/app_localizations.dart';
import '../models/venue.dart';
import '../providers/api_client_provider.dart';
import '../providers/connectivity_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/location_provider.dart';
import '../providers/venue_provider.dart';
import '../widgets/activity_filter_bar.dart';
import '../widgets/radius_selector.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/offline_banner.dart';
import '../widgets/venue_detail_sheet.dart';
import '../widgets/venue_list_panel.dart';
import '../widgets/venue_type_filter_bar.dart';
import 'favorites_screen.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();
  Timer? _debounceTimer;
  Timer? _preloadTimer;
  bool _initialLocationSet = false;
  Venue? _selectedVenue;
  // Tracked from map events: MapController.camera throws until FlutterMap
  // has been rendered once, but markers are built during the first build.
  double _currentZoom = defaultZoomLevel;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _preloadTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  void _onMapEvent(MapEvent event) {
    final newZoom = event.camera.zoom;
    // Rebuild markers when zoom crosses a clustering threshold.
    if (newZoom.floor() != _currentZoom.floor()) {
      _currentZoom = newZoom;
      setState(() {});
    } else {
      _currentZoom = newZoom;
    }
    if (event is MapEventMoveEnd) {
      _preloadTimer?.cancel();
      _debounceTimer?.cancel();

      // Preload: fire a cache-warming request after 200ms
      _preloadTimer = Timer(const Duration(milliseconds: 200), () {
        final center = _mapController.camera.center;
        final radius = ref.read(venueFilterProvider).radiusKm;
        // Fire-and-forget: warm the cache for the current viewport
        ref.read(apiClientProvider).fetchVenues(
              lat: center.latitude,
              lng: center.longitude,
              radiusKm: radius,
            );
      });

      // Display update: update filter state after 500ms (will hit cache)
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
    var venues = ref.watch(filteredVenueProvider);
    final isOnline = ref.watch(connectivityProvider);
    final userLocation = ref.watch(userLocationProvider);

    // Offline fallback: show favorites on the map
    if (!isOnline && (venues.value?.isEmpty ?? true)) {
      final favs = ref.watch(favoritesProvider).value ?? [];
      if (favs.isNotEmpty) {
        venues = AsyncData(favs);
      }
    }

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
            icon: const Icon(Icons.refresh),
            tooltip: AppLocalizations.of(context)!.refresh,
            onPressed: _refreshVenues,
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: AppLocalizations.of(context)!.favorites,
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
        tooltip: AppLocalizations.of(context)!.myLocation,
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
              const Expanded(child: VenueTypeFilterBar()),
              _WheelchairChip(),
            ],
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
    final isBackgroundLoading = ref.watch(venueLoadingProvider);
    final showLoading = venues.isLoading || isBackgroundLoading;

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
        if (showLoading)
          Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: Center(
              child: _LoadingPill(),
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
                  AppLocalizations.of(context)!.errorLoading(venues.error.toString()),
                  style: TextStyle(
                    color:
                        Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ),
          ),
        if (!showLoading &&
            !venues.hasError &&
            (venues.value?.isEmpty ?? false))
          Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: Center(
              child: _EmptyResultPill(
                onClearFilters: _hasActiveFilters()
                    ? () => ref.read(venueFilterProvider.notifier).update(
                          activities: [],
                          venueTypes: [],
                          wheelchairOnly: false,
                        )
                    : null,
              ),
            ),
          ),
      ],
    );
  }

  bool _hasActiveFilters() {
    final filter = ref.read(venueFilterProvider);
    return filter.activities.isNotEmpty ||
        filter.venueTypes.isNotEmpty ||
        filter.wheelchairOnly;
  }

  Future<void> _refreshVenues() async {
    ref.invalidate(venueProvider);
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
          child: VenueListPanel(
            venues: venues.value ?? [],
            selectedVenue: _selectedVenue,
            onVenueTap: (venue) => _selectVenue(venue),
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
    final zoom = _mapController.camera.zoom < 17
        ? 17.0
        : _mapController.camera.zoom;
    _mapController.move(
      LatLng(venue.latitude, venue.longitude),
      zoom,
    );
  }

  Widget _buildVenueCount(BuildContext context, AsyncValue<List<Venue>> venues) {
    final isBackgroundLoading = ref.watch(venueLoadingProvider);
    final list = venues.value;

    if (list == null && venues.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Center(
            child: SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(strokeWidth: 2, color: pubScoutCream),
        )),
      );
    }
    if (venues.hasError && list == null) {
      return const SizedBox.shrink();
    }

    final count = list?.length ?? 0;
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
          if (isBackgroundLoading) ...[
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                  strokeWidth: 1.5, color: pubScoutCream),
            ),
            const SizedBox(width: 6),
          ] else ...[
            const Icon(Icons.place, size: 14, color: pubScoutCream),
            const SizedBox(width: 4),
          ],
          Text(
            filterCount > 0
                ? AppLocalizations.of(context)!.nFilters(count, filterCount)
                : '$count',
            style: const TextStyle(
                color: pubScoutCream,
                fontSize: 12,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  List<Marker> _buildMarkers(List<Venue> venues) {
    final favoriteIds = ref
            .watch(favoritesProvider)
            .value
            ?.map((v) => v.osmId)
            .toSet() ??
        {};

    double zoom;
    try {
      zoom = _mapController.camera.zoom;
    } catch (_) {
      zoom = defaultZoomLevel;
    }
    final clusters = _clusterVenues(venues, zoom);

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
              venueType: venue.venueType,
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
            if (cluster.length > 20) {
              _mapController.move(
                LatLng(avgLat, avgLng),
                math.min(_currentZoom + 2, 18),
              );
            } else {
              _showClusterSheet(cluster);
            }
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
    final zoom = _mapController.camera.zoom < 17
        ? 17.0
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

  void _showClusterSheet(List<Venue> cluster) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ClusterBottomSheet(
        venues: cluster,
        onVenueTap: (venue) {
          Navigator.of(context).pop();
          _showVenuePopup(venue);
        },
      ),
    );
  }
}

class _ClusterBottomSheet extends StatelessWidget {
  final List<Venue> venues;
  final ValueChanged<Venue> onVenueTap;

  const _ClusterBottomSheet({
    required this.venues,
    required this.onVenueTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.2,
      maxChildSize: 0.65,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag handle + header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.place,
                            size: 20, color: pubScoutGreen),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.nVenues(venues.length),
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Venue list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: venues.length,
                  itemBuilder: (context, index) {
                    final venue = venues[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 2),
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [pubScoutGreen, pubScoutGreenDark],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _iconForVenueType(venue.venueType),
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      title: Text(venue.name,
                          style:
                              const TextStyle(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      subtitle: Text(
                        venueTypeLabel(venue.venueType, AppLocalizations.of(context)!) +
                            (venue.address.isNotEmpty
                                ? ' · ${venue.address}'
                                : ''),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: venue.activities.isNotEmpty
                          ? Text('${venue.activities.length}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                  color:
                                      theme.colorScheme.onSurfaceVariant))
                          : null,
                      onTap: () => onVenueTap(venue),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static IconData _iconForVenueType(String type) {
    return switch (type) {
      'bar' => Icons.local_bar,
      'biergarten' => Icons.deck,
      'nightclub' => Icons.nightlife,
      _ => Icons.sports_bar,
    };
  }
}

class _VenueMarkerIcon extends StatelessWidget {
  final String venueType;
  final bool isFavorite;
  final bool isSelected;

  const _VenueMarkerIcon({
    this.venueType = 'pub',
    this.isFavorite = false,
    this.isSelected = false,
  });

  static IconData _iconForType(String type) {
    return switch (type) {
      'bar' => Icons.local_bar,
      'biergarten' => Icons.deck,
      'nightclub' => Icons.nightlife,
      _ => Icons.sports_bar,
    };
  }

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
            isFavorite ? Icons.favorite : _iconForType(venueType),
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

class _LoadingPill extends StatefulWidget {
  @override
  State<_LoadingPill> createState() => _LoadingPillState();
}

class _LoadingPillState extends State<_LoadingPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: pubScoutGreenDark,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.loadingVenues,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _WheelchairChip extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = ref.watch(venueFilterProvider).wheelchairOnly;
    final count = ref.watch(wheelchairCountProvider);

    if (count == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: FilterChip(
        label: Text(isActive
            ? AppLocalizations.of(context)!.accessibleWithCount(count)
            : AppLocalizations.of(context)!.accessible),
        selected: isActive,
        onSelected: (_) => ref
            .read(venueFilterProvider.notifier)
            .update(wheelchairOnly: !isActive),
        avatar: const Icon(Icons.accessible, size: 18),
        showCheckmark: false,
        selectedColor: Theme.of(context).colorScheme.primaryContainer,
      ),
    );
  }
}

class _EmptyResultPill extends StatelessWidget {
  final VoidCallback? onClearFilters;

  const _EmptyResultPill({this.onClearFilters});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off, size: 16),
          const SizedBox(width: 8),
          Text(AppLocalizations.of(context)!.noVenuesFound,
              style: const TextStyle(fontSize: 13)),
          if (onClearFilters != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onClearFilters,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: pubScoutGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(AppLocalizations.of(context)!.clearFilters,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
