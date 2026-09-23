import 'dart:math';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/venue.dart';

class VenueDetailSheet extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.2,
      maxChildSize: 0.7,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
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
                const SizedBox(height: 16),

                // Name
                Text(venue.name, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 8),

                // Activities
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: venue.activities
                      .map((a) => Chip(
                            label: Text(a.name),
                            visualDensity: VisualDensity.compact,
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),

                // Address
                if (venue.address.isNotEmpty)
                  _InfoRow(
                    icon: Icons.location_on,
                    text: venue.address,
                  ),

                // Distance
                if (userLat != null && userLng != null)
                  _InfoRow(
                    icon: Icons.straighten,
                    text: _formatDistance(
                      _distanceKm(
                          userLat!, userLng!, venue.latitude, venue.longitude),
                    ),
                  ),

                // Opening hours
                if (venue.openingHours.isNotEmpty)
                  _InfoRow(
                    icon: Icons.access_time,
                    text: venue.openingHours,
                  ),

                const SizedBox(height: 20),

                // Route button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _openRoute(venue),
                    icon: const Icon(Icons.directions),
                    label: const Text('Route planen'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDistance(double km) {
    if (km < 1) {
      return '${(km * 1000).round()} m entfernt';
    }
    return '${km.toStringAsFixed(1)} km entfernt';
  }

  double _distanceKm(double lat1, double lng1, double lat2, double lng2) {
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

  double _toRadians(double degrees) => degrees * pi / 180;

  Future<void> _openRoute(Venue venue) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${venue.latitude},${venue.longitude}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
