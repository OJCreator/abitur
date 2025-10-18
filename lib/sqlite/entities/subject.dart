import 'dart:convert';
import 'dart:ui';

import 'package:abitur/isolates/serializer.dart';
import 'package:abitur/utils/constants.dart';

import '../../utils/enums/subject_niveau.dart';
import '../../utils/enums/subject_type.dart';
import '../../utils/uuid.dart';


class Subject implements Serializable {

  String id;
  String name;
  String shortName;

  Color color;

  SubjectNiveau subjectNiveau;
  SubjectType subjectType;

  Set<int> terms;
  int countingTermAmount;
  List<int?> manuallyEnteredTermNotes;

  String? graduationEvaluationId; // FOREIGN KEY

  Subject({
    String? id,
    required this.name,
    required this.shortName,
    this.color = primaryColor,
    this.subjectNiveau = SubjectNiveau.basic,
    this.subjectType = SubjectType.standardPflichtfach,
    this.terms = const {0,1,2,3},
    required this.countingTermAmount,
    this.manuallyEnteredTermNotes = const [null, null, null, null],
    this.graduationEvaluationId,
  }) : id = id ?? Uuid.generate();

  static Subject empty() {
    return Subject(name: "-", shortName: "", countingTermAmount: 0);
  }

  @override
  String toString() {
    return "Subject#$id (Name: '$name', Type: '${subjectType.name}')";
  }

  @override
  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "shortName": shortName,
    "color": color.toARGB32(),
    "subjectNiveau": subjectNiveau.code,
    "subjectType": subjectType.code,
    "terms": jsonEncode(terms.toList()),
    "countingTermAmount": countingTermAmount,
    "manuallyEnteredTermNotes": jsonEncode(manuallyEnteredTermNotes),
    "graduationEvaluationId": graduationEvaluationId,
  };

  static Subject fromJson(Map<String, dynamic> json) {
    return Subject(
        id: json["id"],
        name: json["name"],
        shortName: json["shortName"],
        color: Color(json["color"]),
        subjectNiveau: SubjectNiveau.fromCode(json["subjectNiveau"]),
        subjectType: SubjectType.fromCode(json["subjectType"]),
        terms: Set<int>.from(jsonDecode(json["terms"]) as List),
        countingTermAmount: json["countingTermAmount"] as int,
        manuallyEnteredTermNotes: List<int?>.from(jsonDecode(json["manuallyEnteredTermNotes"])),
        graduationEvaluationId: json["graduationEvaluationId"]
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is! Subject) {
      return false;
    }
    return id == other.id;
  }

  @override
  int get hashCode => "@Subject $id".hashCode;
}