import 'package:count_up/utils/errors.dart';

/// Represents the outcome of a workout import.
///
/// Contains [workoutKey] on success, [error] on failure, or neither
/// if the user cancelled the file selection.
class ImportResult {
  final int? workoutKey;
  final ImportError? error;

  const ImportResult.success(int this.workoutKey) : error = null;
  const ImportResult.failure(ImportError this.error) : workoutKey = null;
  const ImportResult.cancelled()
      : workoutKey = null,
        error = null;
}
