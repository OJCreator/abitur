import 'package:abitur/utils/extensions/lists/iterable_extension.dart';

extension IntIterableExtension<E> on Iterable<num> {
  /// Summiert die Werte einer Liste an Zahlen
  num sum() {
    return sumBy((i) => i);
  }
}