import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:animations/animations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:the_kronorium/editing/commands/commander.dart';
import 'package:the_kronorium/editing/commands/create_step_command.dart';
import 'package:the_kronorium/editing/commands/delete_steps_command.dart';
import 'package:the_kronorium/editing/commands/set_array_element_command.dart';
import 'package:the_kronorium/editing/widgets/edit_step_card.dart';
import 'package:the_kronorium/providers/easter_eggs.dart';
import 'package:the_kronorium/editing/commands/command.dart';
import 'package:the_kronorium/editing/editing_fields.dart';
import 'package:the_kronorium/pages/graph_page.dart';
import 'package:the_kronorium/providers/local_easter_eggs.dart';
import 'package:the_kronorium/storage/storage.dart';
import 'package:the_kronorium/widgets/container_card.dart';
import 'package:the_kronorium/editing/widgets/create_step_dialog.dart';
import 'package:the_kronorium/widgets/editor.dart';

class EditEasterEggPage extends ConsumerStatefulWidget {
  final EasterEgg easterEgg;

  const EditEasterEggPage({
    super.key,
    required this.easterEgg,
  });

  @override
  ConsumerState<EditEasterEggPage> createState() => _EditEasterEggPageState();

  static void openForEdit(
    BuildContext context,
    EasterEgg easterEgg, {
    bool asReplacement = false,
  }) {
    var page = MaterialPageRoute(
      builder: (context) {
        return EditEasterEggPage(
          easterEgg: easterEgg,
        );
      },
    );
    var navigator = Navigator.of(context);
    if (asReplacement) {
      navigator.pushReplacement(page);
    } else {
      navigator.push(page);
    }
  }
}

class DownloadInfo {
  final Uri uri;
  final int bytesReceived;
  final int totalBytes;
  final String? error;

  DownloadInfo({
    required this.uri,
    required this.bytesReceived,
    required this.totalBytes,
    this.error,
  });
}

class _EditEasterEggPageState extends ConsumerState<EditEasterEggPage> {
  late final _selected = StateProvider<Set<int>>(
    (ref) => {},
  );
  late final _downloadingImages = StateProvider<DownloadInfo?>(
    (ref) => null,
  );
  late final _commander = Commander();
  late final _key = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
  }

  void doCommand(Command command) {
    setState(() {
      _commander.addCommand(command, widget.easterEgg);
    });
  }

  void undoCommand() {
    setState(() {
      _commander.undoCurrentlyPointedCommand(widget.easterEgg);
    });
  }

  void redoCommand() {
    setState(() {
      _commander.redoOneCommand(widget.easterEgg);
    });
  }

  static List<(String, Color)> colorSuggestions = [
    ("Red Accent", Colors.redAccent),
    ("Pink Accent", Colors.pinkAccent),
    ("Purple Accent", Colors.purpleAccent),
    ("Deep Purple Accent", Colors.deepPurpleAccent),
    ("Indigo Accent", Colors.indigoAccent),
    ("Blue Accent", Colors.blueAccent),
    ("Light Blue Accent", Colors.lightBlueAccent),
    ("Cyan Accent", Colors.cyanAccent),
    ("Teal Accent", Colors.tealAccent),
    ("Green Accent", Colors.greenAccent),
    ("Light Green Accent", Colors.lightGreenAccent),
    ("Lime Accent", Colors.limeAccent),
    ("Yellow Accent", Colors.yellowAccent),
    ("Amber Accent", Colors.amberAccent),
    ("Orange Accent", Colors.orangeAccent),
    ("Deep Orange Accent", Colors.deepOrangeAccent),
    ("Red", Colors.red),
    ("Pink", Colors.pink),
    ("Purple", Colors.purple),
    ("Deep Purple", Colors.deepPurple),
    ("Indigo", Colors.indigo),
    ("Blue", Colors.blue),
    ("Light Blue", Colors.lightBlue),
    ("Cyan", Colors.cyan),
    ("Teal", Colors.teal),
    ("Green", Colors.green),
    ("Light Green", Colors.lightGreen),
    ("Lime", Colors.lime),
    ("Yellow", Colors.yellow),
    ("Amber", Colors.amber),
    ("Orange", Colors.orange),
    ("Deep Orange", Colors.deepOrange),
    ("Brown", Colors.brown),
    ("Blue Grey", Colors.blueGrey),
  ];

  late final _nameProvider = StateProvider(
    (ref) => widget.easterEgg.name,
  );
  late final _mapProvider = StateProvider(
    (ref) => widget.easterEgg.map,
  );
  late final _thumbnailProvider = StateProvider(
    (ref) => widget.easterEgg.thumbnailURL,
  );
  late final _editionProvider = StateProvider(
    (ref) => widget.easterEgg.primaryEdition,
  );

  @override
  Widget build(BuildContext context) {
    const leftContainerWidth = 352.0;
    const rightContainerWidth = 512.0;
    const marginSpacing = 32.0;

    var selected = ref.watch(_selected);
    widget.easterEgg.name = ref.watch(_nameProvider);
    widget.easterEgg.map = ref.watch(_mapProvider);
    widget.easterEgg.thumbnailURL = ref.watch(_thumbnailProvider);
    widget.easterEgg.primaryEdition = ref.watch(_editionProvider);
    var downloadInfo = ref.watch(_downloadingImages);
    return ListenableBuilder(
        listenable: Listenable.merge(widget.easterEgg.steps),
        builder: (context, child) {
          return GraphPage(
            easterEgg: widget.easterEgg,
            selectedProvider: _selected,
            mapMargin: const EdgeInsets.only(
              left: leftContainerWidth + marginSpacing,
              top: marginSpacing,
              bottom: marginSpacing,
              right: rightContainerWidth + marginSpacing,
            ),
            builder: (context, map) {
              var theme = Theme.of(context);
              return Stack(
                children: [
                  Positioned.fill(
                    child: map,
                  ),
                  Positioned(
                    top: 8,
                    bottom: 8,
                    left: 0,
                    width: leftContainerWidth,
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        ContainerCard.leftSideContainer(
                          children: [
                            FloatingActionButton.extended(
                              elevation: 0,
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              onPressed: () {
                                _onCreateStepClicked(context);
                              },
                              icon: Icon(MdiIcons.plusCircle),
                              label: const Text("Add Step"),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: _buildButtonBar(selected),
                            ),
                            if (downloadInfo != null) ...[
                              const Divider(),
                              ListTile(
                                leading: Icon(MdiIcons.cloudDownload),
                                title: Text(
                                  "Downloading image",
                                ),
                                subtitle: Text(downloadInfo.uri.toString()),
                              ),
                              if (downloadInfo.error != null)
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Error: ${downloadInfo.error}',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                )
                              else
                                LinearProgressIndicator(
                                  value: downloadInfo.totalBytes > 0
                                      ? downloadInfo.bytesReceived /
                                          downloadInfo.totalBytes
                                      : null,
                                ),
                            ],
                            TextButton.icon(
                              onPressed: _copyGuideJSONToClipboard,
                              icon: Icon(MdiIcons.contentCopy),
                              label: const Text("Copy JSON"),
                            ),
                            const Divider(),
                            ListTile(
                              leading: Icon(MdiIcons.counter),
                              title: Text(
                                  "Steps: ${widget.easterEgg.steps.length}"),
                            ),
                            EasterEggFieldsEditor(
                              formKey: _key,
                              name: _nameProvider,
                              map: _mapProvider,
                              thumbnail: _thumbnailProvider,
                              primaryEdition: _editionProvider,
                              allowChangeName: false,
                            ),
                            const Divider(),
                            DropdownMenu(
                              initialSelection: findExistingSuggestionForColor(
                                widget.easterEgg.color,
                              ),
                              hintText: "Easter Egg Color Theme",
                              leadingIcon: CircleAvatar(
                                backgroundColor: widget.easterEgg.color,
                              ),
                              onSelected: (value) {
                                if (value != null) {
                                  setState(() {
                                    widget.easterEgg.color = value;
                                  });
                                }
                              },
                              dropdownMenuEntries: [
                                for (var (name, accent) in colorSuggestions)
                                  DropdownMenuEntry(
                                    leadingIcon: CircleAvatar(
                                      backgroundColor: accent,
                                    ),
                                    value: accent,
                                    label: name,
                                  )
                              ],
                            ),
                            const Divider(),
                          ],
                        ),
                        for (var stepIndex in selected)
                          EditStepCard(
                            easterEgg: widget.easterEgg,
                            step: widget.easterEgg.steps[stepIndex],
                            commander: _commander,
                          )
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    bottom: 0,
                    right: 0,
                    width: 512,
                    child: IntrinsicHeight(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            for (var sel in selected)
                              ContainerCard(
                                child: Editor(
                                  selected: Provider(
                                    (ref) {
                                      return widget.easterEgg.steps[sel];
                                    },
                                  ),
                                  onDelete: (EasterEggStep step) {},
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              );
            },
          );
        });
  }

  void _copyGuideJSONToClipboard() async {
    var content = jsonEncode(widget.easterEgg.toMap());
    await Clipboard.setData(ClipboardData(text: content));
  }

  void _onCreateStepClicked(BuildContext context) {
    showModal(
        context: context,
        builder: (context) {
          return CreateStepDialog(
            onCreated: (EasterEggStep step) {
              doCommand(CreateStepCommand(step));
            },
          );
        });
  }

  OverflowBar _buildButtonBar(Set<int> selected) {
    var deleteAllLabel = selected.isEmpty
        ? "Delete selected"
        : "Delete selected (${selected.length})";
    var currentImage = ref.watch(_downloadingImages);
    return OverflowBar(
      alignment: MainAxisAlignment.spaceEvenly,
      spacing: 8,
      children: [
        Tooltip(
          message: "Undo",
          child: IconButton.filled(
            onPressed: _commander.canUndoCommand()
                ? () {
                    undoCommand();
                  }
                : null,
            icon: Icon(MdiIcons.undo),
          ),
        ),
        Tooltip(
          message: "Redo",
          child: IconButton.filled(
            onPressed: _commander.canRedoCommand() ? redoCommand : null,
            icon: Icon(MdiIcons.redo),
          ),
        ),
        Tooltip(
          message: deleteAllLabel,
          child: IconButton.filled(
            onPressed: selected.isEmpty
                ? null
                : () {
                    ref.read(_selected.notifier).state = Set.identity();
                    doCommand(DeleteStepsCommand(selected));
                  },
            icon: Icon(MdiIcons.delete),
          ),
        ),
        Tooltip(
          message: "Do a Richtofen",
          child: IconButton.filled(
            onPressed: () {
              ref.read(_selected.notifier).state = Set.identity();
              doCommand(
                DeleteStepsCommand(
                  List.generate(
                    widget.easterEgg.steps.length,
                    (index) => index,
                  ).toSet(),
                ),
              );
            },
            icon: Icon(MdiIcons.nuke),
          ),
        ),
        Tooltip(
          message: "Download images locally",
          child: IconButton.filled(
            onPressed: currentImage != null
                ? null
                : () async {
                    var steps = widget.easterEgg.steps;
                    HttpClient client = HttpClient();
                    try {
                      for (var value in steps) {
                        var step = value;
                        for (var (i, image) in step.gallery.indexed) {
                          var img = image.image;
                          switch (img.scheme) {
                            case "http":
                            case "https":
                              ref.read(_downloadingImages.notifier).state =
                                  DownloadInfo(
                                uri: img,
                                bytesReceived: 0,
                                totalBytes: 0,
                                error: null,
                              );
                              try {
                                await _downloadImage(client, img, ref, i, step)
                                    .timeout(const Duration(minutes: 1));
                              } catch (e) {
                                String errorMessage;
                                if (e is TimeoutException) {
                                  errorMessage =
                                      'Download timed out after 1 minute';
                                } else {
                                  errorMessage = e.toString();
                                }
                                ref.read(_downloadingImages.notifier).state =
                                    DownloadInfo(
                                  uri: img,
                                  bytesReceived: 0,
                                  totalBytes: 0,
                                  error: errorMessage,
                                );
                              }
                              break;
                            default:
                              break;
                          }
                        }
                      }
                    } finally {
                      ref.read(_downloadingImages.notifier).state = null;
                    }
                  },
            icon: Icon(MdiIcons.cloudDownload),
          ),
        ),
      ],
    );
  }

  Future<void> _downloadImage(
    HttpClient client,
    Uri img,
    WidgetRef ref,
    int index,
    EasterEggStep step,
  ) async {
    var request = await client.getUrl(img);
    var response = await request.close();

    int totalBytes = response.contentLength;
    int bytesReceived = 0;

    var bytes = await consolidateHttpClientResponseBytes(
      response,
      onBytesReceived: (cumulative, total) {
        bytesReceived = cumulative;
        if (total != null) {
          totalBytes = total;
        }
        ref.read(_downloadingImages.notifier).state = DownloadInfo(
          uri: img,
          bytesReceived: bytesReceived,
          totalBytes: totalBytes,
          error: null,
        );
      },
    );

    // If running in debug mode, save to $(RepositoryRoot)/easter_eggs/(easter_egg)/images folder
    if (kDebugMode) {
      var storage = ref.read(platformStorageProvider);
      if (storage is! FileStorage) {
        return;
      }

      var storageKey = LocalEasterEggRegistry.getEasterEggKeyForName(
          widget.easterEgg.name,
          extraPath: [
            "images",
            "${step.name}.$index",
          ]);

      var file = await storage.saveBinary(storageKey, ".png", bytes);
      var uri = Uri.file(file.absolute.path, windows: Platform.isWindows);

      doCommand(SetArrayElementCommand(
        onModified: step.notifyListeners,
        array: step.gallery,
        index: index,
        value: EasterEggGalleryEntry(
          image: uri,
          notes: step.gallery[index].notes,
        ),
        objectName: step.name,
        propertyName: "gallery",
      ));
    }
  }

  Color? findExistingSuggestionForColor(Color color) {
    for (var (_, existing) in colorSuggestions) {
      if (existing.value == color.value) {
        return existing;
      }
    }
    return null;
  }
}
