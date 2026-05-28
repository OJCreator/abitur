enum SubjectNiveau {
  basic("Grundlegendes Anforderungsniveau", "gA"),
  advanced("Erhöhtes Anforderungsniveau", "eA"),
  profile("Profilfach", "Profilfach"),
  voluntary("Wahlfach", "Wahlfach");

  final String name;
  final String shortName;
  String get code {
    switch (this) {
      case SubjectNiveau.basic:
        return "basic";
      case SubjectNiveau.advanced:
        return "advanced";
      case SubjectNiveau.profile:
        return "profile";
      case SubjectNiveau.voluntary:
        return "voluntary";
    }
  }

  const SubjectNiveau(this.name, this.shortName);

  static SubjectNiveau fromCode(String code) {
    switch (code) {
      case "basic":
        return SubjectNiveau.basic;
      case "advanced":
        return SubjectNiveau.advanced;
      case "profile":
        return SubjectNiveau.profile;
      default:
        return SubjectNiveau.voluntary;
    }
  }
}
