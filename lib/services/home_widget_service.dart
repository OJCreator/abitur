// import 'package:home_widget/home_widget.dart';
//
// import 'database/subject_service.dart';
//
// class HomeWidgetService {
//
//   static void init() {
//     updateAverage();
//   }
//
//   static Future<void> updateAverage() async {
//
//     double currentAverage = (await SubjectService.getCurrentAverage()) ?? 15.0;
//     int transmitValue = (currentAverage * 100).round();
//
//     print("Transmit: $transmitValue");
//
//     await HomeWidget.saveWidgetData('abi_percent', transmitValue);
//     await HomeWidget.updateWidget(name: 'AverageWidgetProvider');
//   }
// }