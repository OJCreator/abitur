extension NullableNumListExtension on List<num?> {
  List<int> findNLargestIndices(int n) {
    // Liste von Paaren (Index, Wert), wobei nur nicht-null-Werte berücksichtigt werden
    List<MapEntry<int, num>> nonNullEntries = asMap()
        .entries
        .where((entry) => entry.value != null)
        .map((entry) => MapEntry(entry.key, entry.value!))
        .toList();

    // Sortiere die nicht-null-Werte absteigend nach Wert
    nonNullEntries.sort((a, b) => b.value.compareTo(a.value));

    // Indizes der größten nicht-null-Werte
    List<int> result = nonNullEntries.take(n).map((entry) => entry.key).toList();

    // Falls wir noch weitere Indizes brauchen, füge die ersten null-Indizes hinzu
    if (result.length < n) {
      List<int> nullIndices = asMap()
          .entries
          .where((entry) => entry.value == null)
          .map((entry) => entry.key)
          .toList();

      result.addAll(nullIndices.take(n - result.length));
    }

    return result;
  }

  int indexOfMax() {
    if (isEmpty) {
      throw StateError(
          "Kann den Index des Maximums nicht bestimmen, Liste ist leer.");
    }

    int? maxIndex;
    num? maxValue;

    for (int i = 0; i < length; i++) {
      final value = this[i];
      if (value != null && (maxValue == null || value > maxValue)) {
        maxValue = value;
        maxIndex = i;
      }
    }

    if (maxIndex == null) {
      throw StateError("Alle Werte sind null.");
    }

    return maxIndex;
  }
}