enum SubjectNiveau {
  basic("Grundlegendes Anforderungsniveau", "gA"),
  advanced("Erhöhtes Anforderungsniveau", "eA");

  final String name;
  final String shortName;
  String get code {
    switch (this) {
      case SubjectNiveau.basic:
        return "basic";
      case SubjectNiveau.advanced:
        return "advanced";
    }
  }

  const SubjectNiveau(this.name, this.shortName);

  static SubjectNiveau fromCode(String code) {
    switch (code) {
      case "basic":
        return SubjectNiveau.basic;
      default:
        return SubjectNiveau.advanced;
    }
  }
}
