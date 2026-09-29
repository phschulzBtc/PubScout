import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In de, this message translates to:
  /// **'PubScout'**
  String get appTitle;

  /// No description provided for @searchHint.
  ///
  /// In de, this message translates to:
  /// **'Ort oder Adresse suchen...'**
  String get searchHint;

  /// No description provided for @clearHistory.
  ///
  /// In de, this message translates to:
  /// **'Verlauf löschen'**
  String get clearHistory;

  /// No description provided for @refresh.
  ///
  /// In de, this message translates to:
  /// **'Neu laden'**
  String get refresh;

  /// No description provided for @favorites.
  ///
  /// In de, this message translates to:
  /// **'Favoriten'**
  String get favorites;

  /// No description provided for @myLocation.
  ///
  /// In de, this message translates to:
  /// **'Mein Standort'**
  String get myLocation;

  /// No description provided for @searchRadius.
  ///
  /// In de, this message translates to:
  /// **'Suchradius'**
  String get searchRadius;

  /// No description provided for @loadingVenues.
  ///
  /// In de, this message translates to:
  /// **'Venues laden...'**
  String get loadingVenues;

  /// No description provided for @retrying.
  ///
  /// In de, this message translates to:
  /// **'Erneuter Versuch...'**
  String get retrying;

  /// No description provided for @errorLoading.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Laden: {error}'**
  String errorLoading(String error);

  /// No description provided for @noVenuesFound.
  ///
  /// In de, this message translates to:
  /// **'Keine Venues gefunden'**
  String get noVenuesFound;

  /// No description provided for @clearFilters.
  ///
  /// In de, this message translates to:
  /// **'Filter entfernen'**
  String get clearFilters;

  /// No description provided for @nVenues.
  ///
  /// In de, this message translates to:
  /// **'{count} Venues'**
  String nVenues(int count);

  /// No description provided for @nFilters.
  ///
  /// In de, this message translates to:
  /// **'{count} ({filterCount} Filter)'**
  String nFilters(int count, int filterCount);

  /// No description provided for @noFavoritesTitle.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Favoriten'**
  String get noFavoritesTitle;

  /// No description provided for @noFavoritesHint.
  ///
  /// In de, this message translates to:
  /// **'Tippe auf das Herz-Icon bei einem Venue,\num ihn als Favorit zu speichern.'**
  String get noFavoritesHint;

  /// No description provided for @errorGeneric.
  ///
  /// In de, this message translates to:
  /// **'Fehler: {error}'**
  String errorGeneric(String error);

  /// No description provided for @venueTypePub.
  ///
  /// In de, this message translates to:
  /// **'Kneipe'**
  String get venueTypePub;

  /// No description provided for @venueTypeBar.
  ///
  /// In de, this message translates to:
  /// **'Bar'**
  String get venueTypeBar;

  /// No description provided for @venueTypeBiergarten.
  ///
  /// In de, this message translates to:
  /// **'Biergarten'**
  String get venueTypeBiergarten;

  /// No description provided for @venueTypeNightclub.
  ///
  /// In de, this message translates to:
  /// **'Nachtclub'**
  String get venueTypeNightclub;

  /// No description provided for @accessible.
  ///
  /// In de, this message translates to:
  /// **'Barrierefrei'**
  String get accessible;

  /// No description provided for @accessibleWithCount.
  ///
  /// In de, this message translates to:
  /// **'Barrierefrei ({count})'**
  String accessibleWithCount(int count);

  /// No description provided for @limitedAccessible.
  ///
  /// In de, this message translates to:
  /// **'Eingeschränkt barrierefrei'**
  String get limitedAccessible;

  /// No description provided for @opened.
  ///
  /// In de, this message translates to:
  /// **'Geöffnet'**
  String get opened;

  /// No description provided for @closed.
  ///
  /// In de, this message translates to:
  /// **'Geschlossen'**
  String get closed;

  /// No description provided for @outdoorSeating.
  ///
  /// In de, this message translates to:
  /// **'Außenbereich'**
  String get outdoorSeating;

  /// No description provided for @distance.
  ///
  /// In de, this message translates to:
  /// **'Entfernung'**
  String get distance;

  /// No description provided for @openingHours.
  ///
  /// In de, this message translates to:
  /// **'Öffnungszeiten'**
  String get openingHours;

  /// No description provided for @phone.
  ///
  /// In de, this message translates to:
  /// **'Telefon'**
  String get phone;

  /// No description provided for @website.
  ///
  /// In de, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @planRoute.
  ///
  /// In de, this message translates to:
  /// **'Route planen'**
  String get planRoute;

  /// No description provided for @share.
  ///
  /// In de, this message translates to:
  /// **'Teilen'**
  String get share;

  /// No description provided for @linkCopied.
  ///
  /// In de, this message translates to:
  /// **'Link in Zwischenablage kopiert'**
  String get linkCopied;

  /// No description provided for @offlineBanner.
  ///
  /// In de, this message translates to:
  /// **'Offline — Favoriten weiterhin verfügbar'**
  String get offlineBanner;

  /// No description provided for @noVenuesWithFilters.
  ///
  /// In de, this message translates to:
  /// **'Keine Venues mit diesen Filtern gefunden'**
  String get noVenuesWithFilters;

  /// No description provided for @noVenuesInRadius.
  ///
  /// In de, this message translates to:
  /// **'Keine Venues im Umkreis von {distance}'**
  String noVenuesInRadius(String distance);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
