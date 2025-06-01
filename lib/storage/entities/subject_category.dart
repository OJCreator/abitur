import 'package:abitur/isolates/serializer.dart';
import 'package:abitur/utils/uuid.dart';
import 'package:hive/hive.dart';

part 'subject_category.g.dart';

@HiveType(typeId: 9)
class SubjectCategory implements Serializable {

  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int minGradesRequired;

  SubjectCategory({
    required this.name,
    required this.minGradesRequired,
    String? id,
  }) : id = id ?? Uuid.generate();

  static SubjectCategory empty() {
    return SubjectCategory(name: "Kein Typ", minGradesRequired: 0);
  }

  @override
  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "minGradesRequired": minGradesRequired,
  };

  static SubjectCategory fromJson(Map<String, dynamic> json) {
    return SubjectCategory(
      id: json["id"],
      name: json["name"],
      minGradesRequired: json["minGradesRequired"],
    );
  }
}