// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'PubScout';

  @override
  String get searchHint => 'Search for a place or address...';

  @override
  String get clearHistory => 'Clear history';

  @override
  String get refresh => 'Refresh';

  @override
  String get favorites => 'Favorites';

  @override
  String get myLocation => 'My location';

  @override
  String get searchRadius => 'Search radius';

  @override
  String get loadingVenues => 'Loading venues...';

  @override
  String get retrying => 'Retrying...';

  @override
  String errorLoading(String error) {
    return 'Error loading: $error';
  }

  @override
  String get noVenuesFound => 'No venues found';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String nVenues(int count) {
    return '$count Venues';
  }

  @override
  String nFilters(int count, int filterCount) {
    return '$count ($filterCount Filters)';
  }

  @override
  String get noFavoritesTitle => 'No favorites yet';

  @override
  String get noFavoritesHint =>
      'Tap the heart icon on a venue\nto save it as a favorite.';

  @override
  String errorGeneric(String error) {
    return 'Error: $error';
  }

  @override
  String get venueTypePub => 'Pub';

  @override
  String get venueTypeBar => 'Bar';

  @override
  String get venueTypeBiergarten => 'Beer Garden';

  @override
  String get venueTypeNightclub => 'Nightclub';

  @override
  String get accessible => 'Wheelchair accessible';

  @override
  String accessibleWithCount(int count) {
    return 'Accessible ($count)';
  }

  @override
  String get limitedAccessible => 'Limited accessibility';

  @override
  String get opened => 'Open';

  @override
  String get closed => 'Closed';

  @override
  String get outdoorSeating => 'Outdoor seating';

  @override
  String get distance => 'Distance';

  @override
  String get openingHours => 'Opening hours';

  @override
  String get phone => 'Phone';

  @override
  String get website => 'Website';

  @override
  String get planRoute => 'Get directions';

  @override
  String get share => 'Share';

  @override
  String get linkCopied => 'Link copied to clipboard';

  @override
  String get offlineBanner => 'Offline — Favorites still available';

  @override
  String get noVenuesWithFilters => 'No venues found with these filters';

  @override
  String noVenuesInRadius(String distance) {
    return 'No venues within $distance';
  }
}
