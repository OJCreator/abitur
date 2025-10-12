enum Land {
  bw("Baden-Württemberg"),
  by("Bayern"),
  be("Berlin"),
  bb("Brandenburg"),
  hb("Bremen"),
  hh("Hamburg"),
  he("Hessen"),
  mv("Mecklenburg-Vorpommern"),
  ni("Niedersachsen"),
  nw("Nordrhein-Westfalen"),
  rp("Rheinland-Pfalz"),
  sl("Saarland"),
  sn("Sachsen"),
  st("Sachsen-Anhalt"),
  sh("Schleswig-Holstein"),
  th("Thüringen"),
  none("Kein Land");

  final String name;

  const Land(this.name);

  String get code => toString().split('.').last;

  static Land fromCode(String code) {
    return Land.values.firstWhere((land) => land.code == code,
      orElse: () => throw ArgumentError("Invalid Land code: $code"),
    );
  }
}