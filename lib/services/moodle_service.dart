import 'dart:convert';
import 'package:http/http.dart' as http;

class MoodleService {
  static const String baseUrl = "http://192.168.1.50/moodle";

  // LOGIN -> obtiene el token
  Future<String?> login(String username, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login/token.php"),
      body: {
        "username": username,
        "password": password,
        "service": "moodle_mobile_app",
      },
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data["token"] != null) {
        return data["token"];
      }
    }

    return null;
  }

  // Obtener información del usuario
  Future<Map<String, dynamic>?> getUserData(String token) async {
    final response = await http.get(
      Uri.parse(
        "$baseUrl/webservice/rest/server.php"
        "?wstoken=$token"
        "&wsfunction=core_webservice_get_site_info"
        "&moodlewsrestformat=json",
      ),
    );

    print("USER STATUS: ${response.statusCode}");
    print("USER BODY: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data["errorcode"] != null) {
        return null;
      }

      return data;
    }

    return null;
  }

  Future<bool> validarCorreo(String token, String email) async {
    final response = await http.get(
      Uri.parse(
        "$baseUrl/webservice/rest/server.php"
        "?wstoken=$token"
        "&wsfunction=core_user_get_users_by_field"
        "&field=email"
        "&values[0]=$email"
        "&moodlewsrestformat=json",
      ),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.isNotEmpty;
    }
    return false;
  }

  //Obtener cursos de Moodle
  Future<List<dynamic>> getCourses(String token, int userId) async {
    final response = await http.get(
      Uri.parse(
        "$baseUrl/webservice/rest/server.php"
        "?wstoken=$token"
        "&wsfunction=core_enrol_get_users_courses"
        "&userid=$userId"
        "&moodlewsrestformat=json",
      ),
    );

    print("COURSES BODY: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List) {
        return data;
      }
    }

    return [];
  }

  //obtener actividades de cursos
  Future<List<dynamic>> getCourseActivities(String token, int courseId) async {
    final response = await http.get(
      Uri.parse(
        "$baseUrl/webservice/rest/server.php"
        "?wstoken=$token"
        "&wsfunction=core_course_get_contents"
        "&courseid=$courseId"
        "&moodlewsrestformat=json",
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    }

    return [];
  }

  //subir tarea
  Future<bool> submitAssignment(
    String token,
    int assignmentId,
    String text,
  ) async {
    final response = await http.post(
      Uri.parse(
        "$baseUrl/webservice/rest/server.php"
        "?wstoken=$token"
        "&wsfunction=mod_assign_save_submission"
        "&moodlewsrestformat=json",
      ),
      body: {
        'assignmentid': assignmentId.toString(),
        'plugindata[onlinetext_editor][text]': text,
        'plugindata[onlinetext_editor][format]': '1',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['status'] == true;
    }
    return false;
  }

  //obtener foros de un curso
  Future<List<dynamic>> getCourseForums(String token, int courseId) async {
    final response = await http.get(
      Uri.parse(
        "$baseUrl/webservice/rest/server.php"
        "?wstoken=$token"
        "&wsfunction=mod_forum_get_forums_by_courses"
        "&moodlewsrestformat=json"
        "&courseids[0]=$courseId",
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data; // lista de foros
    }

    return [];
  }

  //obtener discusiones de un foro
  Future<List<dynamic>> getForumDiscussions(String token, int forumId) async {
    final response = await http.get(
      Uri.parse(
        "$baseUrl/webservice/rest/server.php"
        "?wstoken=$token"
        "&wsfunction=mod_forum_get_forum_discussions"
        "&moodlewsrestformat=json"
        "&forumid=$forumId",
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['discussions'] ?? [];
    }

    return [];
  }

  //enviar mensaje a una discusion
  Future<bool> postForumDiscussion(
    String token,
    int forumId,
    String subject,
    String message,
  ) async {
    final response = await http.post(
      Uri.parse(
        "$baseUrl/webservice/rest/server.php"
        "?wstoken=$token"
        "&wsfunction=mod_forum_add_discussion"
        "&moodlewsrestformat=json",
      ),
      body: {
        'forumid': forumId.toString(),
        'subject': subject,
        'message': message,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['discussionid'] != null;
    }

    return false;
  }
  //responder a un mensaje
  Future<bool> replyForumPost(
    String token, int discussionId, String message) async {
  final response = await http.post(
    Uri.parse(
      "$baseUrl/webservice/rest/server.php"
      "?wstoken=$token"
      "&wsfunction=mod_forum_add_discussion_post"
      "&moodlewsrestformat=json",
    ),
    body: {
      'discussionid': discussionId.toString(),
      'message': message,
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['postid'] != null;
  }

  return false;
}

}
