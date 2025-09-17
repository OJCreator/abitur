// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubjectAdapter extends TypeAdapter<Subject> {
  @override
  final int typeId = 2;

  @override
  Subject read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Subject(
      name: fields[1] as String,
      shortName: fields[2] as String,
      manuallyEnteredTermNotes: (fields[8] as List).cast<int?>(),
      countingTermAmount: fields[7] as int,
      id: fields[0] as String?,
    )
      .._color = fields[3] as int
      .._subjectNiveau = fields[4] as String
      .._subjectType = fields[5] as String
      .._terms = (fields[6] as List).cast<int>()
      .._performanceIds = (fields[9] as List).cast<String>()
      .._graduationEvaluationId = fields[10] as String?;
  }

  @override
  void write(BinaryWriter writer, Subject obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.shortName)
      ..writeByte(3)
      ..write(obj._color)
      ..writeByte(4)
      ..write(obj._subjectNiveau)
      ..writeByte(5)
      ..write(obj._subjectType)
      ..writeByte(6)
      ..write(obj._terms)
      ..writeByte(7)
      ..write(obj.countingTermAmount)
      ..writeByte(8)
      ..write(obj.manuallyEnteredTermNotes)
      ..writeByte(9)
      ..write(obj._performanceIds)
      ..writeByte(10)
      ..write(obj._graduationEvaluationId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
