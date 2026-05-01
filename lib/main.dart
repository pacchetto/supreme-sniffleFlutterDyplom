// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'main_screen.dart'; // ПЕРЕВІР, ЩО ІМПОРТ САМЕ ТАКИЙ

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const ProviderScope(child: AetheriaApp()));
}

class AetheriaApp extends StatelessWidget {
  const AetheriaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AetheriaGraph',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF050505), // Deep Black
        textTheme: GoogleFonts.spaceGroteskTextTheme(
          ThemeData.dark().textTheme,
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF007F), // Neon Pink
          secondary: Color(0xFF7000FF), // Deep Purple
        ),
      ),
      home: const MainScreen(), // ТУТ МАЄ БУТИ MAINSCREEN
    );
  }
}
