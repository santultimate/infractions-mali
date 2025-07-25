import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/infraction.dart';

class InfractionService {
  static Future<List<Infraction>> loadInfractions() async {
    final String response = await rootBundle.loadString(
      'assets/data/infractions.json',
    );
    final data = json.decode(response) as Map<String, dynamic>;
    final violations = data['violations'] as List<dynamic>;
    List<Infraction> allInfractions = [];
    for (final classe in violations) {
      final classeName = classe['class'] as String?;
      final items = classe['items'] as List<dynamic>;
      for (final item in items) {
        allInfractions.add(
          Infraction(
            infraction: item['description'] ?? '',
            classe: classeName,
            texte: item['article'] ?? '',
            amende:
                (item['fine']?.toString() ??
                    item['fine_light']?.toString() ??
                    ''),
            extrait: null,
            vehicleTypes:
                (item['vehicle_types'] as List?)
                    ?.map((e) => e.toString())
                    .toList(),
          ),
        );
      }
    }
    return allInfractions;
  }
}
