import 'package:count_up/gen/l10n/app_localizations.dart';
import 'package:count_up/services/settings_service.dart';
import 'package:count_up/widgets/counter.dart';
import 'package:flutter/material.dart';

const double _kSheetContentPadding = 20;
const List<int> _kPresetSeconds = [10, 15, 30];

Future<void> showBreakSheet(
  BuildContext context, {
  required int? seconds,
  required int defaultSeconds,
  required ValueChanged<int?> onChanged,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) =>
        BreakSheet(seconds: seconds, defaultSeconds: defaultSeconds, onChanged: onChanged),
  );
}

class BreakSheet extends StatefulWidget {
  final int? seconds;
  final int defaultSeconds;
  final ValueChanged<int?> onChanged;

  const BreakSheet(
      {super.key, required this.seconds, required this.defaultSeconds, required this.onChanged});

  @override
  State<BreakSheet> createState() => _BreakSheetState();
}

class _BreakSheetState extends State<BreakSheet> {
  late int? _seconds = widget.seconds;

  void _select(int? seconds) {
    setState(() => _seconds = seconds);
    widget.onChanged(seconds);
  }

  Widget _pill(String label, {required bool selected, required int? seconds}) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      shape: const StadiumBorder(),
      onSelected: (_) => _select(seconds),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            _kSheetContentPadding, 0, _kSheetContentPadding, _kSheetContentPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child:
                      Text(l10n.breakDurationLabel, style: Theme.of(context).textTheme.titleLarge),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(visualDensity: VisualDensity(vertical: -1)),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.doneBtn),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _pill(l10n.breakDurationDefaultHint, selected: _seconds == null, seconds: null),
                for (final preset in _kPresetSeconds)
                  _pill(l10n.exerciseDurationSec(preset),
                      selected: _seconds == preset, seconds: preset),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Counter(
                value: _seconds ?? widget.defaultSeconds,
                min: SettingsService.minBreakDurationSeconds,
                max: SettingsService.maxBreakDurationSeconds,
                step: SettingsService.breakDurationStepSeconds,
                onChanged: _select,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
