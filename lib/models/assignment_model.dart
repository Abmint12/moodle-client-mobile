class Assignment {
  final int id;
  final String name;
  final String intro;
  final bool allowsSubmissionText;

  Assignment({
    required this.id,
    required this.name,
    required this.intro,
    required this.allowsSubmissionText,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'],
      name: json['name'],
      intro: json['intro'] ?? '',
      allowsSubmissionText: json['allowsubmissionsfromdate'] != null,
    );
  }
}
