import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:infractions_mali/main.dart';
import 'package:infractions_mali/screens/home_screen.dart';
import 'test_helpers.dart'; // Import the helpers

void main() {
  late MockAlertService mockAlertService;

  setUpAll(() {
    setupTestMocks(); // Initialize all mocks
  });

  setUp(() {
    mockAlertService = MockAlertService();
    
    // Setup default mock behaviors
    when(() => mockAlertService.getAlertsNearLocation(
      any(),
      any(),
      radiusInKm: any(named: 'radiusInKm'),
      userId: any(named: 'userId'),
    )).thenAnswer((_) async => []);
  });

  testWidgets('App launches', (tester) async {
    await tester.pumpWidget(InfractionsApp(alertService: mockAlertService));
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}