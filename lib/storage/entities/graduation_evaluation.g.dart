// // GENERATED CODE - DO NOT MODIFY BY HAND
//
// part of 'graduation_evaluation.dart';
//
// // **************************************************************************
// // TypeAdapterGenerator
// // **************************************************************************
//
// class GraduationEvaluationAdapter extends TypeAdapter<GraduationEvaluation> {
//   @override
//   final int typeId = 9;
//
//   @override
//   GraduationEvaluation read(BinaryReader reader) {
//     final numOfFields = reader.readByte();
//     final fields = <int, dynamic>{
//       for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
//     };
//     return GraduationEvaluation(
//       id: fields[0] as String?,
//     )
//       .._graduationType = fields[1] as String?
//       .._subjectId = fields[2] as String
//       .._evaluationIds = (fields[3] as List).cast<String>();
//   }
//
//   @override
//   void write(BinaryWriter writer, GraduationEvaluation obj) {
//     writer
//       ..writeByte(4)
//       ..writeByte(0)
//       ..write(obj.id)
//       ..writeByte(1)
//       ..write(obj._graduationType)
//       ..writeByte(2)
//       ..write(obj._subjectId)
//       ..writeByte(3)
//       ..write(obj._evaluationIds);
//   }
//
//   @override
//   int get hashCode => typeId.hashCode;
//
//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is GraduationEvaluationAdapter &&
//           runtimeType == other.runtimeType &&
//           typeId == other.typeId;
// }
