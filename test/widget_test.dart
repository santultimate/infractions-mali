import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:infractions_mali/test/test_helpers.dart';
import 'package:infractions_mali/main.dart';

void main() {
  late MockAlertService mockAlertService;

  setUpAll(() {
    mockAlertService = MockAlertService();
    setupTestMocks();
  });

  testWidgets('App launches', (tester) async {
    await tester.pumpWidget(InfractionsApp(alertService: mockAlertService));
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}