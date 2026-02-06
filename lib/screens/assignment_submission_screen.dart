import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/moodle_service.dart';

class AssignmentSubmissionScreen extends StatefulWidget {
  final String token;
  final int assignmentId;
  final String assignmentName;
  final List<String>? allowedTypes;

  const AssignmentSubmissionScreen({
    super.key,
    required this.token,
    required this.assignmentId,
    required this.assignmentName,
    this.allowedTypes,
  });

  @override
  State<AssignmentSubmissionScreen> createState() =>
      _AssignmentSubmissionScreenState();
}

class _AssignmentSubmissionScreenState
    extends State<AssignmentSubmissionScreen> {
  final TextEditingController _textController = TextEditingController();
  List<PlatformFile> _selectedFiles = [];
  bool _sending = false;
  Map<String, double> _uploadProgress = {};

  void _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: widget.allowedTypes != null ? FileType.custom : FileType.any,
      allowedExtensions: widget.allowedTypes,
      allowMultiple: true,
      withData: true, // <- importante para usar bytes
    );

    if (result != null) {
      setState(() {
        _selectedFiles = result.files;
        _uploadProgress = {for (var f in _selectedFiles) f.name: 0.0};
      });
    }
  }

  void _sendSubmission() async {
    if (_textController.text.isEmpty && _selectedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Agrega texto o archivos antes de enviar")),
      );
      return;
    }

    setState(() => _sending = true);

    bool successText = true;
    bool successFiles = true;

    if (_textController.text.isNotEmpty) {
      successText = await MoodleService().submitAssignment(
        widget.token,
        widget.assignmentId,
        _textController.text,
      );
    }

    if (_selectedFiles.isNotEmpty) {
      for (var file in _selectedFiles) {
        bool result = false;

        if (file.bytes != null) {
          result = await MoodleService().uploadFileFromBytes(
            file.bytes!,
            file.name,
            widget.token,
            widget.assignmentId,
            (progress) {
              setState(() {
                _uploadProgress[file.name] = progress;
              });
            },
          );
        } else if (file.path != null) {
          result = await MoodleService().uploadFileWithProgress(
            file.path!,
            widget.token,
            widget.assignmentId,
            (progress) {
              setState(() {
                _uploadProgress[file.name] = progress;
              });
            },
          );
        } else {
          print('No se puede subir ${file.name}, sin path ni bytes');
        }

        if (!result) successFiles = false;
      }
    }

    setState(() => _sending = false);

    if (successText && successFiles) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tarea enviada correctamente")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al enviar la tarea")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.assignmentName)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _textController,
                maxLines: 8,
                decoration: const InputDecoration(
                  hintText: "Escribe tu tarea aquí...",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.attach_file),
                label: const Text("Agregar archivos"),
                onPressed: _sending ? null : _pickFiles,
              ),
              if (_selectedFiles.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  "Archivos seleccionados:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                for (var file in _selectedFiles) ...[
                  Text("${file.name} (${(file.size / 1024).toStringAsFixed(2)} KB)"),
                  LinearProgressIndicator(
                    value: _uploadProgress[file.name] ?? 0.0,
                    backgroundColor: Colors.grey[200],
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 8),
                ]
              ],
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _sending ? null : _sendSubmission,
                child: _sending
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Enviar tarea"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
