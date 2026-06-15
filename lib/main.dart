// lib/main.dart

import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'l10n/app_localizations.dart';
import 'main_screen.dart';
import 'auth_page.dart';
import 'web_main_screen.dart';
import 'web_splash_page.dart';
import 'dart:async';
import 'locale_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (kIsWeb) {
      // On web, initialize window API key from JS
      await _initWebEnvironment();
    } else {
      // Supabase initialization ONLY for mobile (not for web)
      // 1. Завантажуємо змінні середовища (ТІЛЬКИ ДЛЯ МОБІЛЬНИХ)
      await _loadEnvironmentVariables();

      // 2. Ініціалізуємо підключення до бази даних Supabase (ТІЛЬКИ ДЛЯ МОБІЛЬНИХ)
      await _initializeSupabase();
    }
  } catch (e) {
    debugPrint("❌ Critical error during initialization: $e");
  }

  runApp(const ProviderScope(child: AetheriaApp()));
}

/// Завантажує змінні середовища з .env файлу або використовує fallback значення
Future<void> _loadEnvironmentVariables() async {
  try {
    // Спробуємо завантажити .env файл
    await dotenv.load(fileName: ".env");
    debugPrint("✅ .env file loaded successfully");

    // Перевіримо, чи завантажилися потрібні змінні
    final url = dotenv.env['SUPABASE_URL'];
    final key = dotenv.env['SUPABASE_ANON_KEY'];

    if (url != null && key != null) {
      debugPrint("✅ Supabase credentials found in .env");
      return;
    }
  } catch (e) {
    debugPrint("⚠️ Warning: Could not load .env file: $e");
  }

  // Fallback: використовуємо hardcoded значення, якщо .env не завантажився
  debugPrint("⚠️ Using fallback Supabase credentials");
  dotenv.env['SUPABASE_URL'] = 'https://qtgecgjfpewhjjrulhgg.supabase.co';
  dotenv.env['SUPABASE_ANON_KEY'] =
      'sb_publishable_40d9vcQnczZ2nXp6hxU89g_TFU9mMgY';
}

/// Ініціалізація Supabase з обробкою помилок
Future<void> _initializeSupabase() async {
  try {
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl == null || supabaseKey == null) {
      debugPrint("❌ Error: Supabase credentials not found!");
      debugPrint("   SUPABASE_URL: ${supabaseUrl != null ? '✓' : '✗'}");
      debugPrint("   SUPABASE_ANON_KEY: ${supabaseKey != null ? '✓' : '✗'}");
      throw Exception(
        "Supabase credentials are missing. Please check your .env file.",
      );
    }

    debugPrint("🔄 Initializing Supabase...");
    debugPrint("   URL: $supabaseUrl");

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
      debug: kDebugMode,
    );

    debugPrint("✅ Supabase initialized successfully!");
    debugPrint("   Instance: ${Supabase.instance.client}");
  } catch (e, stackTrace) {
    debugPrint("❌ Error initializing Supabase: $e");
    debugPrint("Stack trace: $stackTrace");
    rethrow; // Пробросимо помилку вище для обробки
  }
}

Future<void> _initWebEnvironment() async {
  // This will be called before app starts on web
  // The window.groqApiKey is injected by the build process
}

class AetheriaApp extends ConsumerWidget {
  const AetheriaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    return MaterialApp(
      title: 'AetheriaGraph',
      debugShowCheckedModeBanner: false,
      locale: currentLocale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        brightness: Brightness.dark,
        splashFactory: InkRipple.splashFactory,
        scaffoldBackgroundColor: const Color(0xFF1A1A1E), // Deep Black
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,

        textTheme: GoogleFonts.spaceGroteskTextTheme(
          ThemeData.dark().textTheme,
        ),

        switchTheme: SwitchThemeData(
          trackOutlineColor: WidgetStateProperty.all(Colors.transparent),

          thumbIcon: WidgetStateProperty.all(
            const Icon(Icons.clear, color: Colors.transparent, size: 0),
          ),

          // === ВБИВАЄМО РАМКУ/КРУЖОК ПРИ ЗАТИСКАННІ ТУМБЛЕРА ===
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          splashRadius: 0,

          thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFFFF007F); // Neon Pink
            }
            return const Color(0xFF1A1A1E); // Сірий
          }),

          trackColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFFFF007F).withOpacity(0.25);
            }
            return Colors.white.withOpacity(0.1);
          }),
        ),

        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF007F), // Neon Pink
          secondary: Color(0xFF7000FF), // Deep Purple
        ),
      ),
      // Web: показуємо splash, Mobile: показуємо AuthGate
      home: kIsWeb ? const WebSplashPage() : const AuthGate(),
    );
  }
}

/// Обгортка для AuthGate - перевіряє, чи Supabase ініціалізований
class AuthGateWrapper extends StatelessWidget {
  const AuthGateWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Перевіряємо, чи Supabase ініціалізований
    try {
      // Якщо Supabase ініціалізований, показуємо AuthGate
      return const AuthGate();
    } catch (e) {
      debugPrint("⚠️ Supabase not initialized: $e");
    }

    // Якщо Supabase не ініціалізований, показуємо екран завантаження
    return const Scaffold(
      backgroundColor: Color(0xFF050505),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFFFF007F)),
            SizedBox(height: 20),
            Text('Initializing...', style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
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

  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _checkInitialSession();
    _listenToAuthChanges();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  // Перевірка сесії при старті додатка
  void _checkInitialSession() {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (mounted) {
        setState(() {
          _currentSession = session;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("⚠️ Error checking session: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Постійний слухач змін (вхід, вихід, ресет)
  void _listenToAuthChanges() {
    try {
      _authSubscription = Supabase.instance.client.auth.onAuthStateChange
          .listen((data) {
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
    } catch (e) {
      debugPrint("⚠️ Error setting up auth listener: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF050505),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFFF007F)),
        ),
      );
    }

    // Platform-specific routing: Web vs Mobile
    if (_currentSession != null) {
      return kIsWeb ? const WebMainScreen() : const MainScreen();
    }

    return kIsWeb ? const WebSplashPage() : const AuthPage();
  }
}
