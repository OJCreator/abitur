// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timetable.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TimetableAdapter extends TypeAdapter<Timetable> {
  @override
  final int typeId = 4;

  @override
  Timetable read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Timetable(
      monday: (fields[0] as List?)?.cast<String?>(),
      mondayRooms: (fields[1] as List?)?.cast<String?>(),
      tuesday: (fields[2] as List?)?.cast<String?>(),
      tuesdayRooms: (fields[3] as List?)?.cast<String?>(),
      wednesday: (fields[4] as List?)?.cast<String?>(),
      wednesdayRooms: (fields[5] as List?)?.cast<String?>(),
      thursday: (fields[6] as List?)?.cast<String?>(),
      thursdayRooms: (fields[7] as List?)?.cast<String?>(),
      friday: (fields[8] as List?)?.cast<String?>(),
      fridayRooms: (fields[9] as List?)?.cast<String?>(),
    );
  }

  @override
  void write(BinaryWriter writer, Timetable obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.monday)
      ..writeByte(1)
      ..write(obj.mondayRooms)
      ..writeByte(2)
      ..write(obj.tuesday)
      ..writeByte(3)
      ..write(obj.tuesdayRooms)
      ..writeByte(4)
      ..write(obj.wednesday)
      ..writeByte(5)
      ..write(obj.wednesdayRooms)
      ..writeByte(6)
      ..write(obj.thursday)
      ..writeByte(7)
      ..write(obj.thursdayRooms)
      ..writeByte(8)
      ..write(obj.friday)
      ..writeByte(9)
      ..write(obj.fridayRooms);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimetableAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
