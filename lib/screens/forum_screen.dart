import 'package:flutter/material.dart';
import '../services/moodle_service.dart';

class ForumScreen extends StatefulWidget {
  final String token;
  final int courseId;
  final int forumId;
  final String forumName;
  
  const ForumScreen({
    Key? key,
    required this.token,
    required this.courseId,
    required this.forumId,
    required this.forumName,
  }) : super(key: key);

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}


class _ForumScreenState extends State<ForumScreen> {
  late Future<List<dynamic>> _discussionsFuture;

  @override
  void initState() {
    super.initState();
    _discussionsFuture = MoodleService().getForumDiscussions(widget.token, widget.forumId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.forumName)),
      body: FutureBuilder<List<dynamic>>(
        future: _discussionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No hay discusiones disponibles"));
          }

          final discussions = snapshot.data!;

          return ListView.builder(
            itemCount: discussions.length,
            itemBuilder: (context, index) {
              final discussion = discussions[index];
              return ListTile(
                title: Text(discussion['name'] ?? "Discusión"),
                subtitle: Text("Creado por: ${discussion['userfullname'] ?? 'Desconocido'}"),
                onTap: () {
                  // Aquí podrías ir a otra pantalla para ver los mensajes de la discusión
                },
              );
            },
          );
        },
      ),
    );
  }
}
