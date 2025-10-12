extension IntExtension on int {
  String weekday() {
    switch (this) {
      case 1: return "Montag";
      case 2: return "Dienstag";
      case 3: return "Mittwoch";
      case 4: return "Donnerstag";
      case 5: return "Freitag";
      case 6: return "Samstag";
      default: return "Sonntag";
    }
  }
  String monthShort() {
    switch (this) {
      case 1: return "Jan";
      case 2: return "Feb";
      case 3: return "Mär";
      case 4: return "Apr";
      case 5: return "Mai";
      case 6: return "Jun";
      case 7: return "Jul";
      case 8: return "Aug";
      case 9: return "Sep";
      case 10: return "Okt";
      case 11: return "Nov";
      default: return "Dez";
    }
  }
}