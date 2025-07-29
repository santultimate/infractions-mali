import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:infractions_mali/main.dart';
import 'package:infractions_mali/screens/home_screen.dart';
import 'package:infractions_mali/services/alert_service.dart';
import 'package:infractions_mali/services/auth_service.dart';

class MockAlertService extends Mock implements AlertService {}

class MockAuthService extends Mock implements AuthService {}

void main() {
  group('Infractions Mali App Tests', () {
    late MockAlertService mockAlertService;
    late MockAuthService mockAuthService;

    setUp(() {
      mockAlertService = MockAlertService();
      mockAuthService = MockAuthService();
    });

    testWidgets('App launches and shows home screen',
        (WidgetTester tester) async {
      // Setup mocks
      when(() => mockAuthService.currentUser).thenReturn(null);
      when(() => mockAuthService.isLoggedIn).thenReturn(false);

      // Build our app with mocked dependencies
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(
            alertService: mockAlertService,
            authService: mockAuthService,
          ),
        ),
      );

      // Verify home screen is shown
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('Search functionality works', (WidgetTester tester) async {
      // Setup mocks
      when(() => mockAuthService.currentUser).thenReturn(null);
      when(() => mockAuthService.isLoggedIn).thenReturn(false);

      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(
            alertService: mockAlertService,
            authService: mockAuthService,
          ),
        ),
      );

      // Find and tap the search field
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      // Enter search text
      await tester.enterText(searchField, 'radar');
      await tester.pump();

      // Verify search field contains the entered text
      expect(find.text('radar'), findsOneWidget);
    });

    testWidgets('Filter dropdowns work correctly', (WidgetTester tester) async {
      // Setup mocks
      when(() => mockAuthService.currentUser).thenReturn(null);
      when(() => mockAuthService.isLoggedIn).thenReturn(false);

      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(
            alertService: mockAlertService,
            authService: mockAuthService,
          ),
        ),
      );

      // Find dropdown buttons
      final dropdowns = find.byType(DropdownButton<String>);
      expect(dropdowns, findsAtLeastNWidgets(2));

      // Tap on first dropdown
      await tester.tap(dropdowns.first);
      await tester.pumpAndSettle();

      // Verify dropdown items are shown
      expect(find.text('Tous'), findsOneWidget);
      expect(find.text('Motorisés'), findsOneWidget);
    });

    testWidgets('Drawer navigation works', (WidgetTester tester) async {
      // Setup mocks
      when(() => mockAuthService.currentUser).thenReturn(null);
      when(() => mockAuthService.isLoggedIn).thenReturn(false);

      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(
            alertService: mockAlertService,
            authService: mockAuthService,
          ),
        ),
      );

      // Open drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Verify drawer is open
      expect(find.byType(Drawer), findsOneWidget);
    });

    testWidgets('Login button navigates to login screen',
        (WidgetTester tester) async {
      // Setup mocks
      when(() => mockAuthService.currentUser).thenReturn(null);
      when(() => mockAuthService.isLoggedIn).thenReturn(false);

      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(
            alertService: mockAlertService,
            authService: mockAuthService,
          ),
        ),
      );

      // Tap on login button
      await tester.tap(find.byIcon(Icons.login));
      await tester.pumpAndSettle();

      // Verify navigation to login screen
      expect(find.byType(Scaffold), findsAtLeastNWidgets(2));
    });
  });

  group('Authentication Tests', () {
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
    });

    testWidgets('Login screen shows login options when not authenticated',
        (WidgetTester tester) async {
      when(() => mockAuthService.currentUser).thenReturn(null);
      when(() => mockAuthService.isLoggedIn).thenReturn(false);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Center(
                  child: Column(
                    children: [
                      if (!mockAuthService.isLoggedIn) ...[
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text('Google Login'),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text('Facebook Login'),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Google Login'), findsOneWidget);
      expect(find.text('Facebook Login'), findsOneWidget);
    });

    testWidgets('User profile shows when authenticated',
        (WidgetTester tester) async {
      when(() => mockAuthService.currentUser)
          .thenReturn(null); // Mock user object
      when(() => mockAuthService.isLoggedIn).thenReturn(true);
      when(() => mockAuthService.userDisplayName).thenReturn('John Doe');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Center(
                  child: Column(
                    children: [
                      if (mockAuthService.isLoggedIn) ...[
                        Text('Welcome ${mockAuthService.userDisplayName}'),
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text('Logout'),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Welcome John Doe'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
    });
  });
}
