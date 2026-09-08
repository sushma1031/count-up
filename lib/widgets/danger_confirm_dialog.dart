import 'package:flutter/material.dart';
import 'package:count_up/gen/l10n/app_localizations.dart';

class DangerConfirmDialog extends StatelessWidget {
  final String message;

  const DangerConfirmDialog({Key? key, required this.message}) : super(key: key);

  static Future<bool> show(BuildContext context, {required String message}) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => DangerConfirmDialog(message: message),
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
              l10n.yesBtn,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () => Navigator.pop(context, true)),
        TextButton(
            child: Text(
              l10n.noBtn,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () => Navigator.pop(context, false)),
      ],
      elevation: 24,
    );
  }
}
