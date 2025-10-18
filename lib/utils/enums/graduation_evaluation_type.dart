enum GraduationEvaluationType {
  written("Schriftlich"),
  oral("Mündlich"),
  seminar("Seminararbeit");

  final String name;
  String get code => toString().split('.').last;

  const GraduationEvaluationType(this.name);

  static GraduationEvaluationType fromCode(String code) {
    return GraduationEvaluationType.values.firstWhere((type) => type.code == code,
      orElse: () => throw ArgumentError("Invalid GraduationEvaluationType code: $code"),
    );
  }
}