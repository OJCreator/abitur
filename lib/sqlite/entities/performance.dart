import 'package:abitur/isolates/serializer.dart';

import '../../utils/uuid.dart';

class Performance implements Serializable {

  String id;
  String name;
  double weighting;
  String subjectId; // FOREIGN KEY

  Performance({
    String? id,
    required this.name,
    required this.weighting,
    required this.subjectId,
  }) : id = id ?? Uuid.generate();

  static Performance empty() {
    return Performance(name: "-", weighting: 0, subjectId: "");
  }

  @override
  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "weighting": weighting,
    "subjectId": subjectId,
  };

  static Performance fromJson(Map<String, dynamic> json) {
    return Performance(
      id: json["id"],
      name: json["name"],
      weighting: json["weighting"],
      subjectId: json["subjectId"],
    );
  }

  @override
  String toString() {
    return "(Performance '$name')";
  }

  @override
  bool operator ==(Object other) {
    if (other is! Performance) {
      return false;
    }
    return id == other.id;
  }

  @override
  int get hashCode => "@Performance $id".hashCode;
}
