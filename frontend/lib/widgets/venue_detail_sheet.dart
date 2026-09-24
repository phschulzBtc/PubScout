import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme.dart';
import '../models/venue.dart';
import '../providers/favorites_provider.dart';

class VenueDetailSheet extends ConsumerWidget {
  final Venue venue;
  final double? userLat;
  final double? userLng;

  const VenueDetailSheet({
    super.key,
    required this.venue,
    this.userLat,
    this.userLng,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.2,
      maxChildSize: 0.75,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  ...buildContentChildren(context, ref, venue,
                      userLat: userLat, userLng: userLng),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Shared content builder usable in both bottom sheet and side panel.
  static Widget buildContent(
    BuildContext context,
    WidgetRef ref,
    Venue venue, {
    double? userLat,
    double? userLng,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: buildContentChildren(context, ref, venue,
          userLat: userLat, userLng: userLng),
    );
  }

  static List<Widget> buildContentChildren(
    BuildContext context,
    WidgetRef ref,
    Venue venue, {
    double? userLat,
    double? userLng,
  }) {
    final theme = Theme.of(context);
    final favList = ref.watch(favoritesProvider).value;
    final isFavorite = favList?.any((v) => v.osmId == venue.osmId) ?? false;

    return [
      // Header: icon + name + favorite
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [pubScoutGreen, pubScoutGreenDark],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.sports_bar,
                color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(venue.name,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700)),
                if (venue.address.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(venue.address,
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                ],
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color:
                  isFavorite ? pubScoutCoral : theme.colorScheme.outline,
            ),
            onPressed: () =>
                ref.read(favoritesProvider.notifier).toggle(venue),
          ),
        ],
      ),
      const SizedBox(height: 16),

      // Description
      if (venue.description.isNotEmpty) ...[
        Text(venue.description,
            style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 16),
      ],

      // Activity chips with details
      Wrap(
        spacing: 8,
        runSpacing: 6,
        children: venue.activities
            .map((a) => Chip(
                  label: Text(
                    a.details.isNotEmpty
                        ? '${a.name} (${a.details})'
                        : a.name,
                    style: const TextStyle(fontSize: 13),
                  ),
                  backgroundColor:
                      pubScoutGreen.withValues(alpha: 0.1),
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ))
            .toList(),
      ),
      const SizedBox(height: 16),

      // Feature badges row
      if (venue.outdoorSeating ||
          venue.wheelchair.isNotEmpty) ...[
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            if (venue.outdoorSeating)
              _FeatureBadge(
                icon: Icons.deck,
                label: 'Außenbereich',
              ),
            if (venue.wheelchair == 'yes')
              _FeatureBadge(
                icon: Icons.accessible,
                label: 'Barrierefrei',
              ),
            if (venue.wheelchair == 'limited')
              _FeatureBadge(
                icon: Icons.accessible,
                label: 'Eingeschränkt barrierefrei',
              ),
          ],
        ),
        const SizedBox(height: 16),
      ],

      // Info cards
      Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            if (userLat != null && userLng != null)
              _InfoTile(
                icon: Icons.near_me,
                label: 'Entfernung',
                value: _formatDistance(_distanceKm(
                    userLat, userLng, venue.latitude, venue.longitude)),
                showDivider: venue.openingHours.isNotEmpty ||
                    venue.phone.isNotEmpty ||
                    venue.website.isNotEmpty,
              ),
            if (venue.openingHours.isNotEmpty)
              _InfoTile(
                icon: Icons.schedule,
                label: 'Öffnungszeiten',
                value: venue.openingHours,
                showDivider:
                    venue.phone.isNotEmpty || venue.website.isNotEmpty,
              ),
            if (venue.phone.isNotEmpty)
              _InfoTile(
                icon: Icons.phone,
                label: 'Telefon',
                value: venue.phone,
                showDivider: venue.website.isNotEmpty,
                onTap: () => _launchUrl('tel:${venue.phone}'),
              ),
            if (venue.website.isNotEmpty)
              _InfoTile(
                icon: Icons.language,
                label: 'Website',
                value: _shortenUrl(venue.website),
                showDivider: false,
                onTap: () => _launchUrl(venue.website),
              ),
          ],
        ),
      ),

      const SizedBox(height: 24),

      // Route button
      SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () => _openRoute(venue),
          icon: const Icon(Icons.directions),
          label: const Text('Route planen'),
        ),
      ),
    ];
  }

  static String _shortenUrl(String url) {
    return url
        .replaceFirst(RegExp(r'^https?://'), '')
        .replaceFirst(RegExp(r'^www\.'), '')
        .replaceFirst(RegExp(r'/$'), '');
  }

  static String _formatDistance(double km) {
    if (km < 1) return '${(km * 1000).round()} m';
    return '${km.toStringAsFixed(1)} km';
  }

  static double _distanceKm(
      double lat1, double lng1, double lat2, double lng2) {
    const earthRadiusKm = 6371.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _toRadians(double degrees) => degrees * pi / 180;

  static Future<void> _openRoute(Venue venue) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${venue.latitude},${venue.longitude}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _FeatureBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.secondary),
          const SizedBox(width: 4),
          Text(label,
              style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.secondary)),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool showDivider;
  final VoidCallback? onTap;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.showDivider = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: pubScoutGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
                Text(value, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          if (onTap != null)
            Icon(Icons.chevron_right,
                size: 20, color: theme.colorScheme.outline),
        ],
      ),
    );
    return Column(
      children: [
        onTap != null
            ? InkWell(onTap: onTap, child: content)
            : content,
        if (showDivider)
          Divider(height: 1, indent: 48, color: theme.dividerColor),
      ],
    );
  }
}
