// // GENERATED CODE - DO NOT MODIFY BY HAND
//
// part of 'timetable_settings.dart';
//
// // **************************************************************************
// // TypeAdapterGenerator
// // **************************************************************************
//
// class TimetableSettingsAdapter extends TypeAdapter<TimetableSettings> {
//   @override
//   final int typeId = 4;
//
//   @override
//   TimetableSettings read(BinaryReader reader) {
//     final numOfFields = reader.readByte();
//     final fields = <int, dynamic>{
//       for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
//     };
//     return TimetableSettings(
//       timetables: (fields[0] as List?)?.cast<String>(),
//       times: (fields[1] as List?)?.cast<String>(),
//     );
//   }
//
//   @override
//   void write(BinaryWriter writer, TimetableSettings obj) {
//     writer
//       ..writeByte(2)
//       ..writeByte(0)
//       ..write(obj.timetables)
//       ..writeByte(1)
//       ..write(obj.times);
//   }
//
//   @override
//   int get hashCode => typeId.hashCode;
//
//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is TimetableSettingsAdapter &&
//           runtimeType == other.runtimeType &&
//           typeId == other.typeId;
// }
