import 'package:flutter/material.dart';
import 'package:count_up/services/timer_audio_service.dart';
import 'package:count_up/widgets/volume_slider.dart';
import 'package:count_up/utils/assets.dart';
import 'package:count_up/gen/l10n/app_localizations.dart';

class VolumeSettings extends StatefulWidget {
  static const double _sliderStep = 0.05;

  final double initial;
  final double min;
  final void Function(double) onChanged;

  const VolumeSettings({
    Key? key,
    required this.initial,
    required this.onChanged,
    this.min = 0.0,
  }) : super(key: key);

  @override
  State<VolumeSettings> createState() => _VolumeSettingsState();
}

class _VolumeSettingsState extends State<VolumeSettings> {
  late double _volume;
  final _previewPlayer = TimerAudioService(Assets.audioExerciseChange);
  bool _configured = false;
  bool _isPreviewing = false;

  @override
  void initState() {
    super.initState();
    _volume = widget.initial.clamp(widget.min, 1.0);
  }

  Future<void> _previewVolume() async {
    if (mounted) setState(() => _isPreviewing = true);

    try {
      if (!_configured) {
        await _previewPlayer.configure();
        _configured = true;
      }

      if (!mounted) return;

      // Stop any preview already in progress so repeated taps prevent playback overlap.
      await _previewPlayer.stop();
      await _previewPlayer.setVolume(_volume);
      await _previewPlayer.play();
    } catch (e) {
      debugPrint('Volume preview audio error: $e');
    } finally {
      if (mounted) {
        setState(() => _isPreviewing = false);
      }
    }
  }

  @override
  void dispose() {
    _previewPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.soundSettingLabel, style: TextStyle(fontSize: 16)),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: VolumeSlider(
                initial: _volume,
                step: VolumeSettings._sliderStep,
                min: widget.min,
                onChanged: (value) {
                  setState(() {
                    _volume = value;
                  });
                  widget.onChanged(value);
                },
              ),
            ),
            IconButton(
              onPressed: _isPreviewing || _volume <= 0 ? null : _previewVolume,
              icon: Icon(_volume <= 0 ? Icons.volume_off : Icons.volume_down),
              iconSize: 20,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ],
    );
  }
}
