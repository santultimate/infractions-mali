import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
// import '../widgets/ad_interstitial.dart';

class StatisticsScreen extends StatefulWidget {
  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int alertCount = 0;
  int commentCount = 0;
  int reportedCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Interstitiel une fois sur trois
    // if (DateTime.now().millisecondsSinceEpoch % 3 == 0) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     AdInterstitial.loadAndShow(context: context);
    //   });
    // }
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => isLoading = true);
    final alertsSnap =
        await FirebaseFirestore.instance.collection('alerts').get();
    final commentsSnap =
        await FirebaseFirestore.instance.collection('comments').get();
    int reported = 0;
    for (final doc in alertsSnap.docs) {
      final data = doc.data();
      if (data['reportedBy'] != null && data['reportedBy'] is List) {
        reported += (data['reportedBy'] as List).length;
      }
    }
    setState(() {
      alertCount = alertsSnap.size;
      commentCount = commentsSnap.size;
      reportedCount = reported;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('statistics'))),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tr('total_alerts') + ': $alertCount',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  Text(tr('total_comments') + ': $commentCount',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  Text(tr('total_reports') + ': $reportedCount',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red)),
                  SizedBox(height: 32),
                  ElevatedButton.icon(
                    icon: Icon(Icons.refresh),
                    label: Text(tr('refresh')),
                    onPressed: _loadStats,
                  ),
                ],
              ),
            ),
    );
  }
}
