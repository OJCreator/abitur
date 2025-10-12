import '../enums/land.dart';

extension LandExtension on Land {
  int get writtenAmount {
    if (this == Land.sl || this == Land.st) {
      return 4;
    }
    return 3;
  }
  int get oralAmount {
    if ([Land.bb, Land.hb, Land.hh, Land.nw, Land.rp, Land.sl, Land.st, Land.sh].contains(this)) {
      return 1;
    }
    return 2;
  }
  bool get extraGraduationSubject {
    return [Land.nw, Land.rp, Land.sh, Land.nw].contains(this);
  }
}