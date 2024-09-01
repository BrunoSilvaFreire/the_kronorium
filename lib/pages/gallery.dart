import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:the_kronorium/pages/edit_graph_page.dart';
import 'package:the_kronorium/providers/easter_eggs.dart';
import 'package:the_kronorium/pages/easter_egg_page.dart';
import 'package:the_kronorium/providers/game_registry.dart';
import 'package:the_kronorium/providers/local_easter_eggs.dart';
import 'package:the_kronorium/widgets/container_card.dart';
import 'package:the_kronorium/widgets/create_guide_dialog.dart';
import 'package:the_kronorium/widgets/sliver_easter_egg_grid.dart';

class EasterEggGallery extends ConsumerStatefulWidget {
  const EasterEggGallery({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _EasterEggGalleryState();
  }
}

class _EasterEggGalleryState extends ConsumerState<EasterEggGallery> {
  final _searchController = TextEditingController();
  final _gameFilterProvider = StateProvider(
    (ref) => <ZombiesEdition>{},
  );

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var bundledEasterEggs = ref.watch(easterEggRegistryProvider);
    var localEasterEggs = ref.watch(localEasterEggRegistryProvider);
    var filtered = ref.watch(_gameFilterProvider);
    var games = ref.watch(gameManifestProvider);

    ref.watch(ChangeNotifierProvider(
      (ref) => _searchController,
    ));
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 256,
          ),
          child: ContainerCard.leftSideContainer(
            children: [
              FloatingActionButton.extended(
                elevation: 0,
                onPressed: () {
                  showModal(
                    context: context,
                    useRootNavigator: true,
                    builder: (context) {
                      return const Center(
                        child: CreateGuideForm(),
                      );
                    },
                  );
                },
                icon: Icon(MdiIcons.bookPlus),
                label: const Text("Create new guide"),
              )
            ],
          ),
        ),
        Expanded(
          child: CustomScrollView(
            shrinkWrap: true,
            slivers: [
              const SliverToBoxAdapter(
                child: SizedBox(
                  height: 16,
                ),
              ),
              SliverAppBar(
                primary: true,
                flexibleSpace: SearchBar(
                  controller: _searchController,
                  leading: Icon(MdiIcons.bookSearch),
                  hintText: "Search by map, game or easter egg name",
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    spacing: 8,
                    children: [
                      ...games.maybeWhen(
                        orElse: () {
                          return const <Widget>[];
                        },
                        data: (data) {
                          return [
                            for (var MapEntry(key: edition, value: game)
                                in data.entries)
                              FilterChip(
                                avatar: Image.asset(game.thumbnail),
                                label: Text(game.title),
                                selected: filtered.contains(edition),
                                onSelected: (bool value) {
                                  var newSet = {...filtered};
                                  if (value) {
                                    newSet.add(edition);
                                  } else {
                                    newSet.remove(edition);
                                  }
                                  ref.read(_gameFilterProvider.notifier).state =
                                      newSet;
                                },
                              ),
                          ];
                        },
                        loading: () {
                          return const <Widget>[
                            CircularProgressIndicator(),
                          ];
                        },
                      )
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: ListTile(
                  title: const Text("Bundled Guides"),
                  subtitle: const Text(
                    "Guides that are bundled with the app. These guides are curated by the developers.",
                  ),
                  leading: Icon(MdiIcons.fileCertificate),
                ),
              ),
              SliverEasterEggGrid(
                easterEggs: bundledEasterEggs,
                predicate: shouldShow,
              ),
              SliverToBoxAdapter(
                child: ListTile(
                  title: const Text("Your Guides"),
                  subtitle: const Text(
                    "Guides you have created. These are only stored locally in your device or on your browser. So be careful about losing your data.",
                  ),
                  leading: Icon(MdiIcons.fileAccount),
                ),
              ),
              SliverEasterEggGrid(
                easterEggs: localEasterEggs,
                predicate: shouldShow,
                badgeBuilder: (easterEgg) {
                  return IconButton.filledTonal(
                    icon: Icon(MdiIcons.trashCan),
                    onPressed: () async {
                      var shouldDelete = await showModal(
                        context: context,
                        configuration: const FadeScaleTransitionConfiguration(
                          barrierDismissible: false,
                        ),
                        builder: (context) {
                          return const ConfirmationDialog();
                        },
                      );
                      if (shouldDelete == true) {
                        ref
                            .read(localEasterEggRegistryProvider.notifier)
                            .deleteEasterEgg(easterEgg);
                      }
                    },
                  );
                },
              ),
            ],
          ),
        )
      ],
    );
  }

  bool shouldShow(EasterEgg easterEgg) {
    var validEntries = ref.read(_gameFilterProvider);
    if (validEntries.isNotEmpty) {
      if (!validEntries.contains(easterEgg.primaryEdition)) {
        return false;
      }
    }

    var query = _searchController.text;
    if (query.isEmpty) {
      return true;
    }
    return easterEgg.name.contains(query) || easterEgg.map.contains(query);
  }
}

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: ListTile(
        leading: Icon(MdiIcons.alert),
        title: const Text(
          "Are you sure you want to delete this guide?",
        ),
      ),
      content: const Text("This action cannot be undone. Are you sure?"),
      actions: [
        TextButton.icon(
          onPressed: () {
            Navigator.pop(context, false);
          },
          icon: Icon(MdiIcons.cancel),
          label: const Text("Don't delete it"),
        ),
        TextButton.icon(
          onPressed: () {
            Navigator.pop(context, true);
          },
          icon: Icon(MdiIcons.delete),
          label: const Text("Yes, delete it"),
        ),
      ],
    );
  }
}
