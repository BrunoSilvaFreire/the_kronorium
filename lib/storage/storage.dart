import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:the_kronorium/storage/web.dart';

part 'storage.g.dart';

@Riverpod(keepAlive: true)
class PlatformStorage extends _$PlatformStorage {
  @override
  Storage build() {
    if (kIsWeb) {
      return WebStorage();
    } else {
      return FileStorage(
        File("storage"),
      );
    }
  }
}

class StorageKey<T> {
  final String namespace;
  final List<String> path;

  StorageKey({
    required this.namespace,
    required this.path,
  });

  @override
  String toString() {
    return "$namespace/${path.join(".")}";
  }
}

abstract class Storage {
  Future<void> save<T>(StorageKey<T> key, T value);

  Future<T?> read<T>(StorageKey<T> key);

  Future<void> delete<T>(StorageKey<T> key);
}

class MemoryStorage extends Storage {
  final Map<String, dynamic> _storage = {};

  @override
  Future<T?> read<T>(StorageKey key) async {
    return _storage[key.toString()] as T?;
  }

  @override
  Future<void> save<T>(StorageKey key, T value) async {
    _storage[key.toString()] = value;
  }

  @override
  Future<void> delete<T>(StorageKey<T> key) async {
    _storage.remove(key.toString());
  }
}

class FileStorage extends Storage {
  final File basePath;

  FileStorage(this.basePath);

  Future<File> _getFilePath(StorageKey key, String extension) async {
    StringBuffer path = StringBuffer();
    path.write(basePath.path);
    String? segment = key.namespace;
    int i = 0;
    while (true) {
      path.write("/$segment");
      if (i >= key.path.length) {
        break;
      }
      segment = key.path[i++];
    }
    path.write(extension);
    var destination = File(path.toString());
    var parent = destination.parent;
    if (!(await parent.exists())) {
      await parent.create(recursive: true);
    }
    return destination;
  }

  @override
  Future<T?> read<T>(StorageKey key) async {
    var file = await _getFilePath(key, ".json");
    if (!file.existsSync()) {
      return null;
    }
    var content = await file.readAsString();
    return jsonDecode(content) as T;
  }

  @override
  Future<void> save<T>(StorageKey key, T value) async {
    var file = await _getFilePath(key, ".json");
    var encoded = jsonEncode(value);
    await file.writeAsString(encoded);
  }

  Future<File> saveBinary<T>(StorageKey key, String extension, Uint8List value) async {
    var file = await _getFilePath(key, extension);
    await file.writeAsBytes(value);
    return file;
  }

  @override
  Future<void> delete<T>(StorageKey<T> key) async {
    var file = await _getFilePath(key, ".json");
    if (await file.exists()) {
      await file.delete();
    }
  }
}
