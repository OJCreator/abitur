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

  List<T> extendToSize<T>(int maxSize, T Function(int) generate) {
    final result = List<T>.from(this);
    while (result.length < maxSize) {
      result.add(generate(result.length));
    }
    return result;
  }
}