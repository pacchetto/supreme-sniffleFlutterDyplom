// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main_screen.dart';
import 'auth_page.dart'; // Імпортуємо твій новий файл екрану входу

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Завантажуємо змінні середовища (ЗБЕРЕЖЕНО)
  await dotenv.load(fileName: ".env");

  // 2. Ініціалізуємо підключення до бази даних Supabase (ЗБЕРЕЖЕНО)
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
        scaffoldBackgroundColor: const Color(
          0xFF050505,
        ), // Deep Black (ЗБЕРЕЖЕНО)
        textTheme: GoogleFonts.spaceGroteskTextTheme(
          ThemeData.dark().textTheme,
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF007F), // Neon Pink (ЗБЕРЕЖЕНО)
          secondary: Color(0xFF7000FF), // Deep Purple (ЗБЕРЕЖЕНО)
        ),
      ),
      // Замість статичного MainScreen ставимо динамічний шлюз перевірки авторизації
      home: const AuthGate(),
    );
  }
}

/// Новий віджет-шлюз, який керує відображенням: логін чи головний екран
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isLoading = true;
  Session? _currentSession;

  @override
  void initState() {
    super.initState();
    _checkInitialSession();
    _listenToAuthChanges();
  }

  // Перевірка сесії при старті додатка
  void _checkInitialSession() {
    final session = Supabase.instance.client.auth.currentSession;
    if (mounted) {
      setState(() {
        _currentSession = session;
        _isLoading = false;
      });
    }
  }

  // Постійний слухач змін (вхід, вихід, ресет)
  void _listenToAuthChanges() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (!mounted) return;

      switch (event) {
        case AuthChangeEvent.signedIn:
        case AuthChangeEvent.tokenRefreshed:
          setState(() {
            _currentSession = session;
            _isLoading = false;
          });
          break;
        case AuthChangeEvent.signedOut:
        case AuthChangeEvent.userDeleted:
          setState(() {
            _currentSession = null;
            _isLoading = false;
          });
          break;
        default:
          setState(() {
            _currentSession = session;
          });
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Поки перевіряємо токери в пам'яті — гарний чорний індикатор у твоїй палітрі
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF050505),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFF007F), // Neon Pink індикатор
          ),
        ),
      );
    }

    // Якщо користувач залогінений (анонімно або по email) -> показуємо твій оригінальний екран
    if (_currentSession != null) {
      return const MainScreen();
    }

    // Якщо не залогінений (або після ресету) -> показуємо новий AuthPage
    return const AuthPage();
  }
}
