import 'package:flutter/material.dart';
import '../services/moodle_service.dart';

class AssignmentSubmissionScreen extends StatefulWidget {
  final String token;
  final int assignmentId;
  final String assignmentName;

  const AssignmentSubmissionScreen({
    super.key,
    required this.token,
    required this.assignmentId,
    required this.assignmentName,
  });

  @override
  State<AssignmentSubmissionScreen> createState() =>
      _AssignmentSubmissionScreenState();
}

class _AssignmentSubmissionScreenState
    extends State<AssignmentSubmissionScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _sending = false;

  void _sendSubmission() async {
    if (_textController.text.isEmpty) return;

    setState(() => _sending = true);

    final success = await MoodleService().submitAssignment(
      widget.token,
      widget.assignmentId,
      _textController.text,
    );

    setState(() => _sending = false);

    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Tarea enviada")));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Error al enviar")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.assignmentName)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              maxLines: 10,
              decoration: const InputDecoration(
                hintText: "Escribe tu tarea aquí...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _sending ? null : _sendSubmission,
              child: _sending
                  ? const CircularProgressIndicator()
                  : const Text("Enviar tarea"),
            ),
          ],
        ),
      ),
    );
  }
}
