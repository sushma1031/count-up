// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'duration_exercise.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DurationExerciseAdapter extends TypeAdapter<DurationExercise> {
  @override
  final int typeId = 1;

  @override
  DurationExercise read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DurationExercise(
      fields[0] as String,
      fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, DurationExercise obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj._name)
      ..writeByte(1)
      ..write(obj._duration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DurationExerciseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
