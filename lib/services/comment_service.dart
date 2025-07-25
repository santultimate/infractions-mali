import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment.dart';

class CommentService {
  final CollectionReference commentsCollection =
      FirebaseFirestore.instance.collection('comments');

  // Ajouter un commentaire
  Future<void> addComment(Comment comment) async {
    await commentsCollection.doc(comment.id).set(comment.toJson());
  }

  // Récupérer les commentaires d'une alerte (en temps réel)
  Stream<List<Comment>> getCommentsForAlert(String alertId) {
    return commentsCollection
        .where('alertId', isEqualTo: alertId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Comment.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }
}
