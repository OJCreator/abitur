// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'evaluation_date.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EvaluationDateAdapter extends TypeAdapter<EvaluationDate> {
  @override
  final int typeId = 7;

  @override
  EvaluationDate read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EvaluationDate(
      date: fields[2] as DateTime?,
      id: fields[0] as String?,
      note: fields[3] as int?,
      calendarId: fields[4] as String?,
      weight: fields[5] as int?,
      description: fields[6] as String,
    ).._evaluationId = fields[1] as String;
  }

  @override
  void write(BinaryWriter writer, EvaluationDate obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj._evaluationId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.note)
      ..writeByte(4)
      ..write(obj.calendarId)
      ..writeByte(5)
      ..write(obj.weight)
      ..writeByte(6)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EvaluationDateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
