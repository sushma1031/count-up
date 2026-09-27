import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:count_up/models/workout.dart';
import 'package:count_up/utils/errors.dart';
import 'package:count_up/utils/format.dart';
import 'package:count_up/utils/serialise_workout.dart';
import 'package:count_up/utils/workout_constants.dart';
import 'storage_service.dart';

class WorkoutBackupService {
  final StorageService db;

  WorkoutBackupService(this.db);

  Future<ImportError?> importWorkout() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null) {
      return null;
    }
    File file = File(result.files.single.path!);
    String workoutJson = await file.readAsString();
    return importWorkoutJson(workoutJson);
  }

  Future<ImportError?> importWorkoutJson(String workoutJson) async {
    try {
      var workout = importFromJson(workoutJson);
      if (workout.exercises.length > maxExercisesPerWorkout) {
        return ImportError.exerciseLimit;
      }
      workout.name =
          getUniqueWorkoutName(db.getAllWorkoutNames(), workout.name);
      await db.addWorkout(workout);
      return null;
    } on FormatException catch (e) {
      print('Invalid JSON: $e');
      return ImportError.format;
    } on TypeError catch (e) {
      print('Type error: $e');
      return ImportError.type;
    } catch (e) {
      print('Unexpected error: $e');
      return ImportError.unknown;
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

    final archive = Archive();
    for (var w in workouts) {
      final workoutJson = exportJson(w);
      final backupFileName = generateBackupFilename(w.name, withDate: false);
      final archiveFile = ArchiveFile.string('$backupFileName.json', workoutJson);
      archive.addFile(archiveFile);
    }
    try {
      final zipData = ZipEncoder().encodeBytes(archive);
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
