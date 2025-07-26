import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import '../models/alert.dart';
import '../services/alert_service.dart';
import '../services/auth_service.dart';

class InteractiveMapScreen extends StatefulWidget {
  const InteractiveMapScreen({super.key});

  @override
  State<InteractiveMapScreen> createState() => _InteractiveMapScreenState();
}

class _InteractiveMapScreenState extends State<InteractiveMapScreen> {
  final AlertService _alertService = AlertService();
  final AuthService _authService = AuthService();
  final Distance _distance = const Distance();
  final MapController _mapController = MapController();

  List<Alert> _alerts = [];
  bool _isLoading = true;
  double _radiusKm = 10.0;
  LatLng _center = const LatLng(12.6508, -8.0000); // Default to Bamako
  DateTime? _lastUpdateTime;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    try {
      if (!mounted) return;
      setState(() => _isLoading = true);
      
      final userId = _authService.currentUser?.uid;
      final alerts = await _alertService.getAlertsNearLocation(
        _center.latitude,
        _center.longitude,
        radiusInKm: 50,
        userId: userId,
      );

      if (!mounted) return;
      setState(() {
        _alerts = alerts;
        _lastUpdateTime = DateTime.now();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('error_loading_alerts'.tr())),
        );
        debugPrint('Error loading alerts: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Alert> get _filteredAlerts {
    return _alerts.where((alert) {
      final lat = alert.location['latitude'];
      final lng = alert.location['longitude'];
      if (lat == null || lng == null) return false;
      
      return _distance.as(
        LengthUnit.Kilometer, 
        _center, 
        LatLng(lat, lng),
      ) <= _radiusKm;
    }).toList();
  }

  void _showAlertDetails(Alert alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(alert.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(alert.description),
              const SizedBox(height: 16),
              _buildDetailRow(Icons.category, 'alert_type'.tr(), alert.type.name.tr()),
              _buildDetailRow(Icons.calendar_today, 'posted'.tr(), 
                DateFormat('MMM dd, yyyy - HH:mm').format(alert.createdAt)),
              if (alert.isVerified)
                _buildDetailRow(Icons.verified, 'verified'.tr(), '', isVerified: true),
              if (alert.credibility != null)
                _buildDetailRow(Icons.star, 'credibility'.tr(), 
                  '${alert.credibility!.toStringAsFixed(1)}/5'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('close'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {bool isVerified = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: isVerified ? Colors.green : Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('interactive_map'.tr()),
        actions: [
          if (_lastUpdateTime != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: Text(
                  'updated_at'.tr(args: [DateFormat('HH:mm').format(_lastUpdateTime!)]),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAlerts,
            tooltip: 'refresh'.tr(),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
  mapController: _mapController,
  options: MapOptions(
    center: _center,
    zoom: 12.0,
    onTap: (tapPosition, latlng) {
      setState(() => _center = latlng);
    },
    minZoom: 12.0,
    onPositionChanged: (position, hasGesture) {
      if (hasGesture && position.center != null) {
        setState(() => _center = position.center!);
      }
    },
  ),
  children: [
    TileLayer(
      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
      subdomains: const ['a', 'b', 'c'],
      userAgentPackageName: 'com.example.infractions_mali',
    ),
    CircleLayer(
      circles: [
        CircleMarker(
          point: _center,
          color: Colors.blue.withOpacity(0.1),
          borderColor: Colors.blue,
          borderStrokeWidth: 2.0,
          radius: _radiusKm * 1000,
        ),
      ],
    ),
    MarkerLayer(
      markers: _filteredAlerts.map((alert) => _buildAlertMarker(alert)).toList(),
    ),
  ],
),
        ],
      ),
    );
  }

  Marker _buildAlertMarker(Alert alert) {
    final lat = alert.location['latitude'] ?? _center.latitude;
    final lng = alert.location['longitude'] ?? _center.longitude;
    
    return Marker(
      width: 40.0,
      height: 40.0,
      point: LatLng(lat, lng),
      child: GestureDetector(
        onTap: () => _showAlertDetails(alert),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              _getAlertIcon(alert.type),
              color: _getAlertColor(alert.type),
              size: 32.0,
            ),
            if (alert.isVerified)
              const Positioned(
                right: 0,
                top: 0,
                child: Icon(
                  Icons.verified,
                  color: Colors.green,
                  size: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Positioned _buildMapControls() {
    return Positioned(
      bottom: 16.0,
      right: 16.0,
      child: Column(
        children: [
          FloatingActionButton(
            heroTag: 'recenter',
            onPressed: () => _mapController.move(_center, _mapController.zoom),
            tooltip: 'recenter'.tr(),
            child: const Icon(Icons.my_location),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'zoom_in',
            onPressed: () => _mapController.move(
              _center, 
              _mapController.camera.zoom + 1
            ),
            tooltip: 'zoom_in'.tr(),
            mini: true,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'zoom_out',
            onPressed: () => _mapController.move(
              _center, 
              _mapController.camera.zoom - 1
            ),
            tooltip: 'zoom_out'.tr(),
            mini: true,
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }

  Positioned _buildRadiusFilter() {
    return Positioned(
      top: 16.0,
      left: 16.0,
      right: 16.0,
      child: Card(
        elevation: 4.0,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'filter_radius'.tr(),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.zoom_out_map, size: 20.0),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Slider(
                      value: _radiusKm,
                      min: 1.0,
                      max: 50.0,
                      divisions: 49,
                      label: '${_radiusKm.toStringAsFixed(0)} km',
                      onChanged: (value) => setState(() => _radiusKm = value),
                    ),
                  ),
                  SizedBox(
                    width: 50.0,
                    child: Text(
                      '${_radiusKm.toStringAsFixed(0)} km',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getAlertIcon(AlertType type) {
    switch (type) {
      case AlertType.accident: return Icons.car_crash;
      case AlertType.police: return Icons.local_police;
      case AlertType.roadClosed: return Icons.block;
      case AlertType.hazard: return Icons.warning;
      case AlertType.trafficJam: return Icons.traffic;
      default: return Icons.warning_amber;
    }
  }

  Color _getAlertColor(AlertType type) {
    switch (type) {
      case AlertType.accident: return Colors.red;
      case AlertType.police: return Colors.blue;
      case AlertType.roadClosed: return Colors.orange;
      case AlertType.hazard: return Colors.amber;
      case AlertType.trafficJam: return Colors.purple;
      default: return Colors.grey;
    }
  }
}