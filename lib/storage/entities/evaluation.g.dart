// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'evaluation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EvaluationAdapter extends TypeAdapter<Evaluation> {
  @override
  final int typeId = 0;

  @override
  Evaluation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Evaluation(
      term: fields[2] as int,
      name: fields[3] as String,
      id: fields[4] as String?,
    )
      .._subjectId = fields[0] as String
      .._performanceId = fields[1] as String
      .._evaluationDateIds = (fields[5] as List).cast<String>()
      .._evaluationTypeId = fields[6] as String;
  }

  @override
  void write(BinaryWriter writer, Evaluation obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj._subjectId)
      ..writeByte(1)
      ..write(obj._performanceId)
      ..writeByte(2)
      ..write(obj.term)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.id)
      ..writeByte(5)
      ..write(obj._evaluationDateIds)
      ..writeByte(6)
      ..write(obj._evaluationTypeId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EvaluationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
