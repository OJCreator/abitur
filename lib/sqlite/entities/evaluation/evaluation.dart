import 'package:abitur/isolates/serializer.dart';
import 'package:abitur/utils/uuid.dart';

class Evaluation implements Serializable {

  String id;

  String subjectId; // FOREIGN KEY
  String performanceId; // FOREIGN KEY
  String evaluationTypeId; // FOREIGN KEY

  String name;
  int term;

  Evaluation({
    String? id,
    this.subjectId = "",
    this.performanceId = "",
    this.evaluationTypeId = "",
    required this.name,
    required this.term,
  }) : id = id ?? Uuid.generate();

  static Evaluation empty() {
    return Evaluation(name: "", term: 0);
  }

  @override
  String toString() {
    return "Evaluation#$id (Name: '$name')";
  }

  @override
  Map<String, dynamic> toJson() => {
    "id": id,
    "subjectId": subjectId,
    "performanceId": performanceId,
    "evaluationTypeId": evaluationTypeId,
    "name": name,
    "term": term,
  };

  static Evaluation fromJson(Map<String, dynamic> json) {
    return Evaluation(
      id: json["id"],
      subjectId: json["subjectId"],
      performanceId: json["performanceId"],
      evaluationTypeId: json["evaluationTypeId"],
      name: json["name"],
      term: json["term"],
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is! Evaluation) {
      return false;
    }
    return id == other.id;
  }

  @override
  int get hashCode => "@Evaluation $id".hashCode;
}