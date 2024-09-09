import 'package:flutter/material.dart';

class EditStepNoteField extends StatefulWidget {
  final String initialValue;
  final String labelText;
  final void Function(String value) onSubmitted;

  const EditStepNoteField({
    super.key,
    required this.initialValue,
    required this.onSubmitted,
    required this.labelText,
  });

  @override
  State<EditStepNoteField> createState() => _EditStepNoteFieldState();
}

class _EditStepNoteFieldState extends State<EditStepNoteField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialValue,
    );
  }

  @override
  void didUpdateWidget(covariant EditStepNoteField oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.text = widget.initialValue;
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: widget.labelText,
      ),

      controller: _controller,
      onSubmitted: widget.onSubmitted,
    );
  }
}
