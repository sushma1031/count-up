enum ImportError { format, type, unknownExerciseType, exerciseLimit, unknown }

/// Represents the outcome of a workout import.
///
/// Contains [workoutKey] on success, [error] on failure, or neither
/// if the user cancelled the file selection. [unknownExerciseType] is set
/// only when [error] is [ImportError.unknownExerciseType].
///
/// TODO: Migrate to Dart 3 [Result] class.
class ImportResult {
  final int? workoutKey;
  final ImportError? error;
  final String? unknownExerciseType;

  const ImportResult.success(int this.workoutKey)
      : error = null,
        unknownExerciseType = null;
  const ImportResult.failure(ImportError this.error)
      : workoutKey = null,
        unknownExerciseType = null;
  const ImportResult.unknownExerciseType(String this.unknownExerciseType)
      : error = ImportError.unknownExerciseType,
        workoutKey = null;
  const ImportResult.cancelled()
      : workoutKey = null,
        error = null,
        unknownExerciseType = null;
}
