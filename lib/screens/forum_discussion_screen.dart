import 'package:flutter/material.dart';
import 'package:moodle_client_mobile/screens/discussion_posts_screen.dart';
import '../services/moodle_service.dart';

class ForumDiscussionScreen extends StatefulWidget {
  final String token;
  final int forumId;
  final String forumName;

  const ForumDiscussionScreen({
    super.key,
    required this.token,
    required this.forumId,
    required this.forumName,
  });

  @override
  State<ForumDiscussionScreen> createState() => _ForumDiscussionScreenState();
}

class _ForumDiscussionScreenState extends State<ForumDiscussionScreen> {
  late Future<List<dynamic>> _discussionsFuture;

  @override
  void initState() {
    super.initState();
    _discussionsFuture =
        MoodleService().getForumDiscussions(widget.token, widget.forumId);
  }

  void _addDiscussion() {
    final subjectController = TextEditingController();
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Nueva discusión"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(hintText: "Asunto"),
            ),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(hintText: "Mensaje"),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              subjectController.dispose();
              messageController.dispose();
              Navigator.pop(context);
            },
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await MoodleService().postForumDiscussion(
                widget.token,
                widget.forumId,
                subjectController.text,
                messageController.text,
              );

              subjectController.dispose();
              messageController.dispose();
              Navigator.pop(context);

              if (success) {
                setState(() {
                  _discussionsFuture = MoodleService()
                      .getForumDiscussions(widget.token, widget.forumId);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Discusión publicada")),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Error al publicar")),
                );
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
        title: Text(widget.forumName),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addDiscussion,
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _discussionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }

          final discussions = snapshot.data ?? [];
          if (discussions.isEmpty) {
            return const Center(child: Text("No hay discusiones"));
          }

          return ListView.builder(
            itemCount: discussions.length,
            itemBuilder: (context, index) {
              final discussion = discussions[index];
              return ListTile(
                title: Text(discussion['subject'] ?? ""),
                subtitle: Text(discussion['message'] ?? ""),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DiscussionPostsScreen(
                        token: widget.token,
                        discussionId: discussion['discussion'],
                        discussionSubject: discussion['subject'],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
