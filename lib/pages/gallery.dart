import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:the_kronorium/easter_eggs.dart';
import 'package:the_kronorium/editing/editing_fields.dart';
import 'package:the_kronorium/form_validators.dart';
import 'package:the_kronorium/pages/easter_egg_page.dart';
import 'package:the_kronorium/pages/edit_graph_page.dart';
import 'package:the_kronorium/widgets/container_card.dart';

class EasterEggGallery extends ConsumerWidget {
  const EasterEggGallery({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var easterEggs = ref.watch(easterEggRegistryProvider);
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
        easterEggs.when(
          data: (data) {
            return Expanded(
              child: GridView.extent(
                maxCrossAxisExtent: 256,
                children: [
                  for (var easterEgg in data)
                    EasterEggCard(easterEgg: easterEgg)
                ],
              ),
            );
          },
          error: (error, stackTrace) {
            return Text("ono: ${error}\n ${stackTrace}");
          },
          loading: () {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ],
    );
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
  late final _name = TextEditingController();
  late final _map = TextEditingController();
  late final _thumbnail = TextEditingController();
  late final _key = GlobalKey<FormState>();

  @override
  void dispose() {
    _name.dispose();
    _map.dispose();
    _thumbnail.dispose();
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
        child: Dialog(
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
                  name: StateProvider(
                        (ref) => "",
                  ),
                  map: StateProvider(
                        (ref) => "",
                  ),
                  thumbnail: StateProvider(
                        (ref) => "",
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: OverflowBar(
                  children: [
                    FilledButton.tonal(
                      onPressed: (_key.currentState?.validate() ?? false)
                          ? () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => EditEasterEggPage(
                                    easterEgg: EasterEgg(
                                      steps: [],
                                      name: _name.text,
                                      map: _map.text,
                                      thumbnailURL: "",
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
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
        ),
      );
    });
  }
}

class EasterEggCard extends StatelessWidget {
  const EasterEggCard({
    super.key,
    required this.easterEgg,
  });

  final EasterEgg easterEgg;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image(
              image: NetworkImage(easterEgg.thumbnailURL),
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black87,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      easterEgg.name,
                      style: theme.textTheme.titleSmall,
                    ),
                    Text(
                      easterEgg.map,
                      style: theme.textTheme.headlineLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) {
                      return EasterEggPage(easterEgg);
                    },
                  ));
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
