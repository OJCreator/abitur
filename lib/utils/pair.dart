class Pair<A, B> {
  A first;
  B second;

  Pair(this.first, this.second);

  @override
  String toString() {
    return '($first, $second)';
  }

  Pair<B, A> swap() {
    return Pair(second, first);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Pair<A, B> &&
        other.first == first &&
        other.second == second;
  }

  @override
  int get hashCode => first.hashCode ^ second.hashCode;
}