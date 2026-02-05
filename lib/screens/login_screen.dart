import 'package:flutter/material.dart';
import '../services/moodle_service.dart';
import '../screens/courses_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  final MoodleService moodleService = MoodleService();

    
  bool loading = false;

 void login() async {

  setState(() {
    loading = true;
  });

  final token = await moodleService.login(
    userController.text.trim(),
    passController.text.trim(),
  );

  if (token == null || token.isEmpty) {

    setState(() {
      loading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Credenciales incorrectas")),
    );
    return;
  }

  final userData = await moodleService.getUserData(token);

  setState(() {
    loading = false;
  });

  if (userData != null) {
    final int userId= userData["userid"];
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CoursesScreen(token: token, userId: userId),
      ),
    );

  } else {

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Token inválido")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login Moodle")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              controller: userController,
              decoration: const InputDecoration(labelText: "Usuario"),
            ),

            TextField(
              controller: passController,
              decoration: const InputDecoration(labelText: "Contraseña"),
              obscureText: false           ),

            const SizedBox(height: 20),

            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: login,
                    child: const Text("Ingresar"),
                  ),
          ],
        ),
      ),
    );
  }
  
}
