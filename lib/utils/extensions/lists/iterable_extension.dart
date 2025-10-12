extension IterableExtension<T> on Iterable<T> {

  /// Zählt die Elemente, die der Bedingung [test] entsprechen.
  int countWhere(bool Function(T element) test) {
    return where(test).length;
  }

  Map<S, List<T>> groupBy<S>(S Function(T) keyFunction) {
    final map = <S, List<T>>{};
    for (var element in this) {
      final key = keyFunction(element);
      map.putIfAbsent(key, () => []).add(element);
    }
    return map;
  }


  /// Summiert die Werte, die durch die Transformationsfunktion [selector] bestimmt werden.
  num sumBy(num Function(T element) selector) {
    return fold(0, (previousValue, element) => previousValue + selector(element));
  }


  Map<T, U> mapWith<U>(U Function(T element) transform) {
    return {for (var element in this) element: transform(element)};
  }
}