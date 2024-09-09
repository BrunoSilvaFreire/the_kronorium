import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_kronorium/providers/easter_eggs.dart';
import 'package:the_kronorium/providers/local_easter_eggs.dart';

ProviderContainer createContainer({
  ProviderContainer? parent,
  List<Override> overrides = const [],
  List<ProviderObserver>? observers,
}) {
  // Create a ProviderContainer, and optionally allow specifying parameters.
  final container = ProviderContainer(
    parent: parent,
    overrides: overrides,
    observers: observers,
  );

  // When the test ends, dispose the container.
  addTearDown(container.dispose);

  return container;
}

Future<bool> hasLocalEasterEgg({
  required WidgetTester tester,
  required ProviderContainer providerContainer,
  required String mapName,
}) async {
// Press the 'Create' button
  AsyncValue<List<EasterEgg>> values;
  do {
    values = providerContainer.read(localEasterEggRegistryProvider);
    await tester.pumpAndSettle();
  } while (values.isLoading);

  return values.requireValue.any(
    (element) => element.map == mapName,
  );
}
