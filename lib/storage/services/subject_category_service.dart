// import 'package:abitur/storage/entities/subject_category.dart';
// import 'package:abitur/storage/services/subject_service.dart';
// import 'package:abitur/storage/storage.dart';
//
// class SubjectCategoryService {
//
//   static List<SubjectCategory> findAll() {
//     return Storage.loadSubjectCategories();
//   }
//   static SubjectCategory? findById(String subjectCategoryId) {
//     return Storage.loadSubjectCategory(subjectCategoryId);
//   }
//
//   static Future<SubjectCategory> newSubjectCategory(String name, int minGradesRequired) async {
//
//     SubjectCategory newSubjectCategory = SubjectCategory(
//       name: name,
//       minGradesRequired: minGradesRequired,
//     );
//     await Storage.saveSubjectCategory(newSubjectCategory);
//     return newSubjectCategory;
//   }
//
//   static Future<void> editSubjectCategory(SubjectCategory subjectCategory, {String? name, int? minGradesRequired}) async {
//     name ??= subjectCategory.name;
//     minGradesRequired ??= subjectCategory.minGradesRequired;
//     await Storage.saveSubjectCategory(subjectCategory);
//   }
//
//   static Future<void> deleteSubjectCategory(SubjectCategory subjectCategory) async {
//     if (SubjectService.findAll().any((it) => it.subjectCategoryId == subjectCategory.id)) {
//       return;
//     }
//     await Storage.deleteSubjectCategory(subjectCategory);
//   }
//
//   static Future<void> deleteAllSubjectCategories(List<SubjectCategory> subjectCategories) async {
//     for (var s in subjectCategories) {
//       deleteSubjectCategory(s);
//     }
//   }
//
//   static Future<void> buildFromJson(List<Map<String, dynamic>> jsonData) async {
//     deleteAllSubjectCategories(findAll());
//     List<SubjectCategory> subjectCategories = jsonData.map((e) => SubjectCategory.fromJson(e)).toList();
//     for (SubjectCategory s in subjectCategories) {
//       await Storage.saveSubjectCategory(s);
//     }
//   }
// }