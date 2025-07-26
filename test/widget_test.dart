import 'package:mocktail/mocktail.dart';

class MockAlertService extends Mock implements AlertService {}

void main() {
  final mockAlertService = MockAlertService();
  
  testWidgets('Test description', (tester) async {
    when(() => mockAlertService.method()).thenReturn(value);
    // Your test code
  });
}