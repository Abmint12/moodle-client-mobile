import 'package:flutter/material.dart';
import '../services/moodle_service.dart';

class DiscussionPostsScreen extends StatefulWidget {
  final String token;
  final int discussionId;
  final String discussionSubject;

  const DiscussionPostsScreen({
    super.key,
    required this.token,
    required this.discussionId,
    required this.discussionSubject,
  });

  @override
  State<DiscussionPostsScreen> createState() => _DiscussionPostsScreenState();
}

class _DiscussionPostsScreenState extends State<DiscussionPostsScreen> {
  late Future<List<dynamic>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  void _loadPosts() {
    _postsFuture = MoodleService().getForumDiscussions(widget.token, widget.discussionId);
  }

  void _replyPost() {
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Responder mensaje"),
        content: TextField(
          controller: messageController,
          maxLines: 5,
          decoration: const InputDecoration(hintText: "Escribe tu respuesta"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await MoodleService().replyForumPost(
                widget.token,
                widget.discussionId,
                messageController.text,
              );
              Navigator.pop(context);
              if (success) {
                _loadPosts();
                setState(() {});
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text("Respuesta enviada")));
              } else {
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text("Error al enviar")));
              }
            },
            child: const Text("Enviar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.discussionSubject),
        actions: [IconButton(icon: const Icon(Icons.reply), onPressed: _replyPost)],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _postsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final posts = snapshot.data!;
          if (posts.isEmpty) return const Center(child: Text("No hay mensajes"));

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: ListTile(
                  title: Text(post['subject'] ?? ""),
                  subtitle: Text(post['message'] ?? ""),
                  trailing: Text(post['userfullname'] ?? ""),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
