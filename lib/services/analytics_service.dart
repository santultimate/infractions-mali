import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnalyticsService {
  static const String _prefsKey = 'analytics_data';
  static const String _sessionStartKey = 'session_start';
  static const String _totalSessionsKey = 'total_sessions';
  static const String _totalAlertsKey = 'total_alerts';
  static const String _totalCommentsKey = 'total_comments';
  static const String _totalReportsKey = 'total_reports';
  static const String _lastActiveKey = 'last_active';

  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  late SharedPreferences _prefs;
  bool _isInitialized = false;

  /// Initialize the analytics service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
      _startSession();
      debugPrint('Analytics service initialized successfully');
    } catch (e) {
      debugPrint('Analytics initialization error: $e');
    }
  }

  /// Start a new session
  void _startSession() {
    final now = DateTime.now();
    _prefs.setString(_sessionStartKey, now.toIso8601String());

    final totalSessions = _prefs.getInt(_totalSessionsKey) ?? 0;
    _prefs.setInt(_totalSessionsKey, totalSessions + 1);

    _updateLastActive();
  }

  /// Track alert creation
  Future<void> trackAlertCreated({
    required String alertType,
    required double latitude,
    required double longitude,
  }) async {
    if (!_isInitialized) return;

    try {
      final totalAlerts = _prefs.getInt(_totalAlertsKey) ?? 0;
      _prefs.setInt(_totalAlertsKey, totalAlerts + 1);

      // Track alert type
      final alertTypeKey = 'alert_type_$alertType';
      final alertTypeCount = _prefs.getInt(alertTypeKey) ?? 0;
      _prefs.setInt(alertTypeKey, alertTypeCount + 1);

      // Track location data (general area)
      final locationKey =
          'location_${(latitude * 100).round()}_${(longitude * 100).round()}';
      final locationCount = _prefs.getInt(locationKey) ?? 0;
      _prefs.setInt(locationKey, locationCount + 1);

      _updateLastActive();
      debugPrint('Alert created tracked: $alertType at $latitude, $longitude');
    } catch (e) {
      debugPrint('Error tracking alert creation: $e');
    }
  }

  /// Track comment creation
  Future<void> trackCommentCreated({
    required String alertId,
    required int commentLength,
  }) async {
    if (!_isInitialized) return;

    try {
      final totalComments = _prefs.getInt(_totalCommentsKey) ?? 0;
      _prefs.setInt(_totalCommentsKey, totalComments + 1);

      // Track comment length distribution
      final lengthCategory = _getCommentLengthCategory(commentLength);
      final lengthKey = 'comment_length_$lengthCategory';
      final lengthCount = _prefs.getInt(lengthKey) ?? 0;
      _prefs.setInt(lengthKey, lengthCount + 1);

      _updateLastActive();
      debugPrint('Comment created tracked: length $commentLength');
    } catch (e) {
      debugPrint('Error tracking comment creation: $e');
    }
  }

  /// Track alert confirmation/denial
  Future<void> trackAlertVote({
    required String alertId,
    required bool isConfirmed,
  }) async {
    if (!_isInitialized) return;

    try {
      final voteType = isConfirmed ? 'confirmations' : 'denials';
      final voteKey = 'alert_votes_$voteType';
      final voteCount = _prefs.getInt(voteKey) ?? 0;
      _prefs.setInt(voteKey, voteCount + 1);

      _updateLastActive();
      debugPrint('Alert vote tracked: ${isConfirmed ? 'confirmed' : 'denied'}');
    } catch (e) {
      debugPrint('Error tracking alert vote: $e');
    }
  }

  /// Track alert reporting
  Future<void> trackAlertReported({
    required String alertId,
    required String reason,
  }) async {
    if (!_isInitialized) return;

    try {
      final totalReports = _prefs.getInt(_totalReportsKey) ?? 0;
      _prefs.setInt(_totalReportsKey, totalReports + 1);

      // Track report reasons
      final reasonKey = 'report_reason_$reason';
      final reasonCount = _prefs.getInt(reasonKey) ?? 0;
      _prefs.setInt(reasonKey, reasonCount + 1);

      _updateLastActive();
      debugPrint('Alert reported tracked: $reason');
    } catch (e) {
      debugPrint('Error tracking alert report: $e');
    }
  }

  /// Track user authentication
  Future<void> trackUserLogin({
    required String provider,
    required bool isNewUser,
  }) async {
    if (!_isInitialized) return;

    try {
      // Track login provider
      final providerKey = 'login_provider_$provider';
      final providerCount = _prefs.getInt(providerKey) ?? 0;
      _prefs.setInt(providerKey, providerCount + 1);

      // Track new vs returning users
      final userType = isNewUser ? 'new_users' : 'returning_users';
      final userTypeKey = 'user_type_$userType';
      final userTypeCount = _prefs.getInt(userTypeKey) ?? 0;
      _prefs.setInt(userTypeKey, userTypeCount + 1);

      _updateLastActive();
      debugPrint(
          'User login tracked: $provider, ${isNewUser ? 'new' : 'returning'}');
    } catch (e) {
      debugPrint('Error tracking user login: $e');
    }
  }

  /// Track feature usage
  Future<void> trackFeatureUsage({
    required String featureName,
    Map<String, dynamic>? parameters,
  }) async {
    if (!_isInitialized) return;

    try {
      final featureKey = 'feature_usage_$featureName';
      final featureCount = _prefs.getInt(featureKey) ?? 0;
      _prefs.setInt(featureKey, featureCount + 1);

      if (parameters != null) {
        for (final entry in parameters.entries) {
          final paramKey = 'feature_${featureName}_${entry.key}';
          final paramValue = entry.value.toString();
          final paramCount = _prefs.getInt('${paramKey}_$paramValue') ?? 0;
          _prefs.setInt('${paramKey}_$paramValue', paramCount + 1);
        }
      }

      _updateLastActive();
      debugPrint('Feature usage tracked: $featureName');
    } catch (e) {
      debugPrint('Error tracking feature usage: $e');
    }
  }

  /// Track error occurrences
  Future<void> trackError({
    required String errorType,
    required String errorMessage,
    String? stackTrace,
  }) async {
    if (!_isInitialized) return;

    try {
      final errorKey = 'error_type_$errorType';
      final errorCount = _prefs.getInt(errorKey) ?? 0;
      _prefs.setInt(errorKey, errorCount + 1);

      // Store last error for debugging
      _prefs.setString('last_error_type', errorType);
      _prefs.setString('last_error_message', errorMessage);
      if (stackTrace != null) {
        _prefs.setString('last_error_stack', stackTrace);
      }

      _updateLastActive();
      debugPrint('Error tracked: $errorType - $errorMessage');
    } catch (e) {
      debugPrint('Error tracking error: $e');
    }
  }

  /// Get analytics data
  Map<String, dynamic> getAnalyticsData() {
    if (!_isInitialized) return {};

    try {
      return {
        'total_sessions': _prefs.getInt(_totalSessionsKey) ?? 0,
        'total_alerts': _prefs.getInt(_totalAlertsKey) ?? 0,
        'total_comments': _prefs.getInt(_totalCommentsKey) ?? 0,
        'total_reports': _prefs.getInt(_totalReportsKey) ?? 0,
        'last_active': _prefs.getString(_lastActiveKey),
        'session_start': _prefs.getString(_sessionStartKey),
        'alert_types': _getAlertTypeStats(),
        'login_providers': _getLoginProviderStats(),
        'feature_usage': _getFeatureUsageStats(),
        'error_stats': _getErrorStats(),
      };
    } catch (e) {
      debugPrint('Error getting analytics data: $e');
      return {};
    }
  }

  /// Clear analytics data
  Future<void> clearAnalyticsData() async {
    if (!_isInitialized) return;

    try {
      await _prefs.clear();
      debugPrint('Analytics data cleared');
    } catch (e) {
      debugPrint('Error clearing analytics data: $e');
    }
  }

  /// Update last active timestamp
  void _updateLastActive() {
    final now = DateTime.now();
    _prefs.setString(_lastActiveKey, now.toIso8601String());
  }

  /// Get comment length category
  String _getCommentLengthCategory(int length) {
    if (length < 10) return 'short';
    if (length < 50) return 'medium';
    if (length < 100) return 'long';
    return 'very_long';
  }

  /// Get alert type statistics
  Map<String, int> _getAlertTypeStats() {
    final stats = <String, int>{};
    final keys = _prefs.getKeys();

    for (final key in keys) {
      if (key.startsWith('alert_type_')) {
        final alertType = key.replaceFirst('alert_type_', '');
        stats[alertType] = _prefs.getInt(key) ?? 0;
      }
    }

    return stats;
  }

  /// Get login provider statistics
  Map<String, int> _getLoginProviderStats() {
    final stats = <String, int>{};
    final keys = _prefs.getKeys();

    for (final key in keys) {
      if (key.startsWith('login_provider_')) {
        final provider = key.replaceFirst('login_provider_', '');
        stats[provider] = _prefs.getInt(key) ?? 0;
      }
    }

    return stats;
  }

  /// Get feature usage statistics
  Map<String, int> _getFeatureUsageStats() {
    final stats = <String, int>{};
    final keys = _prefs.getKeys();

    for (final key in keys) {
      if (key.startsWith('feature_usage_')) {
        final feature = key.replaceFirst('feature_usage_', '');
        stats[feature] = _prefs.getInt(key) ?? 0;
      }
    }

    return stats;
  }

  /// Get error statistics
  Map<String, int> _getErrorStats() {
    final stats = <String, int>{};
    final keys = _prefs.getKeys();

    for (final key in keys) {
      if (key.startsWith('error_type_')) {
        final errorType = key.replaceFirst('error_type_', '');
        stats[errorType] = _prefs.getInt(key) ?? 0;
      }
    }

    return stats;
  }

  /// Get session duration in minutes
  int getSessionDuration() {
    if (!_isInitialized) return 0;

    try {
      final sessionStart = _prefs.getString(_sessionStartKey);
      if (sessionStart == null) return 0;

      final start = DateTime.parse(sessionStart);
      final now = DateTime.now();
      return now.difference(start).inMinutes;
    } catch (e) {
      debugPrint('Error calculating session duration: $e');
      return 0;
    }
  }

  /// Check if user is active (used app in last 7 days)
  bool isUserActive() {
    if (!_isInitialized) return false;

    try {
      final lastActive = _prefs.getString(_lastActiveKey);
      if (lastActive == null) return false;

      final lastActiveDate = DateTime.parse(lastActive);
      final now = DateTime.now();
      final difference = now.difference(lastActiveDate).inDays;

      return difference <= 7;
    } catch (e) {
      debugPrint('Error checking user activity: $e');
      return false;
    }
  }
}
