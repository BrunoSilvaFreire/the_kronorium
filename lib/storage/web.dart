import 'dart:convert';

import 'package:the_kronorium/storage/storage.dart';
import 'package:universal_html/html.dart' show window;

class WebStorage extends Storage {
  @override
  Future<T?> read<T>(StorageKey key) async {
    var content = window.localStorage[key.toString()];
    if (content == null) {
      return null;
    }
    return jsonDecode(content) as T;
  }

  @override
  Future<void> save<T>(StorageKey key, T value) async {
    window.localStorage[key.toString()] = jsonEncode(value);
  }
  @override
  Future<void> delete<T>(StorageKey<T> key) async {
    window.localStorage.remove(key.toString());
  }
}
