import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_kronorium/pages/gallery.dart';
import 'package:the_kronorium/providers/easter_eggs.dart';

class SliverEasterEggGrid extends StatelessWidget {
  final AsyncValue<List<EasterEgg>> easterEggs;
  final bool Function(EasterEgg easterEgg) predicate;
  final Widget Function(EasterEgg easterEgg)? badgeBuilder;

  const SliverEasterEggGrid({
    super.key,
    required this.easterEggs,
    required this.predicate,
    this.badgeBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return easterEggs.when(
      data: (data) {
        return SliverGrid.extent(
          maxCrossAxisExtent: 256,
          children: [
            for (var easterEgg in data)
              if (predicate(easterEgg))
                EasterEggCard(
                  easterEgg: easterEgg,
                  badge: badgeBuilder?.call(easterEgg),
                )
          ],
        );
      },
      error: (error, stackTrace) {
        return SliverToBoxAdapter(
          child: Text("ono: $error\n $stackTrace"),
        );
      },
      loading: () {
        return const SliverToBoxAdapter(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
