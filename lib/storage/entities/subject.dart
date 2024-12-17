import 'dart:ui';

import 'package:abitur/storage/entities/performance.dart';
import 'package:abitur/storage/services/performance_service.dart';
import 'package:abitur/utils/constants.dart';
import 'package:hive/hive.dart';

import '../../utils/uuid.dart';

part 'subject.g.dart';

@HiveType(typeId: 2)
class Subject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String shortName;

  @HiveField(2)
  int _color;
  set color(Color newColor) => _color = newColor.value;
  Color get color => Color(_color);

  @HiveField(3)
  String _subjectType;
  SubjectType get subjectType => SubjectType.fromCode(_subjectType);
  set subjectType(SubjectType newSubjectType) => _subjectType = newSubjectType.code;

  @HiveField(4)
  List<int> _terms;

  Set<int> get terms => _terms.toSet();
  set terms(Set<int> newTerms) {
    _terms = newTerms.toList();
    _terms.sort((a,b) => a.compareTo(b));
  }

  @HiveField(5)
  int countingTermAmount;

  @HiveField(6)
  List<String> _performanceIds;
  set performances(List<Performance> newPerformances) => _performanceIds = newPerformances.map((p) => p.id).toList();
  List<Performance> get performances => _performanceIds.map((p) => PerformanceService.findById(p)!).toList();

  @HiveField(7)
  String id;

  Subject({
    required this.name,
    required this.shortName,
    Color color = primaryColor,
    SubjectType subjectType = SubjectType.basic,
    Set<int>? terms,
    required this.countingTermAmount,
    List<String> performanceIds = const [],
    String? id,
  }) : _color = color.value,
        id = id ?? Uuid.generate(),
        _subjectType = subjectType.code,
        _terms = terms?.toList() ?? [0,1,2,3],
        _performanceIds = performanceIds;

  @override
  String toString() {
    return "Subject#$id (Name: '$name', Type: '${subjectType.name}')";
  }

  Map<String, dynamic> toJson() => {
    "name": name,
    "shortName": shortName,
    "color": _color,
    "subjectType": _subjectType,
    "terms": _terms,
    "countingTermAmount": countingTermAmount,
    "performanceIds": _performanceIds,
    "id": id,
  };

  static Subject fromJson(Map<String, dynamic> json) {
    return Subject(
      name: json["name"],
      shortName: json["shortName"],
      color: Color(json["color"]),
      subjectType: SubjectType.fromCode(json["subjectType"]),
      terms: (json["terms"] as List).map((e) => e as int).toSet(),
      countingTermAmount: json["countingTermAmount"] as int,
      performanceIds: (json["performanceIds"] as List).map((e) => e as String).toList(),
      id: json["id"],
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

enum SubjectType {
  basic("Grundlegendes Anforderungsniveau"),
  advanced("Erhöhtes Anforderungsniveau"),
  profile("Profilfach"),
  voluntary("Wahlfach");

  final String name;
  String get code {
    switch (this) {
      case SubjectType.basic:
        return "basic";
      case SubjectType.advanced:
        return "advanced";
      case SubjectType.profile:
        return "profile";
      case SubjectType.voluntary:
        return "voluntary";
    }
  }

  const SubjectType(this.name);

  static SubjectType fromCode(String code) {
    switch (code) {
      case "basic":
        return SubjectType.basic;
      case "advanced":
        return SubjectType.advanced;
      case "profile":
        return SubjectType.profile;
      default:
        return SubjectType.voluntary;
    }
  }
}
