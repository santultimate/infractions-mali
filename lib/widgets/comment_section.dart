import 'package:flutter/material.dart';
import '../models/comment.dart';
import '../services/comment_service.dart';
import '../services/auth_service.dart';
import 'package:uuid/uuid.dart';
import 'package:easy_localization/easy_localization.dart';
// import 'ad_interstitial.dart';

class CommentSection extends StatefulWidget {
  final String alertId;
  const CommentSection({required this.alertId, required String currentUserId});

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final CommentService _commentService = CommentService();
  final TextEditingController _controller = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _addComment() async {
    final authService = AuthService();
    final user = authService.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vous devez être connecté pour commenter.')),
      );
      return;
    }
    if (_controller.text.trim().isEmpty) return;
    setState(() => _isSubmitting = true);
    final comment = Comment(
      id: Uuid().v4(),
      alertId: widget.alertId,
      text: _controller.text.trim(),
      authorName: user.displayName?.split(' ').first ?? 'Utilisateur',
      authorPhotoUrl: user.photoURL,
      createdAt: DateTime.now(),
    );
    await _commentService.addComment(comment);
    _controller.clear();
    setState(() => _isSubmitting = false);
    // Afficher la pub interstitielle
    // AdInterstitial.loadAndShow(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tr('comment'), style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Expanded(
          child: StreamBuilder<List<Comment>>(
            stream: _commentService.getCommentsForAlert(widget.alertId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              final comments = snapshot.data ?? [];
              if (comments.isEmpty) {
                return Text(tr('no_comment'));
              }
              return ListView.builder(
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  return ListTile(
                    leading: comment.authorPhotoUrl != null
                        ? CircleAvatar(
                            backgroundImage:
                                NetworkImage(comment.authorPhotoUrl!))
                        : CircleAvatar(child: Icon(Icons.person)),
                    title: Text(comment.authorName),
                    subtitle: Text(comment.text),
                    trailing: Text(
                      '${comment.createdAt.hour.toString().padLeft(2, '0')}:${comment.createdAt.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  );
                },
              );
            },
          ),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(hintText: tr('add_comment')),
                minLines: 1,
                maxLines: 3,
              ),
            ),
            IconButton(
              icon: _isSubmitting
                  ? CircularProgressIndicator()
                  : Icon(Icons.send),
              onPressed: _isSubmitting ? null : _addComment,
            ),
          ],
        ),
      ],
    );
  }
}
