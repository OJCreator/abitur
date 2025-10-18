//
//
// import 'package:abitur/storage/entities/evaluation.dart';
// import 'package:abitur/storage/entities/performance.dart';
// import 'package:abitur/storage/services/evaluation_service.dart';
// import 'package:abitur/storage/storage.dart';
//
// import '../../services/database/evaluation_service.dart';
//
// class PerformanceService {
//   static List<Performance> findAll() {
//     return Storage.loadPerformances();
//   }
//   static Performance? findById(String id) {
//     return Storage.loadPerformance(id);
//   }
//
//   static Future<Performance> newPerformance(String name, double weighting) async {
//     Performance p = Performance(name: name, weighting: weighting);
//     await Storage.savePerformance(p);
//     return p;
//   }
//
//   static Future<void> savePerformances(List<Performance> performances) async {
//     for (Performance p in performances) {
//       await Storage.savePerformance(p);
//     }
//   }
//
//   static Future<void> deletePerformances(List<Performance> performances) async {
//     for (Performance p in performances) {
//       await deletePerformance(p);
//     }
//   }
//
//   static Future<void> deletePerformance(Performance performance) async {
//     List<Evaluation> evaluationsToDelete = await EvaluationService.findAllByPerformance(performance);
//     await EvaluationService.deleteAllEvaluations(evaluationsToDelete);
//     await Storage.deletePerformance(performance);
//   }
//
//   static Future<void> buildFromJson(List<Map<String, dynamic>> jsonData) async {
//
//     await deletePerformances(findAll());
//
//     List<Performance> performances = jsonData.map((e) => Performance.fromJson(e)).toList();
//     await savePerformances(performances);
//   }
// }