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
        "service": "moodle_mobile_app"
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
        "&moodlewsrestformat=json"
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
}
