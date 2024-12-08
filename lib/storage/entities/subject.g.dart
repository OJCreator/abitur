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
      name: fields[0] as String,
      shortName: fields[1] as String,
      id: fields[6] as String?,
    )
      .._color = fields[2] as int
      .._subjectType = fields[3] as String
      .._terms = (fields[4] as List).cast<int>()
      .._performanceIds = (fields[5] as List).cast<String>();
  }

  @override
  void write(BinaryWriter writer, Subject obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.shortName)
      ..writeByte(2)
      ..write(obj._color)
      ..writeByte(3)
      ..write(obj._subjectType)
      ..writeByte(4)
      ..write(obj._terms)
      ..writeByte(5)
      ..write(obj._performanceIds)
      ..writeByte(6)
      ..write(obj.id);
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
