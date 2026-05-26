import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Стрім для відстеження стану авторизації (для автоматичного редиректу)
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Перевірка, чи користувач зараз авторизований
  bool get isAuthenticated => _supabase.auth.currentSession != null;

  // 1. АНОНІМНИЙ ВХІД (Швидкий старт)
  Future<User?> signInAnonymously() async {
    try {
      final AuthResponse response = await _supabase.auth.signInAnonymously();
      return response.user;
    } catch (e) {
      if (kDebugMode) debugPrint("⛔ Помилка анонімного входу: $e");
      rethrow;
    }
  }

  // 2. РЕЄСТРАЦІЯ ЧЕРЕЗ EMAIL + PASSWORD
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
      return response.user;
    } catch (e) {
      if (kDebugMode) debugPrint("⛔ Помилка входу: $e");
      rethrow;
    }
  }

  // 4. ВИХІД ІЗ СИСТЕМИ
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      if (kDebugMode) debugPrint("⛔ Помилка виходу: $e");
      rethrow;
    }
  }
}
