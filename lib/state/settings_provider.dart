import 'package:flutter/widgets.dart';
import '../services/settings_service.dart';

/// Exposes [SettingsService] to the widget tree.
///
/// This must be mounted above the [MaterialApp] so that children
/// of the app's Navigator can still reach it.
class SettingsProvider extends InheritedWidget {
  final SettingsService settings;

  const SettingsProvider({
    super.key,
    required this.settings,
    required super.child,
  });

  static SettingsService of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<SettingsProvider>();
    if (provider == null) {
      throw FlutterError(
          'SettingsProvider.of() called with a context that does not contain a SettingsProvider.\n'
          'Ensure a SettingsProvider is mounted above the MaterialApp.');
    }
    return provider.settings;
  }

  @override
  bool updateShouldNotify(SettingsProvider oldWidget) =>
      settings != oldWidget.settings;
}
