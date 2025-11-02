import 'package:abitur/utils/enums/subject_niveau.dart';

enum SubjectType {
  wahlfach("Wahlfach", ["Orchester", "BigBand", "Theater"], false, false, null),
  profilfach("Profilfach", ["Instrumentalensemble", "Vokalensemble", "Psychologie"], false, true, 2),
  wSeminar("W-Seminar", ["W-Seminar"], false, true, 1),
  naturwissenschaftOhneInf("Naturwissenschaft (ohne Informatik)", ["Physik", "Biologie", "Chemie", "Biophysik", "Astrophysik"], true, true, 2),
  informatik("Informatik", ["Informatik"], true, true, 1),
  fortgefuehrteFremdsprache("Fortgeführte Fremdsprache", ["Englisch", "Französisch", "Latein", "Spanisch"], true, true, 2),
  spaetBeginnendeFremdsprache("Spät beginnende Fremdsprache", ["Türkisch", "Russisch", "Japanisch"], true, true, 1),
  standardPflichtfach("Standard-Pflichtfach", ["Deutsch", "Mathematik", "Geschichte", "Religion", "Ethik", "Sport", "Kunst", "Musik"], true, true, 6),
  gesellschaftswissenschaften("Gesellschaftswissenschaft", ["PuG", "Geographie", "Wirtschaft"], true, true, 2),
  mathevk("Vertiefungskurs Mathematik", ["Mathe VK"], false, true, 1),
  deutschvk("Vertiefungskurs Deutsch", ["Deutsch VK"], false, true, 1);

  final String displayName;
  final List<String> examples;
  final bool canBeLeistungsfach;
  final bool gradable;
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


  const SubjectType(this.displayName, this.examples, this.canBeLeistungsfach, this.gradable, this.maxAmount);


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

final subjectsBayern = [ // TODO
  SubjectTemplate("Biologie", "Bio", SubjectType.naturwissenschaftOhneInf),
  SubjectTemplate("Chemie", "Ch", SubjectType.naturwissenschaftOhneInf),
  SubjectTemplate("Deutsch", "D", SubjectType.standardPflichtfach, terms: {0,1,2,3}, countingTermAmount: 4, subjectNiveau: SubjectNiveau.advanced),
  SubjectTemplate("Englisch", "E", SubjectType.fortgefuehrteFremdsprache),
  SubjectTemplate("Ethik", "Eth", SubjectType.standardPflichtfach),
  SubjectTemplate("Religion", "Rel", SubjectType.standardPflichtfach),
  SubjectTemplate("Evangelische Religion", "Rel", SubjectType.standardPflichtfach),
  SubjectTemplate("Katholische Religion", "Rel", SubjectType.standardPflichtfach),
  SubjectTemplate("Französisch", "F", SubjectType.fortgefuehrteFremdsprache),
  SubjectTemplate("Geographie", "Geo", SubjectType.gesellschaftswissenschaften),
  SubjectTemplate("Geschichte", "G", SubjectType.standardPflichtfach),
  SubjectTemplate("Informatik", "Inf", SubjectType.informatik),
  SubjectTemplate("Kunst", "Ku", SubjectType.standardPflichtfach),
  SubjectTemplate("Mathematik", "M", SubjectType.standardPflichtfach, terms: {0,1,2,3}, countingTermAmount: 4, subjectNiveau: SubjectNiveau.advanced),
  SubjectTemplate("Musik", "Mu", SubjectType.standardPflichtfach),
  SubjectTemplate("Physik", "Ph", SubjectType.naturwissenschaftOhneInf),
  SubjectTemplate("Politik und Gesellschaft", "PuG", SubjectType.gesellschaftswissenschaften),
  SubjectTemplate("Spanisch", "S", SubjectType.fortgefuehrteFremdsprache),
  SubjectTemplate("Sport", "Spo", SubjectType.standardPflichtfach),
  SubjectTemplate("Wirtschaft und Recht", "WuR", SubjectType.gesellschaftswissenschaften),
  SubjectTemplate("W-Seminar", "WS", SubjectType.wSeminar, terms: {0,1,2}, countingTermAmount: 2),
];

class SubjectTemplate {
  final String name;
  final String shortName;
  final SubjectType subjectType;
  final Set<int> terms;
  final int countingTermAmount;
  final SubjectNiveau subjectNiveau;

  const SubjectTemplate(
      this.name,
      this.shortName,
      this.subjectType,
      {
        this.terms = const {0,1,2,3},
        this.countingTermAmount = 3,
        this.subjectNiveau = SubjectNiveau.basic,
      });
}