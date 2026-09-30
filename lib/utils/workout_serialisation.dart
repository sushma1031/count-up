import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:count_up/models/workout.dart';
import 'format.dart';

String exportJson(Workout workout) {
  final workoutJson = JsonEncoder.withIndent('  ').convert(workout);
  return workoutJson;
}

Workout importFromJson(String json) {
  Map<String, dynamic> workoutMap = jsonDecode(json);
  Workout workout = Workout.fromJson(workoutMap);
  return workout;
}

List<int> buildWorkoutsZipBytes(List<Workout> workouts) {
  final archive = Archive();
  for (final workout in workouts) {
    final workoutJson = exportJson(workout);
    final backupFileName =
        generateBackupFilename(workout.name, withDate: false);
    archive.addFile(ArchiveFile.string('$backupFileName.json', workoutJson));
  }
  return ZipEncoder().encodeBytes(archive);
}
