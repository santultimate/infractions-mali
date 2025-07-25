class Infraction {
  final String infraction;
  final String? classe;
  final String texte;
  final String amende;
  final String? extrait;
  final List<String>? vehicleTypes;

  Infraction({
    required this.infraction,
    required this.classe,
    required this.texte,
    required this.amende,
    this.extrait,
    this.vehicleTypes,
  });

  factory Infraction.fromJson(Map<String, dynamic> json) {
    return Infraction(
      infraction: json['infraction'] ?? json['description'] ?? '',
      classe: json['classe'] ?? json['class'],
      texte: json['texte'] ?? json['article'] ?? '',
      amende:
          json['amende']?.toString() ??
          json['fine']?.toString() ??
          json['fine_light']?.toString() ??
          '',
      extrait: json['extrait'],
      vehicleTypes:
          (json['vehicle_types'] as List?)?.map((e) => e.toString()).toList(),
    );
  }
}
