enum ImportError { format, type, exerciseLimit, unknown }

/// Outcome of a workout import.
sealed class ImportResult {
  const ImportResult();
}

final class ImportSuccess extends ImportResult {
  final int workoutKey;
  const ImportSuccess(this.workoutKey);
}

final class ImportCancelled extends ImportResult {
  const ImportCancelled();
}

final class ImportFailure extends ImportResult {
  final ImportError error;
  const ImportFailure(this.error);
}

final class ImportUnknownExerciseType extends ImportResult {
  final String type;
  const ImportUnknownExerciseType(this.type);
}
