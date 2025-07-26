import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
// import 'package:infractions_mali/test/test_helpers.dart';
import 'package:infractions_mali/main.dart';
import 'package:infractions_mali/screens/home_screen.dart';

// Add this import if AlertService is defined elsewhere
import 'package:infractions_mali/services/alert_service.dart';

class MockAlertService extends Mock implements AlertService {}

void main() {
  late AlertService mockAlertService;

  setUpAll(() {
    mockAlertService = MockAlertService();
    // setupTestMocks();
  });

  testWidgets('App launches', (tester) async {
    await tester.pumpWidget(InfractionsApp(alertService: mockAlertService));
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}