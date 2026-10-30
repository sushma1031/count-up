import 'package:flutter/material.dart';
import 'package:count_up/utils/assets.dart';
import 'screens/workouts_screen.dart';
import 'services/storage_service.dart';
import 'services/settings_service.dart';
import 'state/lifecycle_watcher.dart';
import 'state/settings_provider.dart';
import 'utils/color.dart';
import 'utils/errors.dart';
import 'utils/error_formatters.dart';
import 'gen/l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CountUpApp extends StatelessWidget {
  final StorageService db;
  final SettingsService settings;

  CountUpApp({required this.db, required this.settings});

  @override
  Widget build(BuildContext context) {
    final background = const ColorScheme.dark().surface;
    final neutral = ColorScheme.fromSeed(
        seedColor: Colors.indigo,
        brightness: Brightness.dark,
        dynamicSchemeVariant: DynamicSchemeVariant.monochrome);
    final colorScheme =
        ColorScheme.fromSeed(seedColor: Colors.indigo, brightness: Brightness.dark).copyWith(
      primary: Colors.indigo.shade200,
      primaryContainer: Colors.indigo.shade700,
      onPrimaryContainer: Colors.white,
      secondary: Colors.deepPurple.shade200,
      surface: background,
      surfaceContainerLowest: background,
      surfaceDim: neutral.surfaceDim,
      surfaceBright: neutral.surfaceBright,
      surfaceContainerLow: neutral.surfaceContainerLow,
      surfaceContainer: neutral.surfaceContainer,
      surfaceContainerHigh: neutral.surfaceContainerHigh,
      surfaceContainerHighest: neutral.surfaceContainerHighest,
      onSurface: neutral.onSurface,
      onSurfaceVariant: neutral.onSurfaceVariant,
      outline: neutral.outline,
      outlineVariant: neutral.outlineVariant,
      inverseSurface: neutral.inverseSurface,
      onInverseSurface: neutral.onInverseSurface,
    );
    return SettingsProvider(
      settings: settings,
      child: MaterialApp(
          title: 'Count Up',
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(
              colorScheme: colorScheme,
              appBarTheme:
                  const AppBarTheme(backgroundColor: Colors.transparent, scrolledUnderElevation: 0),
              snackBarTheme: const SnackBarThemeData(
                  behavior: SnackBarBehavior.floating, insetPadding: EdgeInsets.all(16)),
              floatingActionButtonTheme: FloatingActionButtonThemeData(
                  backgroundColor: colorScheme.secondary,
                  foregroundColor: colorScheme.onSecondary)),
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
                        color: Theme.of(context).colorScheme.error,
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
                    child: FilledButton(
                      style: FilledButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 0)),
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
