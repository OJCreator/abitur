// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'evaluation_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EvaluationTypeAdapter extends TypeAdapter<EvaluationType> {
  @override
  final int typeId = 8;

  @override
  EvaluationType read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EvaluationType(
      name: fields[1] as String,
      showInCalendar: fields[2] as bool,
      id: fields[0] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, EvaluationType obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.showInCalendar);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EvaluationTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
