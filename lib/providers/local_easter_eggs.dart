import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:the_kronorium/providers/easter_eggs.dart';
import 'package:the_kronorium/storage/storage.dart';

part 'local_easter_eggs.g.dart';

@Riverpod(keepAlive: true)
class LocalEasterEggRegistry extends AbstractEasterEggRegistry {
  static StorageKey<List> easterEggList = StorageKey(
    namespace: "easter_eggs",
    path: ["local"],
  );

  Future<List<String>> loadEasterEggList() async {
    var storage = ref.watch(platformStorageProvider);
    var existingEasterEggs = await storage.read(easterEggList);
    if (existingEasterEggs == null) {
      return [];
    }
    return existingEasterEggs.cast<String>();
  }

  static StorageKey<Map<String, dynamic>> getEasterEggKeyForName(String value, {
    List<String> extraPath = const [],
  }) {
    return StorageKey(
      namespace: "easter_eggs",
      path: ["easter_egg", _sanitizeName(value), ...extraPath],
    );
  }

  Stream<Map<String, dynamic>> loadEasterEggStreams() async* {
    List<String> easterEggs = await loadEasterEggList();
    var storage = ref.watch(platformStorageProvider);
    for (var value in easterEggs) {
      StorageKey<Map<String, dynamic>> key = getEasterEggKeyForName(value, extraPath: ["meta"]);
      var item = await storage.read(key);
      if (item == null) {
        continue;
      }
      yield item;
    }
  }

  static String _sanitizeName(String name) =>
      name.replaceAll(RegExp(r"[^a-zA-Z0-9]"), "_").toLowerCase();

  Future saveEasterEgg(EasterEgg easterEgg) async {
    var json = easterEgg.toMap();
    StorageKey<Map<String, dynamic>> key = getEasterEggKeyForName(easterEgg.name, extraPath: ["meta"]);
    var storage = ref.watch(platformStorageProvider);
    storage.save(key, json);

    var names = await loadEasterEggList();
    var newNames = {
      ...names,
      easterEgg.name,
    };

    storage.save(
      easterEggList,
      newNames.toList(),
    );
    ref.invalidateSelf();
  }

  @override
  FutureOr<List<EasterEgg>> build() {
    return loadEasterEggsFrom(loadEasterEggStreams(), true);
  }

  Future<void> deleteEasterEgg(EasterEgg easterEgg) async {
    var easterEggKeyForName = getEasterEggKeyForName(easterEgg.name, extraPath:  ["meta"]);
    var storage = ref.watch(platformStorageProvider);
    storage.delete(easterEggKeyForName);

    var names = await loadEasterEggList();
    names.removeWhere(
      (element) {
        return element == easterEgg.name;
      },
    );
    storage.save(easterEggList, names);
    ref.invalidateSelf();
  }
}
