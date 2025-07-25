import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:app_settings/app_settings.dart';
import '../models/alert.dart';
import '../services/auth_service.dart';
import '../services/alert_service.dart';
import '../widgets/add_alert_dialog.dart';

class CommunityMapScreen extends StatefulWidget {
  const CommunityMapScreen({super.key});

  @override
  State<CommunityMapScreen> createState() => _CommunityMapScreenState();
}

class _CommunityMapScreenState extends State<CommunityMapScreen> {
  final AlertService _alertService = AlertService();
  final AuthService _authService = AuthService();

  List<Alert> _alerts = [];
  bool _isLoading = true;
  Position? _currentPosition;
  String? _currentUserId;
  bool _locationPermissionDenied = false;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    if (mounted) setState(() => _isLoading = true);
    await _getCurrentUserId();
    await _checkLocationAndLoadAlerts();
  }

  Future<void> _getCurrentUserId() async {
    try {
      final userId = await _authService.getCurrentUserId();
      if (mounted) setState(() => _currentUserId = userId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('error_getting_user'.tr())),
        );
      }
      debugPrint('Error getting user ID: $e');
    }
  }

  Future<void> _checkLocationAndLoadAlerts() async {
    if (mounted) setState(() {
      _isLoading = true;
      _locationPermissionDenied = false;
    });

    try {
      // Check if location services are enabled
      if (!await Geolocator.isLocationServiceEnabled()) {
        _showLocationServiceError();
        return;
      }

      // Check permissions
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showLocationPermissionError();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showLocationPermissionPermanentError();
        return;
      }

      // Get current position
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      await _loadAlerts();
    } catch (e) {
      debugPrint('Location error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('location_error'.tr())),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  void _showLocationServiceError() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('location_disabled_message'.tr()),
          action: SnackBarAction(
            label: 'enable'.tr(),
            onPressed: () => AppSettings.openLocationSettings(),
          ),
        ),
      );
      setState(() => _isLoading = false);
    }
  }

  void _showLocationPermissionError() {
    if (mounted) {
      setState(() {
        _isLoading = false;
        _locationPermissionDenied = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('location_permission_denied_message'.tr()),
          action: SnackBarAction(
            label: 'try_again'.tr(),
            onPressed: _checkLocationAndLoadAlerts,
          ),
        ),
      );
    }
  }

  Future<void> _showLocationPermissionPermanentError() async {
    if (!mounted) return;

    final shouldOpenSettings = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('location_permission_required'.tr()),
        content: Text('location_permission_denied_forever_message'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('settings'.tr()),
          ),
        ],
      ),
    );

    if (shouldOpenSettings == true) {
      await AppSettings.openAppSettings();
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadAlerts() async {
    if (_currentPosition == null) return;

    try {
      final alerts = await _alertService.getAlertsNearLocation(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        userId: _currentUserId,
      );

      if (mounted) setState(() => _alerts = alerts);
    } catch (e) {
      debugPrint('Error loading alerts: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('error_loading_alerts'.tr())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddAlertDialog() {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('location_required_for_alert'.tr())),
      );
      return;
    }

    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('login_required_for_alert'.tr())),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AddAlertDialog(
        currentPosition: _currentPosition!,
        currentUserId: _currentUserId!,
        onAlertAdded: _loadAlerts,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('community_map'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkLocationAndLoadAlerts,
            tooltip: 'refresh'.tr(),
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAlertDialog,
        tooltip: 'add_alert'.tr(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_locationPermissionDenied) {
      return _buildPermissionDeniedView();
    }

    if (_alerts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('no_alerts_found'.tr()),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _checkLocationAndLoadAlerts,
              child: Text('retry'.tr()),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _alerts.length,
      itemBuilder: (context, index) => _buildAlertCard(_alerts[index]),
    );
  }

  Widget _buildPermissionDeniedView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_off, size: 64),
          const SizedBox(height: 16),
          Text('location_permission_required'.tr(),
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('please_enable_location'.tr(),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _checkLocationAndLoadAlerts,
            child: Text('grant_permission'.tr()),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => AppSettings.openAppSettings(),
            child: Text('open_settings'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(Alert alert) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: Icon(
          _getAlertIcon(alert.type),
          color: _getAlertColor(alert.type),
        ),
        title: Text(alert.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(alert.description),
            const SizedBox(height: 4),
            Text(
              '${'created_at'.tr()}: ${DateFormat('MMM dd, yyyy - HH:mm').format(alert.createdAt)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () => _showAlertDetails(alert),
        ),
      ),
    );
  }

  void _showAlertDetails(Alert alert) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: AlertDetailsSheet(alert: alert),
        );
      },
    );
  }

  // Helper methods for alert display
  IconData _getAlertIcon(AlertType type) {
    switch (type) {
      case AlertType.accident: return Icons.car_crash;
      case AlertType.police: return Icons.local_police;
    // Add other cases as needed
      default: return Icons.warning;
    }
  }

  Color _getAlertColor(AlertType type) {
    switch (type) {
      case AlertType.accident: return Colors.red;
      case AlertType.police: return Colors.blue;
    // Add other cases as needed
      default: return Colors.orange;
    }
  }
}

class AlertDetailsSheet extends StatelessWidget {
  final Alert alert;

  const AlertDetailsSheet({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_getAlertIcon(alert.type), color: _getAlertColor(alert.type)),
              const SizedBox(width: 8),
              Text(
                alert.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(alert.description),
          const SizedBox(height: 16),
          Text(
            '${'posted_by'.tr()}: ${alert.createdBy}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            '${'posted_on'.tr()}: ${DateFormat('MMM dd, yyyy - HH:mm').format(alert.createdAt)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          // Add more details as needed
        ],
      ),
    );
  }

  IconData _getAlertIcon(AlertType type) {
    // Same implementation as in parent class
    switch (type) {
      case AlertType.accident: return Icons.car_crash;
      case AlertType.police: return Icons.local_police;
      default: return Icons.warning;
    }
  }

  Color _getAlertColor(AlertType type) {
    // Same implementation as in parent class
    switch (type) {
      case AlertType.accident: return Colors.red;
      case AlertType.police: return Colors.blue;
      default: return Colors.orange;
    }
  }
}