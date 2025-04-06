import 'package:abitur/utils/constants.dart';
import 'package:abitur/utils/pair.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testAvg();
  testRoundNote();
  testWeightedAvg();
  testListExtensions();
  testDateExtension();
}

void testAvg() {
  group('avg()', () {
    test('Berechnet den Durchschnitt ohne null-Werte korrekt', () {
      expect(avg([1, 2, 3, 4, 5]), equals(3.0));
    });

    test('Ignoriert null-Werte', () {
      expect(avg([1, null, 2, null, 5, 6]), equals(3.5));
    });

    test('Gibt null zurück bei nur null-Werten', () {
      expect(avg([null, null]), isNull);
    });

    test('Gibt null zurück bei leerer Liste', () {
      expect(avg([]), isNull);
    });
  });
}

testRoundNote() {
  group('roundNote()', () {
    test('Rundet korrekt', () {
      expect(roundNote(14.7), equals(15));
    });

    test('Rundet .5 auf', () {
      expect(roundNote(12.5), equals(13));
    });

    test('Rundet korrekt ab', () {
      expect(roundNote(10.49), equals(10));
    });

    test('Rundet unter einem Punkt ab', () {
      expect(roundNote(0.9), equals(0));
    });

    test('Gibt null zurück bei null', () {
      expect(roundNote(null), isNull);
    });
  });
}

testWeightedAvg() {
  group('roundNote()', () {
    test('Gleiche Gewichtung', () {
      expect(weightedAvg([Pair(0.5, 15), Pair(0.5, 12)]), equals(13.5));
    });
    test('3/4 zu 1/4 Gewichtung', () {
      expect(weightedAvg([Pair(0.75, 11), Pair(0.25, 2)]), equals(8.75));
    });

    test('Gewichtung ergibt nicht 100%', () {
      expect(weightedAvg([Pair(2, 11), Pair(4, 2)]), equals(5));
    });

    test('Leere Liste', () {
      expect(weightedAvg([]), equals(0));
    });

    test('Ignoriert null Werte', () {
      expect(weightedAvg([Pair(0.4, null), Pair(0.2, 2.3), Pair(0.4, null)]), equals(2.3));
    });
  });
}

testListExtensions() {
  group('setSafe()', () {
    test('Richtigen Wert setzen', () {
      var list = [3,2,1,1,null,3];
      list.setSafe(4, 5);
      expect(list, equals([3,2,1,1,5,3]));
    });
    test('Zu großer Index', () {
      List<int?> list = [1,3,2];
      list.setSafe(7, 5);
      expect(list, equals([1,3,2,null,null,null,null,5]));
    });
    test('Negativer Index', () {
      var list = [1,3,2];
      list.setSafe(-1, 5);
      expect(list, equals([1,3,2]));
    });
  });
  group('elementAtOrNull()', () {
    test('Richtigen Wert geben', () {
      expect([3,2,1].elementAtOrNull(2), equals(1));
    });
    test('Zu großer Index', () {
      expect([3,2,1].elementAtOrNull(7), equals(null));
    });
    test('Negativer Index', () {
      expect([3,2,1].elementAtOrNull(-2), equals(null));
    });
  });
  group('indicesOf()', () {
    test('Einmal gefunden', () {
      expect([3,2,1].indicesOf(2), equals([1]));
    });
    test('Mehrmals gefunden', () {
      expect(["3","3","2","1","3"].indicesOf("3"), equals([0,1,4]));
    });
    test('Keinmal gefunden', () {
      expect([3,3,2,1,3].indicesOf(5), equals([]));
    });
  });
  group('indicesWhere()', () {
    test('Einmal gefunden', () {
      expect([3,2545,1,772].indicesWhere((e) => e.isEven), equals([3]));
    });
    test('Mehrmals gefunden', () {
      expect(["300","33","21","1","3"].indicesWhere((e) => e.length == 2), equals([1,2]));
    });
    test('Keinmal gefunden', () {
      expect([3,3,2,1,3].indicesWhere((e) => e > 19), equals([]));
    });
  });
  group('countWhere()', () {
    test('Einmal gefunden', () {
      expect([3,2545,1,772].countWhere((e) => e > 1000), equals(1));
    });
    test('Mehrmals gefunden', () {
      expect(["300","33","21","1","3"].countWhere((e) => e.length == 2), equals(2));
    });
    test('Keinmal gefunden', () {
      expect([3,3,5,1,3].countWhere((e) => e.isEven), equals(0));
    });
  });
  group('findNLargestIndices()', () {
    test('Größter Index', () {
      expect([3,2545,1,772].findNLargestIndices(1), equals([1]));
    });
    test('Mehrere größte Indizes', () {
      expect([300,5,1,2,33].findNLargestIndices(3), equals([0,4,1]));
    });
    test('Null-Werte benötigt', () {
      expect([1,null,null,3].findNLargestIndices(4), equals([3,0,1,2]));
    });
    test('Mehr Indizes als Listenlänge', () {
      expect([1,3].findNLargestIndices(4), equals([1,0]));
    });
  });
  group('expandToList()', () {
    test('2 Listen', () {
      expect([[3,3,4],[2545,1,772]].expandToList(), equals([3,3,4,2545,1,772]));
    });
    test('Einzelne Werte in mehreren Listen', () {
      expect([[30],[5],[1],[2]].expandToList(), equals([30,5,1,2]));
    });
    test('Null-Werte', () {
      expect([[1,null],[null],[3]].expandToList(), equals([1,null,null,3]));
    });
    test('Ignoriert leere Listen', () {
      expect([[1],[],[3]].expandToList(), equals([1,3]));
    });
  });
  group('sumBy()', () {
    test('Strings summieren', () {
      expect(["1","4","110"].sumBy((e) => int.parse(e)), equals(115));
    });
    test('Modulo summieren', () {
      expect([14,13,3].sumBy((e) => e % 4), equals(6));
    });
    test('Leere Liste', () {
      expect([].sumBy((e) => 10), equals(0));
    });
  });
  group('sum()', () {
    test('Liste aufsummieren', () {
      expect([14,13,3].sum(), equals(30));
    });
    test('Leere Liste', () {
      expect(<int>[].sum(), equals(0));
    });
  });
}

testDateExtension() {
  group('format()', () {
    test('Datum formatieren', () {
      DateTime dt = DateTime(DateTime.now().year, 10, 12);
      expect(dt.format(), endsWith("12.10"));
    });
    test('Datum in einem Jahr', () {
      DateTime dt = DateTime(DateTime.now().year+1, 10, 12);
      expect(dt.format(), endsWith("12.10.${DateTime.now().year+1}"));
    });
    test('Wochentag stimmt', () {
      DateTime dt = DateTime(2025, 4, 6);
      expect(dt.format(), startsWith("So"));
    });
  });
  group('formatYear()', () {
    test('Datum formatieren', () {
      DateTime dt = DateTime(2012, 10, 12);
      expect(dt.formatYear(), equals("2012"));
    });
  });
  group('isOnSameDay()', () {
    test('Heute und morgen', () {
      DateTime now = DateTime.now();
      DateTime tomorrow = DateTime.now().add(Duration(days: 1));
      expect(now.isOnSameDay(tomorrow), equals(false));
    });
    test('Früher und später', () {
      DateTime early = DateTime.now().copyWith(hour: 13);
      DateTime late = DateTime.now().copyWith(hour: 15, minute: 21);
      expect(late.isOnSameDay(early), equals(true));
    });
  });
  group('weekday()', () {
    test('Montag', () {
      expect(1.weekday(), equals("Montag"));
    });
    test('Freitag', () {
      expect(5.weekday(), equals("Freitag"));
    });
  });
}