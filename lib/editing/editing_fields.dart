import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_kronorium/form_validators.dart';

class EasterEggFieldsEditor extends ConsumerStatefulWidget {
  final GlobalKey<FormState> formKey;
  final StateProvider<String> name;
  final StateProvider<String> map;
  final StateProvider<String> thumbnail;

  const EasterEggFieldsEditor({
    super.key,
    required this.formKey,
    required this.name,
    required this.map,
    required this.thumbnail,
  });

  @override
  ConsumerState<EasterEggFieldsEditor> createState() => _EasterEggFieldsEditorState();
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
            validator: FormValidators.notEmpty,
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
            validator: FormValidators.notEmpty,
            onChanged: (value) {
              ref.read(widget.thumbnail.notifier).state = value;
            },
            controller: thumbnail,
          ),
        ],
      ),
    );
  }
}
