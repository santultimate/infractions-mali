import 'package:mocktail/mocktail.dart';
import 'package:infractions_mali/services/alert_service.dart';

class MockAlertService extends Mock implements AlertService {}

// Initialize all mock services
void registerFallbacks() {
  // Register fallback values for complex types
  registerFallbackValue(MockAlertService());
  // Add other fallbacks as needed
}

void setupTestMocks() {
  registerFallbacks();
  // Add any default mock behaviors here
}