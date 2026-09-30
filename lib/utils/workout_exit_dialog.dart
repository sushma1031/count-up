import 'package:flutter/material.dart';
import 'package:count_up/gen/l10n/app_localizations.dart';

Future<bool> showExitWorkoutDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(l10n.workoutIncompleteTitle),
            content: Text(l10n.exitWorkoutConfirm),
            actions: <Widget>[
              TextButton(
                  child: Text(l10n.yesBtn),
                  onPressed: () => Navigator.of(context).pop(true)),
              TextButton(
                  child: Text(l10n.noBtn),
                  onPressed: () => Navigator.of(context).pop(false)),
            ],
            elevation: 20,
          );
        },
      ) ??
      false;
}
