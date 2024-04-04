extension Requirements on Map<String, dynamic> {
  T require<T>(String key) {
    var found = this[key] as T?;
    if (found == null) {
      throw Exception("Unable to find required $key on $this");
    }
    return found;
  }

  List<T> requireList<T>(String key) {
    List<dynamic>? found = this[key] as List<dynamic>?;
    if (found == null) {
      throw Exception("Unable to find required $key on $this");
    }
    return found.cast();
  }

  T? optional<T>(String key) {
    return this[key] as T?;
  }

  List<T>? optionalList<T>(String key) {
    List<dynamic>? found = this[key] as List<dynamic>?;
    if (found == null) {
      return null;
    }
    return found.cast();
  }
}
