import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_kronorium/form_validators.dart';
import 'package:the_kronorium/providers/easter_eggs.dart';
import 'package:the_kronorium/providers/game_registry.dart';
import 'package:the_kronorium/providers/local_easter_eggs.dart';

class EasterEggFieldsEditor extends ConsumerStatefulWidget {
  final GlobalKey<FormState> formKey;
  final StateProvider<String> name;
  final StateProvider<String> map;
  final StateProvider<String> thumbnail;
  final StateProvider<ZombiesEdition> primaryEdition;

  const EasterEggFieldsEditor(
      {super.key,
      required this.formKey,
      required this.name,
      required this.map,
      required this.thumbnail,
      required this.primaryEdition});

  @override
  ConsumerState<EasterEggFieldsEditor> createState() =>
      _EasterEggFieldsEditorState();
}

class _EasterEggFieldsEditorState extends ConsumerState<EasterEggFieldsEditor> {
  final name = TextEditingController();
  final map = TextEditingController();
  final thumbnail = TextEditingController();

  @override
  void dispose() {
    name.dispose();
    map.dispose();
    thumbnail.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    name.text = ref.watch(widget.name);
    map.text = ref.watch(widget.map);
    thumbnail.text = ref.watch(widget.thumbnail);
  }

  @override
  Widget build(BuildContext context) {
    var games = ref.watch(gameManifestProvider);
    var easterEggs = ref.watch(localEasterEggRegistryProvider);
    var edition = ref.watch(widget.primaryEdition);
    return Form(
      key: widget.formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: () {
        setState(() {});
      },
      child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(
              labelText: "Easter Egg Name",
            ),
            validator: (name) => FormValidators.notEmpty(name, () {
              if (name != null) {
                var hasWithSameName = easterEggs.maybeWhen(
                  data: (data) =>
                      data.any((easterEgg) => easterEgg.name == name),
                  orElse: () => false,
                );
                if (hasWithSameName) {
                  return "A local easter egg with this name already exists.";
                }
              }
              return null;
            }),
            onChanged: (value) {
              ref.read(widget.name.notifier).state = value;
            },
            controller: name,
          ),
          TextFormField(
            decoration: const InputDecoration(
              labelText: "Map Name",
            ),
            validator: FormValidators.notEmpty,
            onChanged: (value) {
              ref.read(widget.map.notifier).state = value;
            },
            controller: map,
          ),
          TextFormField(
            decoration: const InputDecoration(
              labelText: "Thumbnail",
            ),
            validator: (value) => FormValidators.notEmpty(value, () {
              if (value != null) {
                if (!Uri.parse(value).isAbsolute) {
                  return "Thumbnail must be a valid URL";
                }
              }
              return null;
            }),
            onChanged: (value) {
              ref.read(widget.thumbnail.notifier).state = value;
            },
            controller: thumbnail,
          ),
          games.maybeWhen(
            orElse: () => const CircularProgressIndicator(),
            data: (data) {
              return DropdownMenu<ZombiesEdition>(
                label: const Text("Game"),
                initialSelection: edition,
                leadingIcon: Image.asset(
                  data[edition]!.thumbnail,
                  height: 24,
                  width: 24,
                ),
                onSelected: (value) {
                  if (value != null) {
                    ref.read(widget.primaryEdition.notifier).state = value;
                  }
                },
                dropdownMenuEntries: [
                  for (var MapEntry(
                        key: edition,
                        value: gameData,
                      ) in data.entries)
                    DropdownMenuEntry(
                      value: edition,
                      leadingIcon: Image.asset(
                        gameData.thumbnail,
                        height: 32,
                        width: 32,
                      ),
                      label: gameData.title,
                    )
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
