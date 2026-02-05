import 'package:flutter/material.dart';
import '../services/moodle_service.dart';

class ActivitiesScreen extends StatefulWidget {
  final String token;
  final int courseId;

  const ActivitiesScreen({
    super.key,
    required this.token,
    required this.courseId,
  });

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
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
      appBar: AppBar(title: const Text("Actividades")),
      body: FutureBuilder<List<dynamic>>(
        future: _activitiesFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final sections = snapshot.data!;

          return ListView(
            children: sections.expand<Widget>((section) {
              final modules = section["modules"] ?? [];
              return modules.map<Widget>((mod) {
                return ListTile(
                  title: Text(mod["name"]),
                  subtitle: Text(mod["modname"]),
                );
              }).toList();
            }).toList(),
          );
        },
      ),
    );
  }
}
