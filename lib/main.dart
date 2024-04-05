import 'package:flutter/material.dart';
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
        home: const Home(),
      ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: Scaffold(
        body: EasterEggGallery(),
      ),
    );
  }
}
