import 'package:flutter/widgets.dart';
import 'package:count_up/gen/l10n/app_localizations.dart';
import 'package:count_up/utils/errors.dart';
import 'package:count_up/models/import_result.dart';
import 'package:count_up/utils/workout_constants.dart';

String errorMessageFor(BuildContext context, AppError error) {
  final l10n = AppLocalizations.of(context);
  return switch (error) {
    AppError.dbInitFailed => l10n.dbInitFailedError,
    AppError.unknown => l10n.unknownError,
  };
}

String importErrorMessage(BuildContext context, ImportError error) {
  final l10n = AppLocalizations.of(context);
  return switch (error) {
    ImportError.format => l10n.importErrorFormat,
    ImportError.type => l10n.importErrorType,
    ImportError.exerciseLimit => l10n.workoutExerciseLimitError(maxExercisesPerWorkout),
    ImportError.unknown => l10n.importErrorUnknown,
  };
}

String exportErrorMessage(BuildContext context, ExportError error) {
  final l10n = AppLocalizations.of(context);
  return switch (error) {
    ExportError.empty => l10n.exportErrorEmpty,
    ExportError.fs => l10n.exportErrorFS,
    ExportError.platform => l10n.exportErrorPlatform,
    ExportError.unknown => l10n.exportErrorUnknown,
  };
}
