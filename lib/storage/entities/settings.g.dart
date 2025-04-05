// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsAdapter extends TypeAdapter<Settings> {
  @override
  final int typeId = 3;

  @override
  Settings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Settings(
      graduationYear: fields[0] as DateTime,
      lightMode: fields[1] as bool,
      viewedWelcomeScreen: fields[4] as bool,
      calendarSynchronisation: fields[5] as bool,
      calendarFullDayEvents: fields[6] as bool,
    )
      .._accentColor = fields[2] as int
      .._land = fields[3] as String;
  }

  @override
  void write(BinaryWriter writer, Settings obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.graduationYear)
      ..writeByte(1)
      ..write(obj.lightMode)
      ..writeByte(2)
      ..write(obj._accentColor)
      ..writeByte(3)
      ..write(obj._land)
      ..writeByte(4)
      ..write(obj.viewedWelcomeScreen)
      ..writeByte(5)
      ..write(obj.calendarSynchronisation)
      ..writeByte(6)
      ..write(obj.calendarFullDayEvents);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
