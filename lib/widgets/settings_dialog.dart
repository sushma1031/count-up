import 'package:count_up/gen/l10n/app_localizations.dart';
import 'package:count_up/services/settings_service.dart';
import 'package:count_up/widgets/counter.dart';
import 'package:count_up/widgets/volume_settings.dart';
import 'package:flutter/material.dart';

class SettingsDialog extends StatefulWidget {
  final SettingsService settings;

  const SettingsDialog({super.key, required this.settings});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  static const _settingsDivider = Divider(height: 24);

  late int _preWorkoutCountdownSeconds;
  late int _breakDurationSeconds;

  @override
  void initState() {
    super.initState();
    _preWorkoutCountdownSeconds = widget.settings.preWorkoutCountdownSeconds;
    _breakDurationSeconds = widget.settings.breakDurationSeconds;
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
          _settingsDivider,
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
          _settingsDivider,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  l10n.breakDurationLabel,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              Counter(
                value: _breakDurationSeconds,
                min: SettingsService.minBreakDurationSeconds,
                max: SettingsService.maxBreakDurationSeconds,
                step: SettingsService.breakDurationStepSeconds,
                onChanged: (value) {
                  setState(() {
                    _breakDurationSeconds = value;
                  });
                  widget.settings.setBreakDurationSeconds(value);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
