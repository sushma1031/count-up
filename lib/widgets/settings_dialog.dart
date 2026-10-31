import 'package:count_up/gen/l10n/app_localizations.dart';
import 'package:count_up/services/settings_service.dart';
import 'package:count_up/widgets/counter.dart';
import 'package:count_up/widgets/volume_settings.dart';
import 'package:flutter/material.dart';

class SettingsDialog extends StatefulWidget {
  final SettingsService settings;

  const SettingsDialog({Key? key, required this.settings}) : super(key: key);

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late int _preWorkoutCountdownSeconds;

  @override
  void initState() {
    super.initState();
    _preWorkoutCountdownSeconds = widget.settings.preWorkoutCountdownSeconds;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.settingsTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          VolumeSettings(
            initial: widget.settings.soundVolume,
            onChanged: widget.settings.setSoundVolume,
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  l10n.preWorkoutCountdownLabel,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              Counter(
                value: _preWorkoutCountdownSeconds,
                min: SettingsService.minPreWorkoutCountdownSeconds,
                max: SettingsService.maxPreWorkoutCountdownSeconds,
                onChanged: (value) {
                  setState(() {
                    _preWorkoutCountdownSeconds = value;
                  });
                  widget.settings.setPreWorkoutCountdownSeconds(value);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
