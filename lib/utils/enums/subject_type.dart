enum SubjectType {
  wahlfach("Wahlfach", "Orchester, BigBand, ...", false, null),
  profilfach("Profilfach", "Instrumentalensemble, Psychologie, ...", false, 2),
  wSeminar("W-Seminar", "W-Seminar", false, 1),
  naturwissenschaftOhneInf("Naturwissenschaft (ohne Informatik)", "Physik, Biologie, ...", true, 2),
  informatik("Informatik", "Informatik", true, 1),
  fortgefuehrteFremdsprache("Fortgeführte Fremdsprache", "Englisch, Französisch, ...", true, 2),
  spaetBeginnendeFremdsprache("Spät beginnende Fremdsprache", "Türkisch, Russisch, ...", true, 1),
  standardPflichtfach("Standard-Pflichtfach", "Deutsch, Mathematik, Geschichte, Religion, Sport, Kunst, Musik", true, 6),
  gesellschaftswissenschaften("Gesellschaftswissenschaft", "PuG, Geographie, Wirtschaft", true, 2),
  mathevk("Vertiefungskurs Mathematik", "Mathe VK", false, 1),
  deutschvk("Vertiefungskurs Deutsch", "Deutsch VK", false, 1);

  final String displayName;
  final String examples;
  final bool canBeLeistungsfach;
  final int? maxAmount;

  String get code {
    switch (this) {
      case SubjectType.wahlfach:
        return "wahlfach";
      case SubjectType.profilfach:
        return "profilfach";
      case SubjectType.wSeminar:
        return "wSeminar";
      case SubjectType.naturwissenschaftOhneInf:
        return "naturwissenschaftOhneInf";
      case SubjectType.informatik:
        return "informatik";
      case SubjectType.fortgefuehrteFremdsprache:
        return "fortgefuehrteFremdsprache";
      case SubjectType.spaetBeginnendeFremdsprache:
        return "spaetBeginnendeFremdsprache";
      case SubjectType.standardPflichtfach:
        return "standardPflichtfaecher";
      case SubjectType.gesellschaftswissenschaften:
        return "gesellschaftswissenschaften";
      case SubjectType.mathevk:
        return "mathevk";
      case SubjectType.deutschvk:
        return "deutschvk";
    }
  }


  const SubjectType(this.displayName, this.examples, this.canBeLeistungsfach, this.maxAmount);


  static SubjectType fromCode(String code) {
    switch (code) {
      case "wahlfach":
        return SubjectType.wahlfach;
      case "profilfach":
        return SubjectType.profilfach;
      case "wSeminar":
        return SubjectType.wSeminar;
      case "naturwissenschaftOhneInf":
        return SubjectType.naturwissenschaftOhneInf;
      case "informatik":
        return SubjectType.informatik;
      case "fortgefuehrteFremdsprache":
        return SubjectType.fortgefuehrteFremdsprache;
      case "spaetBeginnendeFremdsprache":
        return SubjectType.spaetBeginnendeFremdsprache;
      case "standardPflichtfaecher":
        return SubjectType.standardPflichtfach;
      case "gesellschaftswissenschaften":
        return SubjectType.gesellschaftswissenschaften;
      case "mathevk":
        return SubjectType.mathevk;
      case "deutschvk":
        return SubjectType.deutschvk;
      default:
        throw ArgumentError("Unbekannter SubjectType-Code: $code");
    }
  }
}