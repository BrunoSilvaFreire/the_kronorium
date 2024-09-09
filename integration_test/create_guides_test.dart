import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:the_kronorium/editing/widgets/create_guide_dialog.dart';
import 'package:the_kronorium/main.dart' as app;
import 'test_lib.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'User can create an Easter Egg Guide',
    (WidgetTester tester) async {
      var container = createContainer();
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Verify that we are on the EasterEggGallery page
      var createGuideButton = find.text('Create new guide');
      expect(createGuideButton, findsOneWidget);

      // Tap the FloatingActionButton to create a new guide
      await tester.tap(createGuideButton);
      await tester.pumpAndSettle();

      var formFinder = find.byType(CreateGuideForm);
      expect(formFinder, findsOneWidget);

      // Enter the guide details in the form
      var easterEggName = find.bySemanticsLabel("Easter Egg Name");
      expect(easterEggName, findsOneWidget);
      await tester.enterText(easterEggName, 'Trial by Ordeal'); // Name
      await tester.pumpAndSettle();

      var mapName = find.bySemanticsLabel("Map Name");
      expect(mapName, findsOneWidget);
      var easterEggMapName = 'Dead of the Night (Integration Test)';
      await tester.enterText(mapName, easterEggMapName); // Map
      await tester.pumpAndSettle();

      var thumbnail = find.bySemanticsLabel("Thumbnail");
      expect(thumbnail, findsOneWidget);
      await tester.enterText(thumbnail,
          'https://static.wikia.nocookie.net/callofduty/images/4/4c/Dead_of_the_Night_BO4.jpg/revision/latest/scale-to-width-down/1000'); // Thumbnail
      await tester.pumpAndSettle();

      // Select a Zombies Edition

      await tester.tap(find.descendant(
        of: formFinder,
        matching: find.bySemanticsLabel('Game'),
      ));
      await tester.pumpAndSettle();
      await tester.tap(
        find
            .descendant(of: formFinder, matching: find.text('Black Ops 4'))
            .last,
      );
      await tester.pumpAndSettle();

      var foundLocalEasterEgg = await hasLocalEasterEgg(
        tester: tester,
        providerContainer: container,
        mapName: easterEggMapName,
      );
      assert(foundLocalEasterEgg);
    },
  );

  testWidgets(
    'User can open an Easter Egg Guide',
        (WidgetTester tester) async {
      var container = createContainer();
      app.main();
      await tester.pumpAndSettle();

      // Verify that we are on the EasterEggGallery page
      var moonCard = find.text('Moon');
      expect(moonCard, findsOneWidget);
      await tester.tap(moonCard);
      await tester.pumpAndSettle();
      expect(find.text("Turn on the power"), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.text("Create new guide"), findsOneWidget);
    },
  );
}
