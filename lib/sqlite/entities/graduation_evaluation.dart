import 'package:abitur/isolates/serializer.dart';
import 'package:abitur/utils/uuid.dart';

import '../../utils/enums/graduation_evaluation_type.dart';


class GraduationEvaluation implements Serializable {

  String id;
  String subjectId; // FOREIGN KEY

  GraduationEvaluationType graduationEvaluationType;
  bool isDividedEvaluation;

  int? notePartOne;
  DateTime? datePartOne;
  int weightPartOne;

  int? notePartTwo;
  DateTime? datePartTwo;
  int weightPartTwo;

  GraduationEvaluation({
    String? id,
    this.subjectId = "",
    this.graduationEvaluationType = GraduationEvaluationType.written,
    this.isDividedEvaluation = false,
    this.notePartOne,
    this.datePartOne,
    this.weightPartOne = 1,
    this.notePartTwo,
    this.datePartTwo,
    this.weightPartTwo = 1,
  }) : id = id ?? Uuid.generate();


  static GraduationEvaluation empty() {
    return GraduationEvaluation();
  }

  @override
  Map<String, dynamic> toJson() => {
    "id": id,
    "subjectId": subjectId,
    "graduationEvaluationType": graduationEvaluationType.code,
    "isDividedEvaluation": isDividedEvaluation ? 1 : 0,
    "notePartOne": notePartOne,
    "datePartOne": datePartOne?.toIso8601String(),
    "weightPartOne": weightPartOne,
    "notePartTwo": notePartTwo,
    "datePartTwo": datePartTwo?.toIso8601String(),
    "weightPartTwo": weightPartTwo,
  };

  static GraduationEvaluation fromJson(Map<String, dynamic> json) {
    print(json);
    return GraduationEvaluation(
      id: json["id"],
      subjectId: json["subjectId"],
      graduationEvaluationType: GraduationEvaluationType.fromCode(json["graduationEvaluationType"]),
      isDividedEvaluation: json["isDividedEvaluation"] == 1,
      notePartOne: json["notePartOne"],
      datePartOne: json["datePartOne"] != null ? DateTime.parse(json["datePartOne"]) : null,
      weightPartOne: json["weightPartOne"],
      notePartTwo: json["notePartTwo"],
      datePartTwo: json["datePartTwo"] != null ? DateTime.parse(json["datePartTwo"]) : null,
      weightPartTwo: json["weightPartTwo"],
    );
  }
}
