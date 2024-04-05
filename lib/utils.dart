extension Interleave<T> on Iterable<T> {
  Iterable<T> interleave(T Function(T element) selector) sync* {
    var list = toList(growable: false);
    for (int i = 0; i < list.length - 1; i++) {
      var element = list[i];
      yield element;
      yield selector(element);
    }
    yield list.last;
  }
}
