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