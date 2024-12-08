import 'package:hive/hive.dart';

import '../../utils/uuid.dart';

part 'performance.g.dart';

@HiveType(typeId: 1)
class Performance {

  @HiveField(0)
  String name;

  @HiveField(1)
  double weighting;

  @HiveField(2)
  String id;

  Performance({
    required this.name,
    required this.weighting,
    String? id,
  }) : id = id ?? Uuid.generate();

  Map<String, dynamic> toJson() => {
    "name": name,
    "weighting": weighting,
    "id": id,
  };

  static Performance fromJson(Map<String, dynamic> json) {
    return Performance(
      name: json["name"],
      weighting: json["weighting"],
      id: json["id"],
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
