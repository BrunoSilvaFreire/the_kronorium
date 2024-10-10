import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_kronorium/pages/easter_egg_page.dart';
import 'package:the_kronorium/providers/easter_eggs.dart';
import 'package:the_kronorium/providers/game_registry.dart';
import 'package:the_kronorium/widgets/image_download_error_indicator.dart';

class EasterEggCard extends ConsumerWidget {
  const EasterEggCard({super.key, required this.easterEgg, this.badge});

  final EasterEgg easterEgg;
  final Widget? badge;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var theme = Theme.of(context);
    var provider = gameRegistryProvider(easterEgg.primaryEdition);
    var gameData = ref.watch(provider);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          _buildBackgroundImage(),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black87,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: buildTitle(gameData, theme),
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
          ),
          if (badge != null)
            Positioned(
              top: 8,
              right: 8,
              child: badge!,
            ),
        ],
      ),
    );
  }

  Positioned _buildBackgroundImage() {
    return Positioned.fill(
      child: Image(
        image: NetworkImage(easterEgg.thumbnailURL),
        loadingBuilder: (context, child, ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          ThemeData theme = Theme.of(context);
          return const ImageDownloadErrorIndicator();
        },
        fit: BoxFit.cover,
      ),
    );
  }

  Widget buildTitle(AsyncValue<GameData> data, ThemeData theme) {
    return Row(
      children: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          child: data.maybeWhen(
            orElse: () => const CircleAvatar(),
            data: (data) => Image.asset(
              data.thumbnail,
              width: 32,
              height: 32,
            ),
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                easterEgg.name,
                style: theme.textTheme.titleSmall,
                overflow: TextOverflow.fade,
              ),
              FittedBox(
                child: Text(
                  easterEgg.map,
                  style: theme.textTheme.headlineSmall,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
