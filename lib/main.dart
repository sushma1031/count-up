import 'package:flutter/material.dart';
import 'app.dart';
import 'models/workout.dart';
import 'models/exercise.dart';
import 'services/workout_storage_service.dart';
import 'services/hive_settings_service.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentsDir =
      await path_provider.getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentsDir.path);
  Hive.registerAdapter(DurationExerciseAdapter());
  Hive.registerAdapter(RepExerciseAdapter());
  Hive.registerAdapter(WorkoutAdapter());

  final settings = HiveSettingsService();
  await settings.init();

  runApp(CountUpApp(
    db: WorkoutStorageService('workoutsBox'),
    settings: settings,
  ));
}
