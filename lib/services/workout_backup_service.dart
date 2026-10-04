import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:count_up/models/exercise.dart';
import 'package:count_up/models/workout.dart';
import 'package:count_up/models/import_result.dart';
import 'package:count_up/utils/errors.dart';
import 'package:count_up/utils/format.dart';
import 'package:count_up/utils/workout_serialisation.dart';
import 'package:count_up/utils/workout_constants.dart';
import 'storage_service.dart';

class WorkoutBackupService {
  final StorageService db;

  WorkoutBackupService(this.db);

  Future<ImportResult> importWorkout() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null) {
      return const ImportResult.cancelled();
    }
    File file = File(result.files.single.path!);
    String workoutJson = await file.readAsString();
    return importWorkoutJson(workoutJson);
  }

  Future<ImportResult> importWorkoutJson(String workoutJson) async {
    try {
      var workout = importFromJson(workoutJson);
      if (workout.exercises.length > maxExercisesPerWorkout) {
        return const ImportResult.failure(ImportError.exerciseLimit);
      }
      workout.name =
          getUniqueWorkoutName(db.getAllWorkoutNames(), workout.name);
      return ImportResult.success(await db.addWorkout(workout));
    } on UnknownExerciseTypeException catch (e) {
      print('Unknown exercise type: $e');
      return ImportResult.unknownExerciseType(e.type);
    } on FormatException catch (e) {
      print('Invalid JSON: $e');
      return const ImportResult.failure(ImportError.format);
    } on TypeError catch (e) {
      print('Type error: $e');
      return const ImportResult.failure(ImportError.type);
    } catch (e) {
      print('Unexpected error: $e');
      return const ImportResult.failure(ImportError.unknown);
    }
  }

  Future<ExportError?> exportWorkout(Workout workout) async {
    if (workout.exercises.isEmpty) return ExportError.empty;
    try {
      final workoutJson = exportJson(workout);
      final backupFileName = generateBackupFilename(workout.name);
      final tempDir = await getTemporaryDirectory();

      final file = File('${tempDir.path}/$backupFileName.json');
      await file.writeAsString(workoutJson);

      await Share.shareXFiles([XFile(file.path)]);
      return null;
    } on FileSystemException catch (e) {
      print('File system error: $e');
      return ExportError.fs;
    } on PlatformException catch (e) {
      print('Platform share error: $e');
      return ExportError.platform;
    } on Exception catch (e) {
      print('Unexpected error: $e');
      return ExportError.unknown;
    }
  }

  Future<ExportError?> exportAllWorkouts() async {
    final workouts = db.getAllWorkouts();
    if (workouts.isEmpty) return ExportError.empty;

    Directory tempDir;
    try {
      tempDir = await getApplicationDocumentsDirectory();
    } on MissingPlatformDirectoryException catch (e) {
      print('Could not access temporary directory: $e');
      return ExportError.platform;
    }

    final zipData = buildWorkoutsZipBytes(workouts);
    try {
      final file = File('${tempDir.path}/${generateBackupFilename("count-up")}.zip');
      await file.writeAsBytes(zipData);
      await Share.shareXFiles([XFile(file.path, mimeType: 'application/zip')]);
      await file.delete();
      return null;
    } on FileSystemException catch (e) {
      print('File system error: $e');
      return ExportError.fs;
    } on PlatformException catch (e) {
      print('Platform share error: $e');
      return ExportError.platform;
    } on Exception catch (e) {
      print('Unexpected error: $e');
      return ExportError.unknown;
    }
  }
}
