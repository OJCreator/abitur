// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject_category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubjectCategoryAdapter extends TypeAdapter<SubjectCategory> {
  @override
  final int typeId = 9;

  @override
  SubjectCategory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubjectCategory(
      name: fields[1] as String,
      minGradesRequired: fields[2] as int,
      id: fields[0] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SubjectCategory obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.minGradesRequired);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubjectCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
