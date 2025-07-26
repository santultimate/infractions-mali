import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infractions_mali/main.dart';
import 'package:infractions_mali/screens/home_screen.dart';
import 'package:infractions_mali/screens/community_map_screen.dart';
import 'package:infractions_mali/screens/interactive_map_screen.dart';
import 'package:infractions_mali/services/alert_service.dart';
import 'package:mockito/mockito.dart';

// Mock classes for dependencies
class MockAlertService extends Mock implements AlertService {}

void main() {
  // Initialize mock services
  final mockAlertService = MockAlertService();

  group('App Navigation Tests', () {
    testWidgets('App launches and shows home screen', (WidgetTester tester) async {
      // Build our app with mocked dependencies
      await tester.pumpWidget(
        MaterialApp(
          home: InfractionsApp(alertService: mockAlertService),
        ),
      );

      // Verify home screen is shown
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(CommunityMapScreen), findsNothing);
    });

    testWidgets('Navigation to community map screen works', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: InfractionsApp(alertService: mockAlertService),
        ),
      );

      // Tap on the map navigation item
      await tester.tap(find.byKey(const Key('map_navigation_button')));
      await tester.pumpAndSettle();

      // Verify community map screen is shown
      expect(find.byType(CommunityMapScreen), findsOneWidget);
    });
  });

  group('CommunityMapScreen Tests', () {
    testWidgets('Shows loading indicator initially', (WidgetTester tester) async {
      // Setup mock data
      when(mockAlertService.getAlertsNearLocation(
        any,
        any,
        radiusInKm: anyNamed('radiusInKm'),
        userId: anyNamed('userId'),
      )).thenAnswer((_) async => []);

      await tester.pumpWidget(
        MaterialApp(
          home: CommunityMapScreen(alertService: mockAlertService),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Displays alerts after loading', (WidgetTester tester) async {
      // Setup mock data
      final testAlerts = [
        Alert(
          id: '1',
          type: AlertType.radarMobile,
          title: 'Radar mobile',
          description: 'Radar control in progress',
          location: {'latitude': 12.65, 'longitude': -8.0},
          createdAt: DateTime.now(),
          userId: 'user1',
          createdBy: 'Test User',
        ),
      ];

      when(mockAlertService.getAlertsNearLocation(
        any,
        any,
        radiusInKm: anyNamed('radiusInKm'),
        userId: anyNamed('userId'),
      )).thenAnswer((_) async => testAlerts);

      await tester.pumpWidget(
        MaterialApp(
          home: CommunityMapScreen(alertService: mockAlertService),
        ),
      );

      // Initial loading state
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete loading
      await tester.pumpAndSettle();

      // Verify alerts are displayed
      expect(find.byType(ListTile), findsNWidgets(testAlerts.length));
      expect(find.text('Radar mobile'), findsOneWidget);
    });
  });

  group('HomeScreen Tests', () {
    testWidgets('Displays infraction categories', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(alertService: mockAlertService),
        ),
      );

      expect(find.text('Radars'), findsOneWidget);
      expect(find.text('Police Checks'), findsOneWidget);
      expect(find.text('Accidents'), findsOneWidget);
    });

    testWidgets('Navigation to infraction details works', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(alertService: mockAlertService),
        ),
      );

      // Tap on first infraction category
      await tester.tap(find.byKey(const Key('radar_category')).first);
      await tester.pumpAndSettle();

      // Verify details screen is shown
      expect(find.byType(AlertDialog), findsOneWidget);
    });
  });
}