import 'package:flutter/material.dart';
import 'package:count_up/gen/l10n/app_localizations.dart';

class DangerConfirmDialog extends StatelessWidget {
  final String message;
  final String confirmLabel;

  const DangerConfirmDialog({super.key, required this.message, required this.confirmLabel});

  static Future<bool> show(BuildContext context,
      {required String message, required String confirmLabel}) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => DangerConfirmDialog(message: message, confirmLabel: confirmLabel),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Wrap(spacing: 20, crossAxisAlignment: WrapCrossAlignment.center, children: [
        Icon(Icons.error, color: Theme.of(context).colorScheme.error),
        Text(l10n.dangerZoneTitle),
      ]),
      content: Text(message),
      actions: <Widget>[
        TextButton(
            child: Text(
              l10n.cancelBtn,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () => Navigator.pop(context, false)),
        TextButton(
            child: Text(
              confirmLabel,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () => Navigator.pop(context, true)),
      ],
    );
  }
}
