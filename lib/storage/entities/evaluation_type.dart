import 'package:abitur/isolates/serializer.dart';
import 'package:abitur/utils/uuid.dart';
import 'package:hive/hive.dart';

part 'evaluation_type.g.dart';

@HiveType(typeId: 8)
class EvaluationType implements Serializable {

  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String _assessmentType;
  AssessmentType get assessmentType => AssessmentType.fromCode(_assessmentType);
  set assessmentType(AssessmentType newAssessmentType) => _assessmentType = newAssessmentType.code;

  @HiveField(3)
  bool showInCalendar;

  EvaluationType({
    required this.name,
    AssessmentType assessmentType = AssessmentType.other,
    this.showInCalendar = false,
    String? id,
  }) : id = id ?? Uuid.generate(),
        _assessmentType = assessmentType.code;

  static EvaluationType empty() {
    return EvaluationType(name: "Kein Typ", assessmentType: AssessmentType.other);
  }

  @override
  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "assessmentType": assessmentType.code,
    "showInCalendar": showInCalendar,
  };

  static EvaluationType fromJson(Map<String, dynamic> json) {
    return EvaluationType(
      id: json["id"],
      name: json["name"],
      assessmentType: AssessmentType.fromCode(json["assessmentType"]),
      showInCalendar: json["showInCalendar"],
    );
  }
}

enum AssessmentType {
  oral("Mündlich"),
  written("Schriftlich"),
  other("Sonstiges");

  final String name;

  String get code {
    switch (this) {
      case AssessmentType.oral:
        return "oral";
      case AssessmentType.written:
        return "written";
      case AssessmentType.other:
        return "other";
    }
  }

  const AssessmentType(this.name);

  static AssessmentType fromCode(String code) {
    switch (code) {
      case "oral":
        return AssessmentType.oral;
      case "written":
        return AssessmentType.written;
      default:
        return AssessmentType.other;
    }
  }
}