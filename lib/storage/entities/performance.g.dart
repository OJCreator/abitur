// // GENERATED CODE - DO NOT MODIFY BY HAND
//
// part of 'performance.dart';
//
// // **************************************************************************
// // TypeAdapterGenerator
// // **************************************************************************
//
// class PerformanceAdapter extends TypeAdapter<Performance> {
//   @override
//   final int typeId = 1;
//
//   @override
//   Performance read(BinaryReader reader) {
//     final numOfFields = reader.readByte();
//     final fields = <int, dynamic>{
//       for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
//     };
//     return Performance(
//       name: fields[1] as String,
//       weighting: fields[2] as double,
//       id: fields[0] as String?,
//     );
//   }
//
//   @override
//   void write(BinaryWriter writer, Performance obj) {
//     writer
//       ..writeByte(3)
//       ..writeByte(0)
//       ..write(obj.id)
//       ..writeByte(1)
//       ..write(obj.name)
//       ..writeByte(2)
//       ..write(obj.weighting);
//   }
//
//   @override
//   int get hashCode => typeId.hashCode;
//
//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is PerformanceAdapter &&
//           runtimeType == other.runtimeType &&
//           typeId == other.typeId;
// }
