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
                  child: Text(l10n.stayBtn),
                  onPressed: () => Navigator.of(context).pop(false)),
              TextButton(
                  child: Text(l10n.exitBtn),
                  onPressed: () => Navigator.of(context).pop(true)),
            ],
          );
        },
      ) ??
      false;
}
