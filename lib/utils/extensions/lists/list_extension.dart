extension ListExtensions<T> on List<T> {
  T? elementAtOrNull(int index) {
    if (index < 0 || index >= length) {
      return null;
    }
    return this[index];
  }
  List<int> indicesOf(T value) {
    List<int> indices = [];
    for (int i = 0; i < length; i++) {
      if (this[i] == value) {
        indices.add(i);
      }
    }
    return indices;
  }
  List<int> indicesWhere(bool Function(T element) test) {
    List<int> indices = [];
    for (int i = 0; i < length; i++) {
      if (test(this[i])) {
        indices.add(i);
      }
    }
    return indices;
  }

  List<T> maxSize(int maxSize) {
    if (length <= maxSize) {
      return this;
    }
    return getRange(0, maxSize).toList();
  }
}