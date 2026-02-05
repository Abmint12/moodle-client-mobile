import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/course_model.dart';

class CourseService {

  final String baseUrl;
  final String token;

  CourseService(this.baseUrl, this.token);

  Future<List<Course>> getCourses() async {

    final response = await http.get(
      Uri.parse(
        "$baseUrl/webservice/rest/server.php"
        "?wstoken=$token"
        "&wsfunction=core_enrol_get_users_courses"
        "&moodlewsrestformat=json"
      ),
    );

    if (response.statusCode == 200) {

      final List data = jsonDecode(response.body);

      return data.map((e) => Course.fromJson(e)).toList();
    }

    return [];
  }
}
