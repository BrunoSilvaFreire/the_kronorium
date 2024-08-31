import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:the_kronorium/providers/easter_eggs.dart';
import 'package:the_kronorium/editing/editing_fields.dart';
import 'package:the_kronorium/pages/edit_graph_page.dart';
import 'package:the_kronorium/providers/local_easter_eggs.dart';

class CreateGuideDialog extends ConsumerWidget {
  const CreateGuideDialog({
    super.key,
    required GlobalKey<FormState> formKey,
    required StateProvider<String> name,
    required StateProvider<String> map,
    required StateProvider<String> thumbnail,
  })  : _key = formKey,
        _name = name,
        _map = map,
        _thumbnail = thumbnail;

  final GlobalKey<FormState> _key;
  final StateProvider<String> _name;
  final StateProvider<String> _map;
  final StateProvider<String> _thumbnail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var name = ref.watch(_name);
    var map = ref.watch(_map);
    var thumbnail = ref.watch(_thumbnail);

    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(MdiIcons.bookPlus),
            title: const Text("Create new guide"),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: EasterEggFieldsEditor(
              formKey: _key,
              name: _name,
              map: _map,
              thumbnail: _thumbnail,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: OverflowBar(
              children: [
                FilledButton.tonal(
                  onPressed: (_key.currentState?.validate() ?? false)
                      ? () {
                          var registry = ref.read(
                            localEasterEggRegistryProvider.notifier,
                          );
                          createEasterEgg(
                            name,
                            map,
                            thumbnail,
                            context,
                            registry,
                          );
                        }
                      : null,
                  child: const Text("Create"),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  void createEasterEgg(
    String name,
    String map,
    String thumbnail,
    BuildContext context,
    LocalEasterEggRegistry registry,
  ) {
    var easterEgg = EasterEgg(
      steps: [],
      name: name,
      map: map,
      thumbnailURL: thumbnail,
      color: Theme.of(context).primaryColor,
    );
    registry.saveEasterEgg(easterEgg);
    // We do a pop instead of replace in order to allow the hero animation of
    // the FAB to work correctly.
    Navigator.pop(context);
    EditEasterEggPage.openForEdit(context, easterEgg);
  }
}

class CreateGuideForm extends StatefulWidget {
  const CreateGuideForm({
    super.key,
  });

  @override
  State<CreateGuideForm> createState() => _CreateGuideFormState();
}

class _CreateGuideFormState extends State<CreateGuideForm> {
  late final _name = StateProvider<String>(
    (ref) => "",
  );
  late final _map = StateProvider<String>(
    (ref) => "",
  );
  late final _thumbnail = StateProvider<String>(
    (ref) => "",
  );
  late final _key = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: 64 * 6,
          maxWidth: constraints.maxWidth * 0.6,
        ),
        child: CreateGuideDialog(
          formKey: _key,
          name: _name,
          map: _map,
          thumbnail: _thumbnail,
        ),
      );
    });
  }
}
