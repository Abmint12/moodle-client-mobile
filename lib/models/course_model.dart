class Course {
  final int id;
  final String fullname;
  final String shortname;

  Course({
    required this.id,
    required this.fullname,
    required this.shortname,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      fullname: json['fullname'],
      shortname: json['shortname'],
    );
  }
}
