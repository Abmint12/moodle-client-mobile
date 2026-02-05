import 'package:flutter/material.dart';
import 'package:moodle_client_mobile/screens/assignment_submission_screen.dart';
import '../services/moodle_service.dart';

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
    _activitiesFuture = MoodleService()
        .getCourseActivities(widget.token, widget.courseId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.courseName)),
      body: FutureBuilder<List<dynamic>>(
        future: _activitiesFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final sections = snapshot.data!;
          if (sections.isEmpty) {
            return const Center(child: Text("No hay actividades disponibles"));
          }

          // Listamos directamente como Moodle
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
                  return ListTile(
                    title: Text(mod["name"]),
                    subtitle: Text(
                      "${mod["modname"]} • ${mod["visible"] == 0 ? "Oculto" : "Visible"}",
                    ),
                    trailing: mod["modname"] == 'assign'
                        ? const Icon(Icons.upload_file)
                        : null,
                    onTap: () {
                      // Aquí podrías navegar a la pantalla de envío de tareas si es assign
                      if (mod["modname"] == 'assign') {
                         Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AssignmentSubmissionScreen(
                              token:widget.token, 
                              assignmentId: mod["instance"], 
                              assignmentName: mod["mod"],
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
