import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:geolocator/geolocator.dart';
import '../models/alert.dart';
import '../services/alert_service.dart';
import '../services/auth_service.dart';

class AddAlertDialog extends StatefulWidget {
  final AlertService alertService;
  final AuthService authService;

  const AddAlertDialog({
    Key? key,
    required this.alertService,
    required this.authService,
  }) : super(key: key);

  @override
  State<AddAlertDialog> createState() => _AddAlertDialogState();
}

class _AddAlertDialogState extends State<AddAlertDialog>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  AlertType _selectedType = AlertType.radarMobile;
  bool _isLoading = false;
  bool _isSubmitting = false;
  Position? _currentPosition;
  String? _error;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);

    try {
      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('location_permission_denied'.tr());
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('location_permission_denied_forever'.tr());
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'location_error'.tr(args: [e.toString()]);
        _isLoading = false;
      });
    }
  }

  Future<void> _submitAlert() async {
    if (!_formKey.currentState!.validate()) return;

    // Check if user is logged in
    if (!widget.authService.isLoggedIn) {
      _showLoginRequiredDialog();
      return;
    }

    // Check email verification
    if (!widget.authService.isEmailVerified) {
      _showEmailVerificationDialog();
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      if (_currentPosition == null) {
        throw Exception('location_not_available'.tr());
      }

      final alert = Alert(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: _selectedType,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        location: {
          'latitude': _currentPosition!.latitude,
          'longitude': _currentPosition!.longitude,
        },
        createdAt: DateTime.now(),
        userId: widget.authService.userId!,
        createdBy: widget.authService.userDisplayName ??
            widget.authService.userEmail ??
            'anonymous'.tr(),
      );

      final success = await widget.alertService.submitAlert(
        type: _selectedType,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        location: {
          'latitude': _currentPosition!.latitude,
          'longitude': _currentPosition!.longitude,
        },
        userId: widget.authService.userId!,
        createdBy: widget.authService.userDisplayName ??
            widget.authService.userEmail ??
            'anonymous'.tr(),
      );

      if (!success) {
        throw Exception('alert_submission_failed'.tr());
      }

      // Show success animation
      await _showSuccessAnimation();

      if (mounted) {
        Navigator.of(context).pop(true);
        _showSuccessSnackbar();
      }
    } catch (e) {
      setState(() {
        _error = 'alert_submission_error'.tr(args: [e.toString()]);
        _isSubmitting = false;
      });
    }
  }

  Future<void> _showSuccessAnimation() async {
    _animationController.reset();
    await _animationController.forward();
  }

  void _showSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text('alert_submitted_successfully'.tr()),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('login_required'.tr()),
        content: Text('login_required_message'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              // Navigate to login screen
              Navigator.of(context).pushNamed('/login');
            },
            child: Text('login'.tr()),
          ),
        ],
      ),
    );
  }

  void _showEmailVerificationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('email_verification_required'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('email_verification_message'.tr()),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                try {
                  await widget.authService.sendEmailVerification();
                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('verification_email_sent'.tr()),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('verification_email_error'.tr()),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text('resend_verification'.tr()),
            ),
          ],
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

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.add_location, color: Colors.red),
            const SizedBox(width: 8),
            Text('add_alert'.tr()),
          ],
        ),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Alert Type Selection
                DropdownButtonFormField<AlertType>(
                  value: _selectedType,
                  decoration: InputDecoration(
                    labelText: 'alert_type'.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.category),
                  ),
                  items: AlertType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Row(
                        children: [
                          Icon(_getAlertTypeIcon(type)),
                          const SizedBox(width: 8),
                          Text(_getAlertTypeName(type)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedType = value);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Title Field
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'alert_title'.tr(),
                    hintText: 'alert_title_hint'.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'title_required'.tr();
                    }
                    if (value.trim().length < 3) {
                      return 'title_too_short'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description Field
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'alert_description'.tr(),
                    hintText: 'alert_description_hint'.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.description),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'description_required'.tr();
                    }
                    if (value.trim().length < 10) {
                      return 'description_too_short'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Location Status
                _buildLocationStatus(),

                // Error Message
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
            child: Text('cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: _isSubmitting || _isLoading ? null : _submitAlert,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text('submit_alert'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationStatus() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _currentPosition != null
            ? Colors.green.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _currentPosition != null
              ? Colors.green.shade300
              : Colors.orange.shade300,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _currentPosition != null
                ? Icons.location_on
                : Icons.location_searching,
            color: _currentPosition != null ? Colors.green : Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentPosition != null
                      ? 'location_acquired'.tr()
                      : 'acquiring_location'.tr(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color:
                        _currentPosition != null ? Colors.green : Colors.orange,
                  ),
                ),
                if (_currentPosition != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${_currentPosition!.latitude.toStringAsFixed(6)}, '
                    '${_currentPosition!.longitude.toStringAsFixed(6)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          if (_isLoading)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }

  IconData _getAlertTypeIcon(AlertType type) {
    switch (type) {
      case AlertType.radarMobile:
        return Icons.radar;
      case AlertType.radarFixe:
        return Icons.speed;
      case AlertType.police:
        return Icons.local_police;
      case AlertType.accident:
        return Icons.car_crash;
      case AlertType.travaux:
        return Icons.construction;
      case AlertType.trafficJam:
        return Icons.traffic;
      case AlertType.other:
        return Icons.warning;
      case AlertType.roadClosure:
        return Icons.block;
      case AlertType.fire:
        return Icons.local_fire_department;
      case AlertType.controlePermis:
        return Icons.drive_file_rename_outline;
      case AlertType.controleTechnique:
        return Icons.build;
      case AlertType.fouillePoliciere:
        return Icons.search;
      case AlertType.corruptionRacket:
        return Icons.money_off;
      case AlertType.hazard:
        return Icons.warning_amber;
      case AlertType.roadClosed:
        return Icons.do_not_disturb;
    }
  }

  String _getAlertTypeName(AlertType type) {
    switch (type) {
      case AlertType.radarMobile:
        return 'radar_mobile'.tr();
      case AlertType.radarFixe:
        return 'radar_fixe'.tr();
      case AlertType.police:
        return 'controle_police'.tr();
      case AlertType.accident:
        return 'accident'.tr();
      case AlertType.travaux:
        return 'travaux'.tr();
      case AlertType.trafficJam:
        return 'embouteillage'.tr();
      case AlertType.other:
        return 'autre'.tr();
      case AlertType.roadClosure:
        return 'fermeture_route'.tr();
      case AlertType.fire:
        return 'incendie'.tr();
      case AlertType.controlePermis:
        return 'controle_permis'.tr();
      case AlertType.controleTechnique:
        return 'controle_technique'.tr();
      case AlertType.fouillePoliciere:
        return 'fouille_policiere'.tr();
      case AlertType.corruptionRacket:
        return 'corruption_racket'.tr();
      case AlertType.hazard:
        return 'danger'.tr();
      case AlertType.roadClosed:
        return 'route_fermee'.tr();
    }
  }
}
