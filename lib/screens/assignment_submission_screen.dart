import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/moodle_service.dart';

class AssignmentSubmissionScreen extends StatefulWidget {
  final String token;
  final int assignmentId;
  final String assignmentName;
  final List<String>? allowedTypes; // Tipos de archivos permitidos

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

  // Seleccionar archivos según tipos permitidos
  void _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: widget.allowedTypes != null ? FileType.custom : FileType.any,
      allowedExtensions: widget.allowedTypes,
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        _selectedFiles = result.files;
      });
    }
  }

  // Enviar la tarea a Moodle
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

    // Enviar texto si hay
    if (_textController.text.isNotEmpty) {
      successText = await MoodleService().submitAssignment(
        widget.token,
        widget.assignmentId,
        _textController.text,
      );
    }

    // TODO: Enviar archivos a Moodle usando su API
    // Por ahora solo mostramos que se seleccionaron
    if (_selectedFiles.isNotEmpty) {
      // Aquí debes implementar la subida real de archivos según Moodle
      for (var file in _selectedFiles) {
        print("Archivo a subir: ${file.name} (${file.size} bytes)");
      }
      // Simulamos éxito
      successFiles = true;
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
              // Campo de texto
              TextField(
                controller: _textController,
                maxLines: 8,
                decoration: const InputDecoration(
                  hintText: "Escribe tu tarea aquí...",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Selección de archivos
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
                for (var file in _selectedFiles)
                  Text("${file.name} (${(file.size / 1024).toStringAsFixed(2)} KB)"),
              ],

              const SizedBox(height: 16),

              // Botón enviar
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
