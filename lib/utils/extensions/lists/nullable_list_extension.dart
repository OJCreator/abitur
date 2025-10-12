extension NullableListExtensions<T> on List<T?> {
  void setSafe(int index, T? value) {
    if (index < 0) {
      return;
    }
    if (index >= length) {
      addAll(List<T?>.filled(index - length + 1, null));
    }
    this[index] = value;
  }
}