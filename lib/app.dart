import 'package:flutter/material.dart';
import 'package:count_up/utils/assets.dart';
import 'screens/workouts_screen.dart';
import 'services/storage_service.dart';
import 'services/settings_service.dart';
import 'state/lifecycle_watcher.dart';
import 'state/settings_provider.dart';
import 'utils/color.dart';
import 'utils/errors.dart';
import 'gen/l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CountUpApp extends StatelessWidget {
  final StorageService db;
  final SettingsService settings;

  CountUpApp({required this.db, required this.settings});

  @override
  Widget build(BuildContext context) {
    ColorScheme _colorScheme = ColorScheme.dark().copyWith(
        primary: Colors.indigo.shade200,
        primaryContainer: Colors.indigo.shade700,
        secondary: Colors.deepPurple.shade200,
        secondaryContainer: Colors.deepPurple.shade200,
        error: AppColors.error,
        onPrimaryContainer: Colors.white);
    return SettingsProvider(
      settings: settings,
      child: MaterialApp(
          title: 'Count Up',
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(
              useMaterial3: false,
              brightness: Brightness.dark,
              primarySwatch: Colors.indigo,
              colorScheme: _colorScheme,
              applyElevationOverlayColor: true,
              snackBarTheme: SnackBarThemeData(
                  behavior: SnackBarBehavior.floating,
                  insetPadding: const EdgeInsets.all(16),
                  backgroundColor: darken(_colorScheme.onSurface, 0.2),
                  actionTextColor: _colorScheme.primaryContainer,
                  elevation: 16)),
          home: LifecycleWatcher(
            child: HomePage(db: db),
          )),
    );
  }
}

class HomePage extends StatefulWidget {
  final StorageService db;
  const HomePage({Key? key, required this.db}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _hasShownSettingsPersistenceWarning = false;

  Future<void> loadDataWithDelay() async {
    await widget.db.loadData();
    await Future.delayed(Duration(seconds: 2));
  }

  void _showSettingsPersistenceWarning(BuildContext context) {
    final settings = SettingsProvider.of(context);
    if (_hasShownSettingsPersistenceWarning || settings.isPersistenceAvailable) {
      return;
    }

    final warningColour = darken(AppColors.warning);
    final warningText = AppLocalizations.of(context).settingsNotPersistedWarning;

    _hasShownSettingsPersistenceWarning = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: warningColour,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(warningText, style: TextStyle(height: 1.4)),
              ),
            ],
          ),
          duration: const Duration(seconds: 6),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: loadDataWithDelay(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        final l10n = AppLocalizations.of(context);
        if (snapshot.connectionState != ConnectionState.done) {
          final gradient = LinearGradient(colors: [Colors.indigo.shade200, Colors.indigo]);
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: Center(
              child: ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) => gradient.createShader(
                  Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                ),
                child: Text(
                  l10n.splashTitle,
                  style: TextStyle(
                    fontSize: 40,
                    fontFamily: Assets.fontEthosNova,
                  ),
                ),
              ),
            ),
          );
        }
        if (snapshot.hasError) {
          final error = snapshot.error;
          String message;
          if (error is HiveError) {
            message = errorMessageFor(context, AppError.dbInitFailed);
          } else {
            message = errorMessageFor(context, AppError.unknown);
          }
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                      padding: EdgeInsetsGeometry.only(bottom: 24),
                      child: Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.redAccent,
                      )),
                  Text(message, textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
                  Padding(
                      padding: EdgeInsetsGeometry.symmetric(vertical: 16),
                      child: Text(
                        l10n.tryAgainMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                      )),
                  Padding(
                    padding: EdgeInsetsGeometry.symmetric(vertical: 16),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 0)),
                      onPressed: () {
                        setState(() {});
                      },
                      child: Text(l10n.retryBtn),
                    ),
                  )
                ],
              ),
            ),
          );
        } else {
          _showSettingsPersistenceWarning(context);
          return WorkoutsScreen(db: widget.db);
        }
      },
    );
  }
}
