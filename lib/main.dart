// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // НОВИЙ ІМПОРТ SUPABASE
import 'main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Завантажуємо змінні середовища
  await dotenv.load(fileName: ".env");

  // 2. Ініціалізуємо підключення до бази даних Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

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
      // Поки залишаємо MainScreen. Згодом тут можна буде додати перевірку:
      // якщо юзер не залогінений -> показати LoginScreen, інакше -> MainScreen
      home: const MainScreen(),
    );
  }
}
