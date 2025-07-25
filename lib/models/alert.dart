// lib/models/alert_model.dart
import 'package:cloud_firestore/cloud_firestore.dart'; // IMPORTANT pour Timestamp

// Enumération pour les types d'alerte
enum AlertType {
  accident,
  police,
  roadClosure, // Anciennement road_closure
  fire,
  radarMobile,
  radarFixe,
  controlePermis,
  controleTechnique,
  travaux,
  fouillePoliciere,
  corruptionRacket,
  hazard,       // Add this
  trafficJam,   // Add this
  roadClosed, 
  other, // Gardez 'other' comme valeur par défaut
}

class Alert {
  final String id;
  final String title;
  final String description;
  final AlertType type;
  final Map<String, double> location; // Exemple: {'latitude': 0.0, 'longitude': 0.0}
  final DateTime createdAt;
  final bool isVerified;
  final double credibility; // Note de crédibilité, par exemple de 0.0 à 5.0
  final int confirmations;
  final int denials;
  final String userId; // ID de l'utilisateur qui a créé l'alerte
  final String? createdBy; // Nom ou pseudo de l'utilisateur (optionnel)
  final List<String>? photos; // Liste d'URLs des photos (optionnel)
  final bool? wazeValidation; // Si validé par un système externe comme Waze (optionnel)
  final List<String>? confirmedBy; // Liste des UserIDs ayant confirmé
  final List<String>? deniedBy;    // Liste des UserIDs ayant dénié

  Alert({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.location,
    required this.createdAt,
    this.isVerified = false,
    this.credibility = 0.0,
    this.confirmations = 0,
    this.denials = 0,
    required this.userId,
    this.createdBy,
    this.photos,
    this.wazeValidation,
    this.confirmedBy,
    this.deniedBy,
  });

  // Méthode pour convertir un document Firestore en instance d'Alert
  factory Alert.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic> data = doc.data()!;
    return Alert(
      id: doc.id,
      title: data['title'] ?? 'Titre non défini',
      description: data['description'] ?? 'Description non définie',
      type: _parseAlertType(data['type'] ?? 'other'),
      location: Map<String, double>.from(data['location'] ?? {'latitude': 0.0, 'longitude': 0.0}),
      createdAt: (data['createdAt'] as Timestamp? ?? Timestamp.now()).toDate(),
      isVerified: data['isVerified'] ?? false,
      credibility: (data['credibility'] as num?)?.toDouble() ?? 0.0,
      confirmations: data['confirmations'] ?? 0,
      denials: data['denials'] ?? 0,
      userId: data['userId'] ?? 'unknown_user',
      createdBy: data['createdBy'],
      photos: List<String>.from(data['photos'] ?? []),
      wazeValidation: data['wazeValidation'],
      confirmedBy: List<String>.from(data['confirmedBy'] ?? []),
      deniedBy: List<String>.from(data['deniedBy'] ?? []),
    );
  }

  // Méthode pour convertir une instance d'Alert en un Map pour Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'type': type.name, // Utilise l'extension .name pour les enums (Dart 2.15+)
      'location': location,
      'createdAt': Timestamp.fromDate(createdAt), // Convertir DateTime en Timestamp
      'isVerified': isVerified,
      'credibility': credibility,
      'confirmations': confirmations,
      'denials': denials,
      'userId': userId,
      if (createdBy != null) 'createdBy': createdBy,
      if (photos != null) 'photos': photos,
      if (wazeValidation != null) 'wazeValidation': wazeValidation,
      if (confirmedBy != null) 'confirmedBy': confirmedBy,
      if (deniedBy != null) 'deniedBy': deniedBy,
    };
  }

  // Méthode utilitaire pour parser le type d'alerte depuis une chaîne
  static AlertType _parseAlertType(String typeString) {
    // Tente de trouver une correspondance directe (insensible à la casse)
    for (AlertType type in AlertType.values) {
      if (type.name.toLowerCase() == typeString.toLowerCase()) {
        return type;
      }
    }
    // Gérer les anciennes valeurs ou variations si nécessaire (avant d'utiliser .name)
    // Par exemple, si vous aviez 'road_closure' dans Firestore:
    if (typeString.toLowerCase() == 'road_closure') return AlertType.roadClosure;

    print('Type d\'alerte inconnu: "$typeString", utilisation de "other" par défaut.');
    return AlertType.other; // Valeur par défaut si non reconnue
  }


  // Méthode copyWith pour créer une copie modifiée de l'alerte
  Alert copyWith({
    String? id,
    String? title,
    String? description,
    AlertType? type,
    Map<String, double>? location,
    DateTime? createdAt,
    bool? isVerified,
    double? credibility,
    int? confirmations,
    int? denials,
    String? userId,
    String? createdBy,
    List<String>? photos,
    bool? wazeValidation,
    List<String>? confirmedBy,
    List<String>? deniedBy,
  }) {
    return Alert(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      isVerified: isVerified ?? this.isVerified,
      credibility: credibility ?? this.credibility,
      confirmations: confirmations ?? this.confirmations,
      denials: denials ?? this.denials,
      userId: userId ?? this.userId,
      createdBy: createdBy ?? this.createdBy,
      photos: photos ?? this.photos,
      wazeValidation: wazeValidation ?? this.wazeValidation,
      confirmedBy: confirmedBy ?? this.confirmedBy,
      deniedBy: deniedBy ?? this.deniedBy,
    );
  }
}
