import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:the_kronorium/providers/easter_eggs.dart';
import 'package:localstorage/localstorage.dart';

part 'local_easter_eggs.g.dart';

@Riverpod(keepAlive: true)
class LocalEasterEggRegistry extends AbstractEasterEggRegistry {
  List<String> loadEasterEggList() {
    var existingEasterEggs = localStorage.getItem("easter_eggs");
    if (existingEasterEggs == null) {
      return [];
    }
    List<dynamic> decoded = jsonDecode(existingEasterEggs);
    return decoded.cast<String>();
  }

  Stream<Map<String, dynamic>> loadEasterEggStreams() async* {
    List<String> easterEggs = loadEasterEggList();

    for (var value in easterEggs) {
      var item = localStorage.getItem(getEasterEggKeyForName(value));
      if (item == null) {
        continue;
      }
      yield json.decode(item);
    }
  }

  String sanitizeName(String name) =>
      name.replaceAll(RegExp(r"[^a-zA-Z0-9]"), "_");

  String getEasterEggKeyForName(String value) =>
      "easter_egg.${sanitizeName(value)}";

  void saveEasterEgg(EasterEgg easterEgg) {
    var easterEggKeyForName = getEasterEggKeyForName(easterEgg.name);
    localStorage.setItem(
      easterEggKeyForName,
      jsonEncode(
        easterEgg.toMap(),
      ),
    );

    var names = loadEasterEggList();
    localStorage.setItem(
      "easter_eggs",
      jsonEncode([
        ...names,
        easterEgg.name,
      ]),
    );
    ref.invalidateSelf();
  }

  @override
  FutureOr<List<EasterEgg>> build() {
    return loadEasterEggsFrom(loadEasterEggStreams());
  }

  void deleteEasterEgg(EasterEgg easterEgg) {
    var easterEggKeyForName = getEasterEggKeyForName(easterEgg.name);
    localStorage.removeItem(easterEggKeyForName);

    var names = loadEasterEggList();
    names.removeWhere(
      (element) {
        return element == easterEgg.name;
      },
    );
    localStorage.setItem(
      "easter_eggs",
      jsonEncode(names),
    );
    ref.invalidateSelf();
  }
}
