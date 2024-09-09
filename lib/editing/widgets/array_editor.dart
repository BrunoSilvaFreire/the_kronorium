import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:the_kronorium/editing/commands/add_array_element_command.dart';
import 'package:the_kronorium/editing/commands/commander.dart';
import 'package:the_kronorium/editing/commands/set_array_element_command.dart';
import 'package:the_kronorium/editing/editable_object.dart';
import 'package:the_kronorium/providers/easter_eggs.dart';

class ArrayEditor<T> extends StatefulWidget {
  final List<T> array;
  final EditableObject object;
  final String propertyName;
  final Commander commander;
  final EasterEgg easterEgg;
  final T Function() itemCreator;
  final Widget Function(
      int index, T input, void Function(T newValue) onModified) itemBuilder;

  const ArrayEditor({
    super.key,
    required this.array,
    required this.propertyName,
    required this.commander,
    required this.easterEgg,
    required this.object,
    required this.itemCreator,
    required this.itemBuilder,
  });

  @override
  State<ArrayEditor<T>> createState() => _ArrayEditorState<T>();
}

class _ArrayEditorState<T> extends State<ArrayEditor<T>> {
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _noteController.dispose();
  }

  void addElement(T element) {
    widget.commander.addCommand(
      AddArrayElementCommand(
        array: widget.array,
        element: element,
        objectName: widget.object.name,
        propertyName: widget.propertyName,
        onModified: widget.object.notifyListeners,
      ),
      widget.easterEgg,
    );
    _noteController.clear();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(
            "${widget.propertyName} (${widget.array.length})",
          ),
          trailing: IconButton(
            onPressed: () {
              addElement(widget.itemCreator());
            },
            icon: Icon(MdiIcons.plus),
          ),
        ),
        for (var (index, value) in widget.array.indexed)
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: widget.itemBuilder(
                  index,
                  value,
                  (T newValue) {
                    _setEntry(index, newValue);
                  },
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  MdiIcons.delete,
                ),
              ),
            ],
          ),
      ],
    );
  }

  void _setEntry(int index, T value) {
    widget.commander.addCommand(
      SetArrayElementCommand(
        array: widget.array,
        value: value,
        index: index,
        objectName: widget.object.name,
        propertyName: widget.propertyName,
        onModified: widget.object.notifyListeners,
      ),
      widget.easterEgg,
    );
  }
}
