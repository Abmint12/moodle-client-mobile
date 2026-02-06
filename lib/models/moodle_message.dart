class MoodleMessage {
  final String author;
  final String date;
  final String content;
  final List<MoodleMessage> replies;

  MoodleMessage({
    required this.author,
    required this.date,
    required this.content,
    this.replies = const [],
  });
}
