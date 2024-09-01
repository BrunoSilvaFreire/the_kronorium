import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:the_kronorium/providers/easter_eggs.dart';
import 'package:the_kronorium/serialization.dart';

part 'game_registry.g.dart';

@Riverpod(keepAlive: true)
class GameManifest extends _$GameManifest {
  @override
  Future<Map<ZombiesEdition, GameData>> build() async {
    var jsonStr = await rootBundle.loadString("assets/games/manifest.json");
    Map<String, dynamic> manifest = jsonDecode(jsonStr);

    var map = <ZombiesEdition, GameData>{};
    for (var game in manifest.requireList<Map<String, dynamic>>("games")) {
      var edition = ZombiesEdition.values.byName(game.require<String>("game"));

      map[edition] = GameData.fromMap(game);
    }
    return map;
  }
}

@Riverpod(keepAlive: true)
class GameRegistry extends _$GameRegistry {
  @override
  FutureOr<GameData> build(ZombiesEdition zombiesEdition) {
    var manifest = ref.watch(gameManifestProvider);
    return manifest.maybeWhen(
      orElse: () => Completer<GameData>().future,
      data: (data) {
        return Future.value(data[zombiesEdition]);
      },
    );
  }
}

class GameData {
  final String thumbnail;
  final String title;

  GameData({required this.thumbnail, required this.title});

  factory GameData.fromMap(Map<String, dynamic> game) {
    var thumbnail = game.require<String>("thumbnail");
    var title = game.require<String>("title");
    return GameData(
      thumbnail: thumbnail,
      title: title,
    );
  }
}
