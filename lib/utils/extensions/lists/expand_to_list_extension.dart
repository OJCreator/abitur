extension ExpandToListExtension<E> on Iterable<Iterable<E>> {
  /// Kombiniert verschachtelte Listen zu einer flachen Liste.
  List<E> expandToList() => expand((list) => list).toList();
}