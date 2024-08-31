import 'package:flutter/material.dart';
import 'package:the_kronorium/kronorium.dart';
import 'package:the_kronorium/pages/gallery.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const TheKronorium());
}

class TheKronorium extends StatelessWidget {
  const TheKronorium({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'The Kronorium',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.red,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const Kronorium(),
      ),
    );
  }
}

