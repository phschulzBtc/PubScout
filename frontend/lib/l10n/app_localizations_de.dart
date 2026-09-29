// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'PubScout';

  @override
  String get searchHint => 'Ort oder Adresse suchen...';

  @override
  String get clearHistory => 'Verlauf löschen';

  @override
  String get refresh => 'Neu laden';

  @override
  String get favorites => 'Favoriten';

  @override
  String get myLocation => 'Mein Standort';

  @override
  String get searchRadius => 'Suchradius';

  @override
  String get loadingVenues => 'Venues laden...';

  @override
  String get retrying => 'Erneuter Versuch...';

  @override
  String errorLoading(String error) {
    return 'Fehler beim Laden: $error';
  }

  @override
  String get noVenuesFound => 'Keine Venues gefunden';

  @override
  String get clearFilters => 'Filter entfernen';

  @override
  String nVenues(int count) {
    return '$count Venues';
  }

  @override
  String nFilters(int count, int filterCount) {
    return '$count ($filterCount Filter)';
  }

  @override
  String get noFavoritesTitle => 'Noch keine Favoriten';

  @override
  String get noFavoritesHint =>
      'Tippe auf das Herz-Icon bei einem Venue,\num ihn als Favorit zu speichern.';

  @override
  String errorGeneric(String error) {
    return 'Fehler: $error';
  }

  @override
  String get venueTypePub => 'Kneipe';

  @override
  String get venueTypeBar => 'Bar';

  @override
  String get venueTypeBiergarten => 'Biergarten';

  @override
  String get venueTypeNightclub => 'Nachtclub';

  @override
  String get accessible => 'Barrierefrei';

  @override
  String accessibleWithCount(int count) {
    return 'Barrierefrei ($count)';
  }

  @override
  String get limitedAccessible => 'Eingeschränkt barrierefrei';

  @override
  String get opened => 'Geöffnet';

  @override
  String get closed => 'Geschlossen';

  @override
  String get outdoorSeating => 'Außenbereich';

  @override
  String get distance => 'Entfernung';

  @override
  String get openingHours => 'Öffnungszeiten';

  @override
  String get phone => 'Telefon';

  @override
  String get website => 'Website';

  @override
  String get planRoute => 'Route planen';

  @override
  String get share => 'Teilen';

  @override
  String get linkCopied => 'Link in Zwischenablage kopiert';

  @override
  String get offlineBanner => 'Offline — Favoriten weiterhin verfügbar';

  @override
  String get noVenuesWithFilters => 'Keine Venues mit diesen Filtern gefunden';

  @override
  String noVenuesInRadius(String distance) {
    return 'Keine Venues im Umkreis von $distance';
  }
}
