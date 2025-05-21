import 'package:abitur/isolates/serializer.dart';
import 'package:hive/hive.dart';

import '../../utils/uuid.dart';

part 'performance.g.dart';

@HiveType(typeId: 1)
class Performance implements Serializable {

  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double weighting;

  Performance({
    required this.name,
    required this.weighting,
    String? id,
  }) : id = id ?? Uuid.generate();

  static Performance empty() {
    return Performance(name: "-", weighting: 0);
  }

  @override
  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "weighting": weighting,
  };

  static Performance fromJson(Map<String, dynamic> json) {
    return Performance(
      id: json["id"],
      name: json["name"],
      weighting: json["weighting"],
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
