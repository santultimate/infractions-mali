import 'package:flutter_test/flutter_test.dart';
import 'package:infractions_mali/services/performance_service.dart';
import 'package:infractions_mali/services/analytics_service.dart';

void main() {
  group('Performance Tests', () {
    late PerformanceService performanceService;
    late AnalyticsService analyticsService;

    setUp(() {
      performanceService = PerformanceService();
      analyticsService = AnalyticsService();
    });

    test('Performance service initialization', () {
      expect(performanceService, isNotNull);
      expect(performanceService.getPerformanceStats(), isEmpty);
    });

    test('Timer functionality', () {
      performanceService.startTimer('test_operation');

      // Simulate some work
      for (int i = 0; i < 1000; i++) {
        // Do some work
      }

      performanceService.stopTimer('test_operation');

      final stats = performanceService.getPerformanceStats();
      expect(stats, isNotEmpty);
      expect(stats.containsKey('test_operation'), isTrue);
    });

    test('Async operation measurement', () async {
      final result = await performanceService.measureAsync(
        'async_test',
        () async {
          await Future.delayed(const Duration(milliseconds: 50));
          return 'test_result';
        },
      );

      expect(result, equals('test_result'));

      final stats = performanceService.getPerformanceStats();
      expect(stats.containsKey('async_test'), isTrue);
    });

    test('Sync operation measurement', () {
      final result = performanceService.measureSync(
        'sync_test',
        () {
          // Simulate some work
          int sum = 0;
          for (int i = 0; i < 1000; i++) {
            sum += i;
          }
          return sum;
        },
      );

      expect(result, isA<int>());

      final stats = performanceService.getPerformanceStats();
      expect(stats.containsKey('sync_test'), isTrue);
    });

    test('Multiple operations tracking', () {
      for (int i = 0; i < 5; i++) {
        performanceService.startTimer('operation_$i');
        // Simulate work
        for (int j = 0; j < 100; j++) {
          // Do work
        }
        performanceService.stopTimer('operation_$i');
      }

      final stats = performanceService.getPerformanceStats();
      expect(stats.length, equals(5));

      for (int i = 0; i < 5; i++) {
        expect(stats.containsKey('operation_$i'), isTrue);
      }
    });

    test('Slow operations detection', () {
      performanceService.startTimer('slow_operation');

      // Simulate slow work
      for (int i = 0; i < 100000; i++) {
        // Heavy work
      }

      performanceService.stopTimer('slow_operation');

      final slowOperations =
          performanceService.getSlowOperations(thresholdMs: 10);
      expect(slowOperations, isNotEmpty);
      expect(slowOperations.any((op) => op['operation'] == 'slow_operation'),
          isTrue);
    });

    test('Performance log functionality', () {
      performanceService.startTimer('logged_operation');

      // Simulate slow work to trigger logging
      for (int i = 0; i < 100000; i++) {
        // Heavy work
      }

      performanceService.stopTimer('logged_operation');

      final log = performanceService.getPerformanceLog();
      expect(log, isNotEmpty);
      expect(log.any((entry) => entry.contains('logged_operation')), isTrue);
    });

    test('Performance data clearing', () {
      performanceService.startTimer('test_clear');
      performanceService.stopTimer('test_clear');

      expect(performanceService.getPerformanceStats(), isNotEmpty);

      performanceService.clearPerformanceData();

      expect(performanceService.getPerformanceStats(), isEmpty);
      expect(performanceService.getPerformanceLog(), isEmpty);
    });

    test('List performance monitoring', () {
      final testList = List.generate(1000, (index) => 'item_$index');

      final monitoredList = performanceService.monitorListPerformance(
        testList,
        'list_operation',
      );

      expect(monitoredList.length, equals(1000));

      final stats = performanceService.getPerformanceStats();
      expect(stats.containsKey('list_operation'), isTrue);
    });

    test('Map performance monitoring', () {
      final testMap = Map.fromEntries(
        List.generate(1000, (index) => MapEntry('key_$index', 'value_$index')),
      );

      final monitoredMap = performanceService.monitorMapPerformance(
        testMap,
        'map_operation',
      );

      expect(monitoredMap.length, equals(1000));

      final stats = performanceService.getPerformanceStats();
      expect(stats.containsKey('map_operation'), isTrue);
    });

    test('Performance summary generation', () {
      // Add some test data
      for (int i = 0; i < 3; i++) {
        performanceService.startTimer('summary_test_$i');
        // Simulate work
        for (int j = 0; j < 1000; j++) {
          // Do work
        }
        performanceService.stopTimer('summary_test_$i');
      }

      final summary = performanceService.getPerformanceSummary();
      expect(summary, isNotEmpty);
      expect(summary.contains('Performance Summary'), isTrue);
      expect(summary.contains('summary_test_0'), isTrue);
      expect(summary.contains('summary_test_1'), isTrue);
      expect(summary.contains('summary_test_2'), isTrue);
    });
  });

  group('Analytics Performance Tests', () {
    late AnalyticsService analyticsService;

    setUp(() async {
      analyticsService = AnalyticsService();
      await analyticsService.initialize();
    });

    test('Analytics initialization performance', () async {
      final stopwatch = Stopwatch()..start();

      await analyticsService.initialize();

      stopwatch.stop();
      expect(stopwatch.elapsed.inMilliseconds, lessThan(100));
    });

    test('Alert tracking performance', () async {
      final stopwatch = Stopwatch()..start();

      await analyticsService.trackAlertCreated(
        alertType: 'radar_mobile',
        latitude: 12.65,
        longitude: -8.0,
      );

      stopwatch.stop();
      expect(stopwatch.elapsed.inMilliseconds, lessThan(50));
    });

    test('Comment tracking performance', () async {
      final stopwatch = Stopwatch()..start();

      await analyticsService.trackCommentCreated(
        alertId: 'test_alert',
        commentLength: 50,
      );

      stopwatch.stop();
      expect(stopwatch.elapsed.inMilliseconds, lessThan(50));
    });

    test('User login tracking performance', () async {
      final stopwatch = Stopwatch()..start();

      await analyticsService.trackUserLogin(
        provider: 'google',
        isNewUser: false,
      );

      stopwatch.stop();
      expect(stopwatch.elapsed.inMilliseconds, lessThan(50));
    });

    test('Feature usage tracking performance', () async {
      final stopwatch = Stopwatch()..start();

      await analyticsService.trackFeatureUsage(
        featureName: 'map_navigation',
        parameters: {'screen': 'community_map'},
      );

      stopwatch.stop();
      expect(stopwatch.elapsed.inMilliseconds, lessThan(50));
    });

    test('Analytics data retrieval performance', () async {
      // Add some test data first
      await analyticsService.trackAlertCreated(
        alertType: 'test_type',
        latitude: 0.0,
        longitude: 0.0,
      );

      final stopwatch = Stopwatch()..start();

      final data = analyticsService.getAnalyticsData();

      stopwatch.stop();
      expect(stopwatch.elapsed.inMilliseconds, lessThan(50));
      expect(data, isNotEmpty);
    });

    test('Session duration calculation performance', () {
      final stopwatch = Stopwatch()..start();

      final duration = analyticsService.getSessionDuration();

      stopwatch.stop();
      expect(stopwatch.elapsed.inMilliseconds, lessThan(10));
      expect(duration, isA<int>());
    });

    test('User activity check performance', () {
      final stopwatch = Stopwatch()..start();

      final isActive = analyticsService.isUserActive();

      stopwatch.stop();
      expect(stopwatch.elapsed.inMilliseconds, lessThan(10));
      expect(isActive, isA<bool>());
    });

    test('Multiple analytics operations performance', () async {
      final stopwatch = Stopwatch()..start();

      // Perform multiple analytics operations
      await Future.wait([
        analyticsService.trackAlertCreated(
          alertType: 'type1',
          latitude: 1.0,
          longitude: 1.0,
        ),
        analyticsService.trackCommentCreated(
          alertId: 'alert1',
          commentLength: 30,
        ),
        analyticsService.trackUserLogin(
          provider: 'facebook',
          isNewUser: true,
        ),
        analyticsService.trackFeatureUsage(
          featureName: 'search',
          parameters: {'query_length': 10},
        ),
      ]);

      stopwatch.stop();
      expect(stopwatch.elapsed.inMilliseconds, lessThan(200));
    });
  });

  group('Integration Performance Tests', () {
    test('Combined performance and analytics operations', () async {
      final performanceService = PerformanceService();
      final analyticsService = AnalyticsService();

      await analyticsService.initialize();

      // Measure analytics operations with performance service
      await performanceService.measureAsync(
        'analytics_operations',
        () async {
          await analyticsService.trackAlertCreated(
            alertType: 'integration_test',
            latitude: 12.65,
            longitude: -8.0,
          );

          await analyticsService.trackCommentCreated(
            alertId: 'integration_alert',
            commentLength: 100,
          );

          await analyticsService.trackUserLogin(
            provider: 'google',
            isNewUser: false,
          );
        },
      );

      final stats = performanceService.getPerformanceStats();
      expect(stats.containsKey('analytics_operations'), isTrue);

      final analyticsData = analyticsService.getAnalyticsData();
      expect(analyticsData, isNotEmpty);
    });
  });
}
