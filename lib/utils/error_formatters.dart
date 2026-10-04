import 'package:flutter/widgets.dart';
import 'package:count_up/gen/l10n/app_localizations.dart';
import 'package:count_up/utils/errors.dart';
import 'package:count_up/models/import_result.dart';
import 'package:count_up/utils/workout_constants.dart';

String errorMessageFor(BuildContext context, AppError error) {
  final l10n = AppLocalizations.of(context);
  switch (error) {
    case AppError.dbInitFailed:
      return l10n.dbInitFailedError;
    case AppError.unknown:
      return l10n.unknownError;
  }
}

/// Returns a localized error message corresponding to the failure in [result].
///
/// Requires [ImportResult.error] to be non-null.
String importErrorMessage(BuildContext context, ImportResult result) {
  final l10n = AppLocalizations.of(context);
  switch (result.error!) {
    case ImportError.format:
      return l10n.importErrorFormat;
    case ImportError.type:
      return l10n.importErrorType;
    case ImportError.unknownExerciseType:
      return l10n.importErrorUnknownExerciseType(result.unknownExerciseType!);
    case ImportError.exerciseLimit:
      return l10n.workoutExerciseLimitError(maxExercisesPerWorkout);
    case ImportError.unknown:
      return l10n.importErrorUnknown;
  }
}

String exportErrorMessage(BuildContext context, ExportError error) {
  final l10n = AppLocalizations.of(context);
  switch (error) {
    case ExportError.empty:
      return l10n.exportErrorEmpty;
    case ExportError.fs:
      return l10n.exportErrorFS;
    case ExportError.platform:
      return l10n.exportErrorPlatform;
    case ExportError.unknown:
      return l10n.exportErrorUnknown;
  }
}
