import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:localstorage/localstorage.dart';
import 'package:the_kronorium/providers/easter_eggs.dart';
import 'package:the_kronorium/pages/home.dart';
import 'package:the_kronorium/providers/game_registry.dart';

part 'kronorium.g.dart';

sealed class AppState {
  const AppState();
}

class Loading extends AppState {
  const Loading();
}

class Loaded extends AppState {
  const Loaded();
}

@Riverpod(keepAlive: true)
class AppInitialization extends _$AppInitialization {
  @override
  Stream<AppState> build() async* {

    yield const Loading();
    await initLocalStorage();
    var easterEggs = ref.watch(easterEggRegistryProvider);
    var games = ref.watch(gameManifestProvider);
    if (easterEggs.hasValue && games.hasValue) {
      yield const Loaded();
    }
  }
}

class Kronorium extends ConsumerWidget {
  const Kronorium({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var value = ref.watch(appInitializationProvider);
    return value.maybeWhen(
      data: (data) {
        return const Home();
      },
      error: (error, stackTrace) {
        return Text(error.toString());
      },
      orElse: () {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
