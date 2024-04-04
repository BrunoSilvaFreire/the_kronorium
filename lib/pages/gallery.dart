import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_kronorium/easter_eggs.dart';
import 'package:the_kronorium/pages/easter_egg_page.dart';

class EasterEggGallery extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var easterEggs = ref.watch(easterEggRegistryProvider);
    return easterEggs.when(
      data: (data) {
        return GridView.extent(
          maxCrossAxisExtent: 256,
          children: [for (var easterEgg in data) EasterEggCard(easterEgg: easterEgg)],
        );
      },
      error: (error, stackTrace) {
        return Text("ono: ${error}");
      },
      loading: () {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
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
