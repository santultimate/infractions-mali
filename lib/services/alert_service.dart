import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/alert.dart';

class AlertService {
  static const String _baseUrl = 'https://api.waze.com/row-rtserver/web/TGeoRSS';
  static const double _metersPerDegree = 111000;
  final FirebaseFirestore _firestore;

  // Inject Firestore for testability
  AlertService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _alertsCollection => _firestore.collection('alerts');

  Future<List<Alert>> getAlertsNearLocation(
    double latitude,
    double longitude, {
    double radiusInKm = 5.0,
    required String? userId,
    int limit = 50,
  }) async {
    try {
      final radiusInMeters = radiusInKm * 1000;
      final degreeDelta = radiusInMeters / _metersPerDegree;

      final querySnapshot = await _alertsCollection
          .where('location', isGreaterThan: GeoPoint(
            latitude - degreeDelta,
            longitude - degreeDelta,
          ))
          .where('location', isLessThan: GeoPoint(
            latitude + degreeDelta,
            longitude + degreeDelta,
          ))
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => Alert.fromFirestore(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .where((alert) => _distanceBetween(
                latitude,
                longitude,
                alert.location['latitude']!,
                alert.location['longitude']!,
              ) <= radiusInMeters)
          .toList();
    } catch (e) {
      debugPrint('Error fetching alerts: $e');
      throw Exception('Failed to load alerts');
    }
  }

  double _distanceBetween(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  Future<bool> submitAlert({
    required AlertType type,
    required String title,
    required String description,
    required Map<String, double> location,
    required String userId,
    required String createdBy,
    List<String> photos = const [],
    int retryCount = 2,
  }) async {
    try {
      // Validate with Waze
      String? wazeValidation;
      for (var i = 0; i <= retryCount; i++) {
        try {
          wazeValidation = await _validateWithWaze(location, type);
          break;
        } catch (e) {
          if (i == retryCount) rethrow;
          await Future.delayed(const Duration(seconds: 1));
        }
      }

      // Create new alert document
      await _alertsCollection.add({
        'type': type.toString().split('.').last,
        'title': title.trim(),
        'description': description.trim(),
        'location': GeoPoint(location['latitude']!, location['longitude']!),
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        'createdBy': createdBy.trim(),
        'userId': userId,
        'photos': photos,
        'wazeValidation': wazeValidation,
        'credibility': _calculateInitialCredibility(wazeValidation),
        'confirmations': 0,
        'denials': 0,
        'confirmedBy': [],
        'deniedBy': [],
        'isVerified': false,
      });

      return true;
    } catch (e) {
      debugPrint('Error submitting alert: $e');
      return false;
    }
  }

  Future<void> confirmAlert({
    required String alertId,
    required String userId,
    required bool isConfirmed,
  }) async {
    final docRef = _alertsCollection.doc(alertId);

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);
      if (!doc.exists) throw Exception('Alert not found');

      final data = doc.data() as Map<String, dynamic>;
      final confirmedBy = List<String>.from(data['confirmedBy'] ?? []);
      final deniedBy = List<String>.from(data['deniedBy'] ?? []);

      // Remove previous vote if exists
      confirmedBy.remove(userId);
      deniedBy.remove(userId);

      // Add new vote
      if (isConfirmed) {
        confirmedBy.add(userId);
      } else {
        deniedBy.add(userId);
      }

      // Update document
      transaction.update(docRef, {
        'confirmedBy': confirmedBy,
        'deniedBy': deniedBy,
        'confirmations': confirmedBy.length,
        'denials': deniedBy.length,
        'credibility': _calculateCredibility(confirmedBy.length, deniedBy.length),
        'updatedAt': Timestamp.now(),
      });
    });
  }

  Future<String?> _validateWithWaze(
      Map<String, double> location,
      AlertType type,
      ) async {
    try {
      final response = await http.get(Uri.parse(
        '$_baseUrl?top=${location['latitude']! + 0.01}'
            '&left=${location['longitude']! - 0.01}'
            '&bottom=${location['latitude']! - 0.01}'
            '&right=${location['longitude']! + 0.01}'
            '&types=traffic,alerts',
      ));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _analyzeWazeData(data, type, location);
      }
      return null;
    } catch (e) {
      debugPrint('Waze validation error: $e');
      return null;
    }
  }

  String? _analyzeWazeData(Map<String, dynamic> data, AlertType type, Map<String, double> location) {
    try {
      final alerts = data['alerts'] as List?;
      if (alerts == null) return null;

      // Check for matching alerts within 500m
      final matchingAlerts = alerts.where((alert) {
        final alertLocation = alert['location'] as Map?;
        if (alertLocation == null) return false;

        final alertLat = alertLocation['y'] as double;
        final alertLon = alertLocation['x'] as double;
        final distance = _distanceBetween(
          location['latitude']!,
          location['longitude']!,
          alertLat,
          alertLon,
        );

        return distance <= 500 && _matchesAlertType(alert, type);
      });

      return matchingAlerts.isNotEmpty ? 'confirmed' : null;
    } catch (e) {
      debugPrint('Error analyzing Waze data: $e');
      return null;
    }
  }

  bool _matchesAlertType(Map alert, AlertType type) {
    // Implement actual type matching logic
    final wazeType = alert['type'] as String?;
    if (wazeType == null) return false;

    return switch (type) {
      AlertType.radarMobile => wazeType.contains('POLICE'),
      AlertType.accident => wazeType.contains('ACCIDENT'),
      AlertType.hazard => wazeType.contains('HAZARD'),
      AlertType.trafficJam => wazeType.contains('JAM'),
      AlertType.roadClosed => wazeType.contains('ROAD_CLOSED'),
      _ => false,
    };
  }

  double _calculateInitialCredibility(String? wazeValidation) {
    return switch (wazeValidation) {
      'confirmed' => 4.5,
      'partial' => 3.5,
      _ => 3.0,
    };
  }

  double _calculateCredibility(int confirmations, int denials) {
    final total = confirmations + denials;
    if (total == 0) return 3.0;
    final score = (confirmations * 5 + denials * 1) / total;
    return score.clamp(1.0, 5.0);
  }
}