// lib/widgets/message_card.dart
import 'package:flutter/material.dart';
import '../models/moodle_message.dart';

class MessageCard extends StatelessWidget {
  final MoodleMessage message;
  final VoidCallback? onReply;

  const MessageCard({super.key, required this.message, this.onReply});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${message.author} - ${message.date}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(message.content),
            const SizedBox(height: 8),
            if (onReply != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onReply,
                  child: const Text('Responder'),
                ),
              ),
            if (message.replies.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 8),
                child: Column(
                  children: message.replies
                      .map((reply) => MessageCard(message: reply))
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
