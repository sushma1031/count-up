import 'package:count_up/gen/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

Widget localizedApp(Widget home) => MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    );
