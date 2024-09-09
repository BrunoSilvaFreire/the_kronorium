import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/icon_map.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class IconPicker extends StatefulWidget {
  final int maxNumIcons;
  final void Function(String? icon) onPicked;
  final String? initialIcon;
  final String? label;
  final double? width;

  const IconPicker({
    super.key,
    required this.onPicked,
    required this.initialIcon,
    required this.maxNumIcons,
    this.label, this.width,
  });

  @override
  State<IconPicker> createState() => _IconPickerState();
}

class _IconPickerState extends State<IconPicker> {
  final TextEditingController _iconSearchController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _iconSearchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    IconData? icon;
    var initialIcon = widget.initialIcon;
    if (initialIcon != null) {
      icon = MdiIcons.fromString(initialIcon);
    }
    return ListenableBuilder(
      listenable: _iconSearchController,
      builder: (context, _) {
        var label = widget.label;
        return Container(
          margin: const EdgeInsets.only(top: 8),
          child: DropdownMenu<String?>(
            inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
              border: InputBorder.none,
            ),
            dropdownMenuEntries: _getIconSuggestions(),
            label: label == null ? null : Text(label),
            hintText: initialIcon,
            initialSelection: initialIcon,
            leadingIcon: icon == null ? null : Icon(icon),
            onSelected: (value) {
              widget.onPicked(value);
            },
            controller: _iconSearchController,
            width: widget.width,
          ),
        );
      },
    );
  }

  List<DropdownMenuEntry<String>> _getIconSuggestions() {
    return iconMap.entries
        .where(
          (element) => element.key.contains(_iconSearchController.text),
        )
        .take(widget.maxNumIcons)
        .map(
          (e) => DropdownMenuEntry(
            leadingIcon: Icon(e.value),
            value: e.key,
            label: e.key,
          ),
        )
        .toList();
  }
}
