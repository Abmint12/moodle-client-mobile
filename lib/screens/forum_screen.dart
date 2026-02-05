import 'package:flutter/material.dart';
import '../services/moodle_service.dart';
import 'forum_discussion_screen.dart';

class ForumScreen extends StatefulWidget {
  final String token;
  final int courseId;

  const ForumScreen({super.key, required this.token, required this.courseId});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  late Future<List<dynamic>> _forumsFuture;

  @override
  void initState() {
    super.initState();
    _forumsFuture =
        MoodleService().getCourseForums(widget.token, widget.courseId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Foros")),
      body: FutureBuilder<List<dynamic>>(
        future: _forumsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final forums = snapshot.data!;
          if (forums.isEmpty) {
            return const Center(child: Text("No hay foros disponibles"));
          }

          return ListView.builder(
            itemCount: forums.length,
            itemBuilder: (context, index) {
              final forum = forums[index];
              return ListTile(
                title: Text(forum['name']),
                subtitle: Text(forum['intro'] ?? ""),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ForumDiscussionScreen(
                        token: widget.token,
                        forumId: forum['id'],
                        forumName: forum['name'],
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
