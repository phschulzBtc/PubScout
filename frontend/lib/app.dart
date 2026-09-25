import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'l10n/app_localizations.dart';
import 'screens/map_screen.dart';

class PubScoutApp extends StatelessWidget {
  const PubScoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PubScout',
      theme: pubScoutTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const MapScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
