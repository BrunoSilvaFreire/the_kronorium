import 'package:flutter/material.dart';
import 'package:the_kronorium/providers/easter_eggs.dart';

class EditStepGalleryField extends StatefulWidget {
  final EasterEggGalleryEntry entry;
  final String labelText;
  final void Function(EasterEggGalleryEntry value) onChanged;

  const EditStepGalleryField({
    super.key,
    required this.entry,
    required this.onChanged,
    required this.labelText,
  });

  @override
  State<EditStepGalleryField> createState() => _EditStepGalleryFieldState();
}

class _EditStepGalleryFieldState extends State<EditStepGalleryField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.entry.image.toString(),
    );
  }

  @override
  void didUpdateWidget(covariant EditStepGalleryField oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.text = widget.entry.image.toString();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: const InputDecoration(
        labelText: "Image URL",
      ),
      controller: _controller,
      onSubmitted: (value) {
        var parsed = Uri.tryParse(value);
        if (parsed == null) {
          return;
        }
        widget.onChanged(
          EasterEggGalleryEntry(
            image: parsed,
            notes: widget.entry.notes,
          ),
        );
      },
    );
  }
}
