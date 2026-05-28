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

final subjectsBayern = [
  SubjectTemplate(
    id: "arc",
    name: "Archäologie",
    shortName: "Arc",
    termsOptions: [
      {0,1},
      {0, 1, 2, 3},
      {2, 3},
    ],
    minCountingTermAmount: 0,
    niveauOptions: [
      SubjectNiveau.profile
    ],
  ),

  SubjectTemplate(
    id: "bio",
    name: "Biologie",
    shortName: "Bio",
    termsOptions: [
      {0, 1, 2, 3},
      {2, 3},
    ],
    minCountingTermAmount: 3,
    niveauOptions: [
      SubjectNiveau.basic,
      SubjectNiveau.advanced,
    ],
  ),

  SubjectTemplate(
    id: "che",
    name: "Chemie",
    shortName: "Ch",
    termsOptions: [
      {0, 1, 2, 3},
      {2, 3},
    ],
    minCountingTermAmount: 3,
    niveauOptions: [
      SubjectNiveau.basic,
      SubjectNiveau.advanced,
    ],
  ),

  SubjectTemplate(
    id: "chi",
    name: "Chinesisch",
    shortName: "Zh",
    termsOptions: [
      {0, 1, 2, 3},
      {2, 3},
    ],
    minCountingTermAmount: 3,
    niveauOptions: [
      SubjectNiveau.basic,
      SubjectNiveau.advanced,
    ],
  ),

  SubjectTemplate(
    id: "deu",
    name: "Deutsch",
    shortName: "D",
    termsOptions: [
      {0, 1, 2, 3},
    ],
    minCountingTermAmount: 4,
    niveauOptions: [
      SubjectNiveau.advanced,
    ],
  ),

  SubjectTemplate(
    id: "eng",
    name: "Englisch",
    shortName: "E",
    termsOptions: [
      {0, 1, 2, 3},
    ],
    minCountingTermAmount: 4,
    niveauOptions: [
      SubjectNiveau.basic,
      SubjectNiveau.advanced,
    ],
  ),

  SubjectTemplate(
    id: "eth",
    name: "Ethik",
    shortName: "Eth",
    termsOptions: [
      {0, 1, 2, 3},
    ],
    minCountingTermAmount: 4,
    niveauOptions: [
      SubjectNiveau.basic,
      SubjectNiveau.advanced,
    ],
  ),

  SubjectTemplate(
    id: "evg",
    name: "Evangelische Religion",
    shortName: "Rel",
    termsOptions: [
      {0, 1, 2, 3},
    ],
    minCountingTermAmount: 4,
    niveauOptions: [
      SubjectNiveau.basic,
      SubjectNiveau.advanced,
    ],
  ),

  SubjectTemplate(
    id: "frz",
    name: "Französisch",
    shortName: "F",
    termsOptions: [
      {0, 1, 2, 3},
    ],
    minCountingTermAmount: 4,
    niveauOptions: [
      SubjectNiveau.basic,
      SubjectNiveau.advanced,
    ],
  ),

  SubjectTemplate(
    id: "geo",
    name: "Geographie",
    shortName: "Geo",
    termsOptions: [
      {0, 1},
      {0, 1, 2, 3},
    ],
    minCountingTermAmount: 2,
    niveauOptions: [
      SubjectNiveau.basic,
      SubjectNiveau.advanced,
    ],
  ),

  SubjectTemplate(
    id: "glg",
    name: "Geologie",
    shortName: "Glg",
    termsOptions: [
      {0, 1},
      {0, 1, 2, 3},
      {2, 3},
    ],
    minCountingTermAmount: 0,
    niveauOptions: [
      SubjectNiveau.profile,
    ],
  ),

  SubjectTemplate(
    id: "ges",
    name: "Geschichte",
    shortName: "G",
    termsOptions: [
      {0, 1, 2, 3},
    ],
    minCountingTermAmount: 3,
    niveauOptions: [
      SubjectNiveau.basic,
      SubjectNiveau.advanced,
    ],
  ),

  SubjectTemplate(
    id: "gri",
    name: "Griechisch",
    shortName: "Gr",
    termsOptions: [
      {0, 1, 2, 3},
    ],
    minCountingTermAmount: 3,
    niveauOptions: [
      SubjectNiveau.basic,
      SubjectNiveau.advanced,
    ],
  ),

  SubjectTemplate(
    id: "kat",
    name: "Katholische Religion",
    shortName: "Rel",
    termsOptions: [
      {0, 1, 2, 3},
    ],
    minCountingTermAmount: 3,
    niveauOptions: [
      SubjectNiveau.basic,
      SubjectNiveau.advanced,
    ],
  ),

  SubjectTemplate(
    id: "inf",
    name: "Informatik",
    shortName: "Inf",
    termsOptions: [
      {0, 1, 2, 3},
    ],
    minCountingTermAmount: 3,
    niveauOptions: [
      SubjectNiveau.basic,
      SubjectNiveau.advanced,
    ],
  ),

  SubjectTemplate(
    id: "kun",
    name: "Kunst",
    shortName: "Ku",
    termsOptions: [
      {0, 1, 2, 3},
    ],
    minCountingTermAmount: 3,
    niveauOptions: [
      SubjectNiveau.basic,
      SubjectNiveau.advanced,
    ],
  ),

  SubjectTemplate(
    id: "mat",
    name: "Mathematik",
    shortName: "M",
    termsOptions: [
      {0, 1, 2, 3},
    ],
    minCountingTermAmount: 4,
    niveauOptions: [
      SubjectNiveau.advanced,
    ],
  ),

  SubjectTemplate(
    id: "mus",
    name: "Musik",
    shortName: "Mu",
    termsOptions: [
      {0, 1, 2, 3},
    ],
    minCountingTermAmount: 3,
    niveauOptions: [
      SubjectNiveau.basic,
      SubjectNiveau.advanced,
    ],
  ),

  SubjectTemplate(
    id: "phy",
    name: "Physik",
    shortName: "Ph",
    termsOptions: [
      {0, 1, 2, 3},
      {2, 3},
    ],
    minCountingTermAmount: 3,
    niveauOptions: [
      SubjectNiveau.basic,
      SubjectNiveau.advanced,
    ],
  ),

  SubjectTemplate(
    id: "pug",
    name: "Politik und Gesellschaft",
    shortName: "PuG",
    termsOptions: [
      {0, 1},
      {0, 1, 2, 3},
    ],
    minCountingTermAmount: 1,
    niveauOptions: [
      SubjectNiveau.basic,
      SubjectNiveau.advanced,
    ],
  ),

  SubjectTemplate(
    id: "spa",
    name: "Spanisch",
    shortName: "S",
    termsOptions: [
      {0, 1, 2, 3},
    ],
    minCountingTermAmount: 3,
    niveauOptions: [
      SubjectNiveau.basic,
      SubjectNiveau.advanced,
    ],
  ),

  SubjectTemplate(
    id: "spo",
    name: "Sport",
    shortName: "Spo",
    termsOptions: [
      {0, 1, 2, 3},
    ],
    minCountingTermAmount: 0,
    niveauOptions: [
      SubjectNiveau.basic,
      SubjectNiveau.advanced,
    ],
  ),

  SubjectTemplate(
    id: "wur",
    name: "Wirtschaft und Recht",
    shortName: "WuR",
    termsOptions: [
      {0, 1},
      {0, 1, 2, 3},
    ],
    minCountingTermAmount: 1,
    niveauOptions: [
      SubjectNiveau.basic,
      SubjectNiveau.advanced,
    ],
  ),

  SubjectTemplate(
    id: "ins",
    name: "Instrumentalensemble",
    shortName: "Ins",
    termsOptions: [
      {0, 1},
      {0, 1, 2, 3},
      {2, 3},
    ],
    minCountingTermAmount: 0,
    niveauOptions: [
      SubjectNiveau.profile,
    ],
  ),

  SubjectTemplate(
    id: "isl",
    name: "Islamischer Unterricht",
    shortName: "Isl",
    termsOptions: [
      {0, 1, 2, 3},
    ],
    minCountingTermAmount: 3,
    niveauOptions: [
      SubjectNiveau.basic,
    ],
  ),

  SubjectTemplate(
    id: "isr",
    name: "Israelitische Religionslehre",
    shortName: "Isr",
    termsOptions: [
      {0, 1, 2, 3},
    ],
    minCountingTermAmount: 3,
    niveauOptions: [
      SubjectNiveau.basic,
    ],
  ),

  SubjectTemplate(
    id: "ita",
    name: "Italienisch",
    shortName: "I",
    termsOptions: [
      {0, 1, 2, 3},
    ],
    minCountingTermAmount: 3,
    niveauOptions: [
      SubjectNiveau.basic,
      SubjectNiveau.advanced,
    ],
  ),

  SubjectTemplate(
    id: "lat",
    name: "Latein",
    shortName: "L",
    termsOptions: [
      {0, 1, 2, 3},
    ],
    minCountingTermAmount: 3,
    niveauOptions: [
      SubjectNiveau.basic,
      SubjectNiveau.advanced,
    ],
  ),

  SubjectTemplate(
    id: "ort",
    name: "Orthodoxe Religionslehre",
    shortName: "Ort",
    termsOptions: [
      {0, 1, 2, 3},
    ],
    minCountingTermAmount: 0,
    niveauOptions: [
      SubjectNiveau.basic,
    ],
  ),

  SubjectTemplate(
    id: "pol",
    name: "Polnisch",
    shortName: "Pol",
    termsOptions: [
      {0, 1, 2, 3},
    ],
    minCountingTermAmount: 3,
    niveauOptions: [
      SubjectNiveau.basic,
      SubjectNiveau.advanced,
    ],
  ),

  SubjectTemplate(
    id: "psy",
    name: "Psychologie",
    shortName: "Psy",
    termsOptions: [
      {0, 1},
      {0, 1, 2, 3},
      {2, 3},
    ],
    minCountingTermAmount: 0,
    niveauOptions: [
      SubjectNiveau.profile,
    ],
  ),

  SubjectTemplate(
    id: "rus",
    name: "Russisch",
    shortName: "Rus",
    termsOptions: [
      {0, 1, 2, 3},
    ],
    minCountingTermAmount: 3,
    niveauOptions: [
      SubjectNiveau.basic,
      SubjectNiveau.advanced,
    ],
  ),

  SubjectTemplate(
    id: "swf",
    name: "Sozialwissenschaftliche Arbeitsfelder",
    shortName: "SwA",
    termsOptions: [
      {0, 1},
      {0, 1, 2, 3},
      {2, 3},
    ],
    minCountingTermAmount: 0,
    niveauOptions: [
      SubjectNiveau.profile,
    ],
  ),

  SubjectTemplate(
    id: "sug",
    name: "Sport und Gesellschaft",
    shortName: "SuG",
    termsOptions: [
      {0, 1},
      {0, 1, 2, 3},
      {2, 3},
    ],
    minCountingTermAmount: 0,
    niveauOptions: [
      SubjectNiveau.profile,
    ],
  ),

  SubjectTemplate(
    id: "tbk",
    name: "Tanz- und Bewegungskünste",
    shortName: "TBk",
    termsOptions: [
      {0, 1},
      {0, 1, 2, 3},
      {2, 3},
    ],
    minCountingTermAmount: 0,
    niveauOptions: [
      SubjectNiveau.profile,
    ],
  ),

  SubjectTemplate(
    id: "thf",
    name: "Theater und Film",
    shortName: "ThF",
    termsOptions: [
      {0, 1},
      {0, 1, 2, 3},
      {2, 3},
    ],
    minCountingTermAmount: 0,
    niveauOptions: [
      SubjectNiveau.profile,
    ],
  ),

  SubjectTemplate(
    id: "tsc",
    name: "Tschechisch",
    shortName: "Tsc",
    termsOptions: [
      {0, 1, 2, 3},
    ],
    minCountingTermAmount: 3,
    niveauOptions: [
      SubjectNiveau.basic,
      SubjectNiveau.advanced,
    ],
  ),

  SubjectTemplate(
    id: "tue",
    name: "Türkisch",
    shortName: "Tür",
    termsOptions: [
      {0, 1, 2, 3},
    ],
    minCountingTermAmount: 3,
    niveauOptions: [
      SubjectNiveau.basic,
      SubjectNiveau.advanced,
    ],
  ),

  SubjectTemplate(
    id: "vok",
    name: "Vokalensemble",
    shortName: "Vok",
    termsOptions: [
      {0, 1},
      {0, 1, 2, 3},
      {2, 3},
    ],
    minCountingTermAmount: 0,
    niveauOptions: [
      SubjectNiveau.profile,
    ],
  ),

  SubjectTemplate(
    id: "win",
    name: "Wirtschaftsinformatik",
    shortName: "Win",
    termsOptions: [
      {0, 1},
      {0, 1, 2, 3},
      {2, 3},
    ],
    minCountingTermAmount: 0,
    niveauOptions: [
      SubjectNiveau.basic,
      SubjectNiveau.advanced,
    ],
  ),

  SubjectTemplate(
    id: "wse",
    name: "W-Seminar",
    shortName: "WS",
    termsOptions: [
      {0, 1, 2},
    ],
    minCountingTermAmount: 2,
    niveauOptions: [
      SubjectNiveau.basic,
    ],
  ),
];

class SubjectTemplate implements Comparable<SubjectTemplate> {
  final String id;
  final String name;
  final String shortName;

  final List<Set<int>> termsOptions;
  final int minCountingTermAmount;
  final List<SubjectNiveau> niveauOptions;

  const SubjectTemplate({
    required this.id,
    required this.name,
    required this.shortName,
    required this.niveauOptions,
    required this.termsOptions,
    this.minCountingTermAmount = 0,
  });

  @override
  int compareTo(SubjectTemplate other) {
    return name.compareTo(other.name);
  }
}
