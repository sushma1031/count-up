// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rep_exercise.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RepExerciseAdapter extends TypeAdapter<RepExercise> {
  @override
  final int typeId = 5;

  @override
  RepExercise read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RepExercise(
      fields[0] as String,
      fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, RepExercise obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj._name)
      ..writeByte(1)
      ..write(obj._reps);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RepExerciseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
