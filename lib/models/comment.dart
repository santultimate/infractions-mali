class Comment {
  final String id;
  final String alertId;
  final String text;
  final String authorName;
  final String? authorPhotoUrl;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.alertId,
    required this.text,
    required this.authorName,
    this.authorPhotoUrl,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      alertId: json['alertId'],
      text: json['text'],
      authorName: json['authorName'],
      authorPhotoUrl: json['authorPhotoUrl'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'alertId': alertId,
      'text': text,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
