// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'graduation_evaluation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GraduationEvaluationAdapter extends TypeAdapter<GraduationEvaluation> {
  @override
  final int typeId = 10;

  @override
  GraduationEvaluation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GraduationEvaluation(
      id: fields[0] as String?,
      isDividedEvaluation: fields[3] as bool,
      notePartOne: fields[4] as int?,
      datePartOne: fields[5] as DateTime?,
      weightPartOne: fields[6] as int,
      notePartTwo: fields[7] as int?,
      datePartTwo: fields[8] as DateTime?,
      weightPartTwo: fields[9] as int,
    )
      .._subjectId = fields[1] as String
      .._graduationEvaluationType = fields[2] as String;
  }

  @override
  void write(BinaryWriter writer, GraduationEvaluation obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj._subjectId)
      ..writeByte(2)
      ..write(obj._graduationEvaluationType)
      ..writeByte(3)
      ..write(obj.isDividedEvaluation)
      ..writeByte(4)
      ..write(obj.notePartOne)
      ..writeByte(5)
      ..write(obj.datePartOne)
      ..writeByte(6)
      ..write(obj.weightPartOne)
      ..writeByte(7)
      ..write(obj.notePartTwo)
      ..writeByte(8)
      ..write(obj.datePartTwo)
      ..writeByte(9)
      ..write(obj.weightPartTwo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GraduationEvaluationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
