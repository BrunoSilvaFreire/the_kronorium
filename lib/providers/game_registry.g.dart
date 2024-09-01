// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_registry.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$gameManifestHash() => r'280c3655d9ccffa58ad501aa20fc3a2ee2170e0c';

/// See also [GameManifest].
@ProviderFor(GameManifest)
final gameManifestProvider =
    AsyncNotifierProvider<GameManifest, Map<ZombiesEdition, GameData>>.internal(
  GameManifest.new,
  name: r'gameManifestProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$gameManifestHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$GameManifest = AsyncNotifier<Map<ZombiesEdition, GameData>>;
String _$gameRegistryHash() => r'743d1024114990037ef43036b057afc421d4095e';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$GameRegistry extends BuildlessAsyncNotifier<GameData> {
  late final ZombiesEdition zombiesEdition;

  FutureOr<GameData> build(
    ZombiesEdition zombiesEdition,
  );
}

/// See also [GameRegistry].
@ProviderFor(GameRegistry)
const gameRegistryProvider = GameRegistryFamily();

/// See also [GameRegistry].
class GameRegistryFamily extends Family<AsyncValue<GameData>> {
  /// See also [GameRegistry].
  const GameRegistryFamily();

  /// See also [GameRegistry].
  GameRegistryProvider call(
    ZombiesEdition zombiesEdition,
  ) {
    return GameRegistryProvider(
      zombiesEdition,
    );
  }

  @override
  GameRegistryProvider getProviderOverride(
    covariant GameRegistryProvider provider,
  ) {
    return call(
      provider.zombiesEdition,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'gameRegistryProvider';
}

/// See also [GameRegistry].
class GameRegistryProvider
    extends AsyncNotifierProviderImpl<GameRegistry, GameData> {
  /// See also [GameRegistry].
  GameRegistryProvider(
    ZombiesEdition zombiesEdition,
  ) : this._internal(
          () => GameRegistry()..zombiesEdition = zombiesEdition,
          from: gameRegistryProvider,
          name: r'gameRegistryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$gameRegistryHash,
          dependencies: GameRegistryFamily._dependencies,
          allTransitiveDependencies:
              GameRegistryFamily._allTransitiveDependencies,
          zombiesEdition: zombiesEdition,
        );

  GameRegistryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.zombiesEdition,
  }) : super.internal();

  final ZombiesEdition zombiesEdition;

  @override
  FutureOr<GameData> runNotifierBuild(
    covariant GameRegistry notifier,
  ) {
    return notifier.build(
      zombiesEdition,
    );
  }

  @override
  Override overrideWith(GameRegistry Function() create) {
    return ProviderOverride(
      origin: this,
      override: GameRegistryProvider._internal(
        () => create()..zombiesEdition = zombiesEdition,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        zombiesEdition: zombiesEdition,
      ),
    );
  }

  @override
  AsyncNotifierProviderElement<GameRegistry, GameData> createElement() {
    return _GameRegistryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GameRegistryProvider &&
        other.zombiesEdition == zombiesEdition;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, zombiesEdition.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin GameRegistryRef on AsyncNotifierProviderRef<GameData> {
  /// The parameter `zombiesEdition` of this provider.
  ZombiesEdition get zombiesEdition;
}

class _GameRegistryProviderElement
    extends AsyncNotifierProviderElement<GameRegistry, GameData>
    with GameRegistryRef {
  _GameRegistryProviderElement(super.provider);

  @override
  ZombiesEdition get zombiesEdition =>
      (origin as GameRegistryProvider).zombiesEdition;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
