import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:the_kronorium/easter_eggs.dart';

class CreateStepDialog extends StatefulWidget {
  final void Function(EasterEggStep step) onCreated;

  const CreateStepDialog({
    super.key,
    required this.onCreated,
  });

  @override
  State<CreateStepDialog> createState() => _CreateStepDialogState();
}

class _CreateStepDialogState extends State<CreateStepDialog> {
  late final _id = TextEditingController();
  late final _summary = TextEditingController();
  late final _icon = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var names = MdiIcons.getNames();
    var key = GlobalKey<FormState>();
    return Dialog(
      child: Column(
        children: [
          ListTile(
            leading: Icon(MdiIcons.stepForward2),
            title: Text("Create a new step"),
          ),
          Form(
            key: key,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _id,
                    decoration: InputDecoration(
                      label: Text("Id"),
                      hintText:
                          "This is the text you use to reference this step in relation to other steps. It must be unique.",
                      icon: Icon(MdiIcons.rename),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return "This field is required";
                      }
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  TextFormField(
                    controller: _summary,
                    decoration: InputDecoration(
                      label: const Text("Summary"),
                      hintText: "This is the text shown to the user.",
                      icon: Icon(MdiIcons.text),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return "This field is required";
                      }
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  TextFormField(
                    controller: _icon,
                    decoration: InputDecoration(
                      label: const Text("Icon"),
                      hintText:
                          "This is the id of the optional icon that will be shown on the item.",
                      icon: Icon(MdiIcons.simpleIcons),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: OverflowBar(
              alignment: MainAxisAlignment.end,
              children: [
                FilledButton(
                  onPressed: () {
                    var state = key.currentState;
                    if (state == null) {
                      return;
                    }
                    if (!state.validate()) {
                      return;
                    }
                    var step = EasterEggStep(
                      name: _id.text,
                      summary: _summary.text,
                      iconName: _icon.text,
                      dependencies: [],
                      notes: [],
                      gallery: [],
                      validIn: [],
                      kind: EasterEggStepKind.requirement,
                    );
                    widget.onCreated(step);
                    Navigator.of(context).pop();
                  },
                  child: const Text("Create"),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
