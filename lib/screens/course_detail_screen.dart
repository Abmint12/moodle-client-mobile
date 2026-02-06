import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/moodle_service.dart';
import 'assignment_submission_screen.dart';
import 'forum_screen.dart'; // Asegúrate de tener esta pantalla creada

class CourseDetailScreen extends StatefulWidget {
  final String token;
  final int courseId;
  final String courseName;

  const CourseDetailScreen({
    super.key,
    required this.token,
    required this.courseId,
    required this.courseName,
  });

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  late Future<List<dynamic>> _activitiesFuture;

  @override
  void initState() {
    super.initState();
    _activitiesFuture = MoodleService().getCourseActivities(
      widget.token,
      widget.courseId,
    );
  }

  String formatDate(int? timestamp) {
    if (timestamp == null || timestamp == 0) return "No disponible";
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.courseName)),
      body: FutureBuilder<List<dynamic>>(
        future: _activitiesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No hay actividades disponibles"));
          }

          final sections = snapshot.data!;

          return ListView.builder(
            itemCount: sections.length,
            itemBuilder: (context, sectionIndex) {
              final section = sections[sectionIndex];
              final modules = section["modules"] ?? [];

              return ExpansionTile(
                title: Text(
                  section["name"] ?? "Sección ${sectionIndex + 1}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                children: modules.map<Widget>((mod) {
                  final dueDate = mod["duedate"];
                  final openDate = mod["availablefrom"];

                  return ListTile(
                    title: Text(mod["name"] ?? "Actividad"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${mod["modname"]} • ${mod["visible"] == 0 ? "Oculto" : "Visible"}",
                        ),
                        if (mod["modname"] == 'assign')
                          Text("Abre: ${formatDate(openDate)}"),
                        if (mod["modname"] == 'assign')
                          Text("Vence: ${formatDate(dueDate)}"),
                      ],
                    ),
                    trailing: mod["modname"] == 'assign'
                        ? const Icon(Icons.upload_file)
                        : mod["modname"] == 'forum'
                            ? const Icon(Icons.forum)
                            : null,
                    onTap: () {
                      if (mod["modname"] == 'assign') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AssignmentSubmissionScreen(
                              token: widget.token,
                              assignmentId: mod["instance"],
                              assignmentName: mod["name"] ?? "Tarea",
                              allowedTypes: [
                                "txt",
                                "pdf",
                                "jpg",
                                "png",
                              ], // Aquí puedes añadir más según Moodle
                            ),
                          ),
                        );
                      } else if (mod["modname"] == 'forum') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ForumScreen(
                              token: widget.token,
                              courseId: widget.courseId,
                              forumId: mod["instance"], // <--- coincide con constructor
                              forumName: mod["name"] ?? "Foro",    // <--- coincide con constructor
                            ),
                          ),
                        );
                      }
                    },
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}
