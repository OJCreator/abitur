extension MapExtension<K, V> on Map<K, V> {
  Iterable<T> mapToIterable<T>(T Function(K key, V value) transform) {
    return entries.map((entry) => transform(entry.key, entry.value));
  }
}