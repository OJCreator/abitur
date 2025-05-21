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
  bool showInCalendar;

  EvaluationType({
    required this.name,
    this.showInCalendar = false,
    String? id,
  }) : id = id ?? Uuid.generate();

  static EvaluationType empty() {
    return EvaluationType(name: "Kein Typ");
  }

  @override
  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "showInCalendar": showInCalendar,
  };

  static EvaluationType fromJson(Map<String, dynamic> json) {
    return EvaluationType(
      id: json["id"],
      name: json["name"],
      showInCalendar: json["showInCalendar"],
    );
  }
}