import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Moodle Client Mobile',

      theme: ThemeData(
        primaryColor: const Color(0xFF1DA1F2),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1DA1F2),
          secondary: const Color(0xFF17BF63),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),

        fontFamily: 'Roboto',

        // ✅ NUEVA nomenclatura TextTheme (Flutter moderno)
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ), // reemplaza headline6

          bodyMedium: TextStyle(
            fontSize: 16,
          ), // reemplaza bodyText2

          labelLarge: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ), // reemplaza button
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1DA1F2),
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1DA1F2),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 24,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF1DA1F2),
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
        ),

        cardTheme: const CardThemeData(
          elevation: 3,
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(12),
            ),
          ),
        ),
      ),

      home: const LoginScreen(),
    );
  }
}
