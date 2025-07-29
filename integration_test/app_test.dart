import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:infractions_mali/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Infractions Mali App Integration Tests', () {
    testWidgets('Complete app flow test', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify the app starts with home screen
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.text('Infractions Routières Mali'), findsOneWidget);

      // Test search functionality
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);
      await tester.enterText(searchField, 'radar');
      await tester.pumpAndSettle();
      expect(find.text('radar'), findsOneWidget);

      // Test filter dropdowns
      final dropdowns = find.byType(DropdownButton<String>);
      expect(dropdowns, findsAtLeastNWidgets(2));

      // Test drawer navigation
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      expect(find.byType(Drawer), findsOneWidget);

      // Test login button
      await tester.tap(find.byIcon(Icons.login));
      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsAtLeastNWidgets(2));

      // Test floating action buttons
      final fabButtons = find.byType(FloatingActionButton);
      expect(fabButtons, findsAtLeastNWidgets(2));

      // Test community map button
      await tester.tap(fabButtons.first);
      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsAtLeastNWidgets(3));
    });

    testWidgets('Authentication flow test', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to login screen
      await tester.tap(find.byIcon(Icons.login));
      await tester.pumpAndSettle();

      // Verify login screen elements
      expect(find.text('Connexion'), findsOneWidget);
      expect(find.text('Continuer avec Google'), findsOneWidget);
      expect(find.text('Continuer avec Facebook'), findsOneWidget);
    });

    testWidgets('Map navigation test', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test community map navigation
      final fabButtons = find.byType(FloatingActionButton);
      await tester.tap(fabButtons.first);
      await tester.pumpAndSettle();

      // Verify map screen
      expect(find.byType(Scaffold), findsAtLeastNWidgets(3));

      // Go back to home
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Test interactive map navigation
      await tester.tap(fabButtons.last);
      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsAtLeastNWidgets(3));
    });

    testWidgets('Settings and about test', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Open drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Test settings navigation
      await tester.tap(find.text('Paramètres'));
      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsAtLeastNWidgets(3));

      // Go back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Open drawer again
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Test about navigation
      await tester.tap(find.text('À propos'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('Statistics test', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Open drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Navigate to statistics
      await tester.tap(find.text('Statistiques'));
      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsAtLeastNWidgets(3));
    });

    testWidgets('Donation dialog test', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Open drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Navigate to support project
      await tester.tap(find.text('Soutenir le projet'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
    });
  });
}
