import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:developer' as developer;

class PerformanceService {
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();

  final Map<String, Stopwatch> _timers = {};
  final Map<String, List<Duration>> _measurements = {};
  final Map<String, int> _operationCounts = {};
  final List<String> _performanceLog = [];

  /// Start timing an operation
  void startTimer(String operationName) {
    if (kReleaseMode) return; // Only track in debug mode

    _timers[operationName] = Stopwatch()..start();
    _operationCounts[operationName] =
        (_operationCounts[operationName] ?? 0) + 1;

    developer.log('Performance: Started timing $operationName',
        name: 'PerformanceService');
  }

  /// Stop timing an operation and record the duration
  void stopTimer(String operationName) {
    if (kReleaseMode) return; // Only track in debug mode

    final timer = _timers[operationName];
    if (timer == null) {
      debugPrint('Performance: Timer not found for $operationName');
      return;
    }

    timer.stop();
    final duration = timer.elapsed;

    _measurements.putIfAbsent(operationName, () => []).add(duration);
    _timers.remove(operationName);

    // Log if operation takes too long
    if (duration.inMilliseconds > 100) {
      _performanceLog
          .add('SLOW: $operationName took ${duration.inMilliseconds}ms');
      developer.log(
          'Performance: SLOW operation $operationName took ${duration.inMilliseconds}ms',
          name: 'PerformanceService');
    } else {
      developer.log(
          'Performance: $operationName completed in ${duration.inMilliseconds}ms',
          name: 'PerformanceService');
    }
  }

  /// Measure a function execution time
  Future<T> measureAsync<T>(
      String operationName, Future<T> Function() operation) async {
    startTimer(operationName);
    try {
      final result = await operation();
      stopTimer(operationName);
      return result;
    } catch (e) {
      stopTimer(operationName);
      rethrow;
    }
  }

  /// Measure a synchronous function execution time
  T measureSync<T>(String operationName, T Function() operation) {
    startTimer(operationName);
    try {
      final result = operation();
      stopTimer(operationName);
      return result;
    } catch (e) {
      stopTimer(operationName);
      rethrow;
    }
  }

  /// Get performance statistics
  Map<String, dynamic> getPerformanceStats() {
    if (kReleaseMode) return {};

    final stats = <String, dynamic>{};

    for (final entry in _measurements.entries) {
      final operationName = entry.key;
      final durations = entry.value;

      if (durations.isEmpty) continue;

      final totalDuration = durations.fold<Duration>(
          Duration.zero, (sum, duration) => sum + duration);

      final averageDuration = Duration(
          microseconds: totalDuration.inMicroseconds ~/ durations.length);

      final maxDuration = durations.reduce((a, b) => a > b ? a : b);
      final minDuration = durations.reduce((a, b) => a < b ? a : b);

      stats[operationName] = {
        'count': durations.length,
        'total_time_ms': totalDuration.inMilliseconds,
        'average_time_ms': averageDuration.inMilliseconds,
        'max_time_ms': maxDuration.inMilliseconds,
        'min_time_ms': minDuration.inMilliseconds,
        'operation_count': _operationCounts[operationName] ?? 0,
      };
    }

    return stats;
  }

  /// Get slow operations (operations taking more than threshold)
  List<Map<String, dynamic>> getSlowOperations({int thresholdMs = 100}) {
    if (kReleaseMode) return [];

    final slowOperations = <Map<String, dynamic>>[];

    for (final entry in _measurements.entries) {
      final operationName = entry.key;
      final durations = entry.value;

      final slowDurations =
          durations.where((d) => d.inMilliseconds > thresholdMs).toList();

      if (slowDurations.isNotEmpty) {
        slowOperations.add({
          'operation': operationName,
          'slow_count': slowDurations.length,
          'total_count': durations.length,
          'slow_percentage':
              (slowDurations.length / durations.length * 100).roundToDouble(),
          'average_slow_time_ms':
              slowDurations.fold<int>(0, (sum, d) => sum + d.inMilliseconds) ~/
                  slowDurations.length,
        });
      }
    }

    return slowOperations;
  }

  /// Get performance log
  List<String> getPerformanceLog() {
    return List.from(_performanceLog);
  }

  /// Clear performance data
  void clearPerformanceData() {
    _timers.clear();
    _measurements.clear();
    _operationCounts.clear();
    _performanceLog.clear();

    developer.log('Performance: Data cleared', name: 'PerformanceService');
  }

  /// Monitor widget build performance
  Widget wrapWithPerformanceMonitor(Widget child, String widgetName) {
    if (kReleaseMode) return child;

    return PerformanceMonitor(
      name: widgetName,
      child: child,
    );
  }

  /// Monitor list performance
  List<T> monitorListPerformance<T>(List<T> list, String operationName) {
    if (kReleaseMode) return list;

    startTimer(operationName);
    final result = List<T>.from(list);
    stopTimer(operationName);

    return result;
  }

  /// Monitor map performance
  Map<K, V> monitorMapPerformance<K, V>(Map<K, V> map, String operationName) {
    if (kReleaseMode) return map;

    startTimer(operationName);
    final result = Map<K, V>.from(map);
    stopTimer(operationName);

    return result;
  }

  /// Check memory usage (approximate)
  void logMemoryUsage(String context) {
    if (kReleaseMode) return;

    // This is a simplified memory check
    // In a real app, you might use platform-specific APIs
    developer.log('Memory: Context $context', name: 'PerformanceService');
  }

  /// Monitor network request performance
  Future<T> monitorNetworkRequest<T>(
    String requestName,
    Future<T> Function() request,
  ) async {
    return measureAsync('network_$requestName', request);
  }

  /// Monitor database operation performance
  Future<T> monitorDatabaseOperation<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    return measureAsync('database_$operationName', operation);
  }

  /// Monitor file operation performance
  Future<T> monitorFileOperation<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    return measureAsync('file_$operationName', operation);
  }

  /// Get performance summary
  String getPerformanceSummary() {
    if (kReleaseMode) return 'Performance monitoring disabled in release mode';

    final stats = getPerformanceStats();
    final slowOperations = getSlowOperations();

    final summary = StringBuffer();
    summary.writeln('=== Performance Summary ===');
    summary.writeln('Total operations tracked: ${stats.length}');

    if (stats.isNotEmpty) {
      summary.writeln('\n=== Operation Statistics ===');
      for (final entry in stats.entries) {
        final data = entry.value as Map<String, dynamic>;
        summary.writeln('${entry.key}:');
        summary.writeln('  Count: ${data['count']}');
        summary.writeln('  Average: ${data['average_time_ms']}ms');
        summary.writeln('  Max: ${data['max_time_ms']}ms');
        summary.writeln('  Min: ${data['min_time_ms']}ms');
      }
    }

    if (slowOperations.isNotEmpty) {
      summary.writeln('\n=== Slow Operations ===');
      for (final operation in slowOperations) {
        summary.writeln(
            '${operation['operation']}: ${operation['slow_count']}/${operation['total_count']} slow (${operation['slow_percentage']}%)');
      }
    }

    return summary.toString();
  }
}

/// Widget wrapper for performance monitoring
class PerformanceMonitor extends StatefulWidget {
  final String name;
  final Widget child;

  const PerformanceMonitor({
    Key? key,
    required this.name,
    required this.child,
  }) : super(key: key);

  @override
  State<PerformanceMonitor> createState() => _PerformanceMonitorState();
}

class _PerformanceMonitorState extends State<PerformanceMonitor> {
  @override
  void initState() {
    super.initState();
    PerformanceService().startTimer('widget_build_${widget.name}');
  }

  @override
  void dispose() {
    PerformanceService().stopTimer('widget_build_${widget.name}');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Mixin for performance monitoring in StatefulWidget
mixin PerformanceMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    PerformanceService().startTimer('widget_init_${widget.runtimeType}');
  }

  @override
  void dispose() {
    PerformanceService().stopTimer('widget_init_${widget.runtimeType}');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    PerformanceService().startTimer('widget_build_${widget.runtimeType}');
    final result = buildWithPerformance(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PerformanceService().stopTimer('widget_build_${widget.runtimeType}');
    });
    return result;
  }

  Widget buildWithPerformance(BuildContext context);
}
