import 'package:flutter/material.dart';
import '../models/alert.dart';

class AlertListOverlay extends StatelessWidget {
  final List<Alert> alerts;
  final Function(Alert) onAlertTap;

  const AlertListOverlay({
    required this.alerts,
    required this.onAlertTap,
  });

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: alerts.length,
        itemBuilder: (context, index) {
          final alert = alerts[index];
          return Container(
            width: 260,
            margin: EdgeInsets.only(right: 12),
            child: Card(
              elevation: 4,
              child: InkWell(
                onTap: () => onAlertTap(alert),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _getAlertIcon(alert.type),
                            color: _getAlertColor(alert.type),
                            size: 18,
                          ),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              alert.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 4),
                          _buildCredibilityStars(alert.credibility),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        alert.description,
                        style: TextStyle(fontSize: 11),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.access_time,
                              size: 11, color: Colors.grey[600]),
                          SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              _getTimeAgo(alert.createdAt),
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Spacer(),
                          if (alert.isVerified)
                            Icon(Icons.verified, size: 11, color: Colors.green),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getAlertIcon(AlertType type) {
    switch (type) {
      case AlertType.radarMobile:
      case AlertType.radarFixe:
        return Icons.speed;
      case AlertType.controlePermis:
        return Icons.drive_file_rename_outline;
      case AlertType.controleTechnique:
        return Icons.build;
      case AlertType.accident:
        return Icons.car_crash;
      case AlertType.travaux:
        return Icons.construction;
      case AlertType.fouillePoliciere:
        return Icons.local_police;
      case AlertType.corruptionRacket:
        return Icons.money_off;
      default:
        return Icons.warning;
    }
  }

  Color _getAlertColor(AlertType type) {
    switch (type) {
      case AlertType.radarMobile:
      case AlertType.radarFixe:
        return Colors.red;
      case AlertType.controlePermis:
      case AlertType.controleTechnique:
        return Colors.blue;
      case AlertType.accident:
        return Colors.orange;
      case AlertType.travaux:
        return Colors.yellow[700]!;
      case AlertType.fouillePoliciere:
        return Colors.purple;
      case AlertType.corruptionRacket:
        return Colors.deepOrange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildCredibilityStars(double credibility) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < credibility.floor() ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 12,
        );
      }),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} h';
    } else {
      return '${difference.inDays} j';
    }
  }
}
