// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'performance.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PerformanceAdapter extends TypeAdapter<Performance> {
  @override
  final int typeId = 1;

  @override
  Performance read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Performance(
      name: fields[0] as String,
      weighting: fields[1] as double,
      id: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Performance obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.weighting)
      ..writeByte(2)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PerformanceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
