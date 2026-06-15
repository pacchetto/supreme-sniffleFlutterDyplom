import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  /// Ключ для зберігання прапорця гостьового режиму
  static const String guestModeKey = 'is_guest_mode';

  /// Перевіряє, чи активний зараз гостьовий (локальний) режим
  static Future<bool> isGuestMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(guestModeKey) ?? false;
  }

  // Ленива ініціалізація - отримуємо клієнт тільки коли потрібно
  SupabaseClient get _supabase {
    try {
      return Supabase.instance.client;
    } catch (e) {
      if (kDebugMode) debugPrint("⚠️ Supabase not initialized: $e");
      rethrow;
    }
  }

  // Перевірка, чи Supabase ініціалізований
  bool get isSupabaseInitialized {
    try {
      Supabase.instance.client;
      return true;
    } catch (e) {
      return false;
    }
  }

  // Стрім для відстеження стану авторизації (для автоматичного редиректу)
  Stream<AuthState> get authStateChanges {
    if (!isSupabaseInitialized) {
      throw Exception('Supabase is not initialized');
    }
    return _supabase.auth.onAuthStateChange;
  }

  // Перевірка, чи користувач зараз авторизований
  bool get isAuthenticated {
    if (!isSupabaseInitialized) return false;
    return _supabase.auth.currentSession != null;
  }

  // 1. ГОСТЬОВИЙ ВХІД (Локальний, БЕЗ запису в БД)
  // Гість працює офлайн з дефолтними даними. Нічого не пишеться в Supabase,
  // тому гостьові акаунти не займають місце в базі даних.
  Future<void> signInAsGuest() async {
    final prefs = await SharedPreferences.getInstance();
    // Чистимо будь-які залишки попереднього профілю
    await _clearLocalUserData(prefs);
    // Вмикаємо прапорець гостьового режиму
    await prefs.setBool(guestModeKey, true);
    if (kDebugMode) debugPrint("👤 Активовано локальний гостьовий режим");
  }

  // 1b. АНОНІМНИЙ ВХІД ЧЕРЕЗ SUPABASE (залишено для сумісності, не використовується)
  Future<User?> signInAnonymously() async {
    try {
      final AuthResponse response = await _supabase.auth.signInAnonymously();
      return response.user;
    } catch (e) {
      if (kDebugMode) debugPrint("⛔ Помилка анонімного входу: $e");
      rethrow;
    }
  }

  // 2.1 ПЕРЕВІРКА, ЧИ EMAIL ВЖЕ ЗАРЕЄСТРОВАНИЙ
  Future<bool> isEmailAlreadyRegistered(String email) async {
    try {
      final result = await _supabase.rpc(
        'email_exists',
        params: {'check_email': email.trim().toLowerCase()},
      );

      return result == true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint("⛔ Помилка перевірки email: $e");
      }
      rethrow;
    }
  }

  // 2.2 РЕЄСТРАЦІЯ ЧЕРЕЗ EMAIL + PASSWORD
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final AuthResponse response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      return response.user;
    } catch (e) {
      if (kDebugMode) debugPrint("⛔ Помилка реєстрації: $e");
      rethrow;
    }
  }

  // 3. ВХІД ЧЕРЕЗ EMAIL + PASSWORD
  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      // Реальний вхід — знімаємо гостьовий прапорець та чистимо локальні дані
      final prefs = await SharedPreferences.getInstance();
      await _clearLocalUserData(prefs);
      await prefs.remove(guestModeKey);
      return response.user;
    } catch (e) {
      if (kDebugMode) debugPrint("⛔ Помилка входу: $e");
      rethrow;
    }
  }

  // 4. ВИХІД ІЗ СИСТЕМИ
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      // Очищаємо локальні дані попереднього профілю (ім'я, аватар, налаштування)
      await _clearLocalUserData(prefs);
      // Знімаємо прапорець гостьового режиму
      await prefs.remove(guestModeKey);

      // Якщо це був реальний акаунт Supabase — виходимо з нього
      if (isAuthenticated) {
        await _supabase.auth.signOut();
      }
    } catch (e) {
      if (kDebugMode) debugPrint("⛔ Помилка виходу: $e");
      rethrow;
    }
  }

  /// Очищає локально збережені дані користувача (профіль, налаштування, кеш).
  /// Викликається при виході та при вході в гостьовий режим, щоб дані
  /// попереднього користувача не "перетікали" в новий сеанс.
  Future<void> _clearLocalUserData(SharedPreferences prefs) async {
    const keysToClear = [
      'user_name',
      'avatar_path',
      'dark_immersion',
      'bio_sync',
      'zen_notifications',
      'notifications_enabled',
      'sounds_enabled',
    ];
    for (final key in keysToClear) {
      await prefs.remove(key);
    }
  }

  // 5. ЗАПИТ НА СКИДАННЯ ПАРОЛЯ (Надсилає кібер-лінк на пошту)
  Future<void> resetPassword({required String email}) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: kIsWeb ? null : 'io.supabase.cybermonk://reset-callback',
      );
    } catch (e) {
      if (kDebugMode) debugPrint("⛔ Помилка запиту скидання пароля: $e");
      rethrow;
    }
  }

  // 6. ВСТАНОВЛЕННЯ НОВОГО ПАРОЛЯ
  Future<void> updatePassword({required String newPassword}) async {
    try {
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));
    } catch (e) {
      if (kDebugMode) debugPrint("⛔ Помилка оновлення пароля: $e");
      rethrow;
    }
  }
}
