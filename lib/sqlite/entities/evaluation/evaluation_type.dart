import 'package:abitur/isolates/serializer.dart';
import 'package:abitur/utils/uuid.dart';

import '../../../utils/enums/assessment_type.dart';

class EvaluationType implements Serializable {

  String id;

  String name;
  AssessmentType assessmentType;
  bool showInCalendar;

  EvaluationType({
    String? id,
    required this.name,
    this.assessmentType = AssessmentType.other,
    this.showInCalendar = false,
  }) : id = id ?? Uuid.generate();

  static EvaluationType empty() {
    return EvaluationType(name: "Kein Typ", assessmentType: AssessmentType.other);
  }

  @override
  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "assessmentType": assessmentType.code,
    "showInCalendar": showInCalendar ? 1 : 0,
  };

  static EvaluationType fromJson(Map<String, dynamic> json) {
    return EvaluationType(
      id: json["id"],
      name: json["name"],
      assessmentType: AssessmentType.fromCode(json["assessmentType"]),
      showInCalendar: json["showInCalendar"] == 1,
    );
  }
}
