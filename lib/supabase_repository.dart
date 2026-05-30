import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Повертає ID поточного користувача. Якщо не авторизований — віддає тестовий UUID.
  String get _currentUserId {
    final sessionUserId = _supabase.auth.currentUser?.id;
    if (sessionUserId != null) return sessionUserId;
    return '00000000-0000-0000-0000-000000000000';
  }

  // 1. ЗАВАНТАЖЕННЯ ДАНИХ (ПРОФІЛЬ + ГРАФІК + ПРОГРЕС ЗА СЬОГОДНІ)
  Future<Map<String, dynamic>> loadUserData() async {
    final userId = _currentUserId;
    final today = DateTime.now().toIso8601String().split('T').first;

    try {
      // Паралельний запуск запитів для мінімізації затримки мережі
      final responses = await Future.wait([
        _supabase.from('profile').select().eq('id', userId).maybeSingle(),
        _supabase
            .from('focus_stats')
            .select()
            .eq('user_id', userId)
            .maybeSingle(),
        // НОВЕ: Запит до денного прогресу
        _supabase
            .from('daily_progress')
            .select()
            .eq('user_id', userId)
            .eq('date', today)
            .maybeSingle(),
      ]);

      final profileResponse = responses[0];
      final statsResponse = responses[1];
      final dailyResponse = responses[2];

      // Якщо якихось базових даних немає (перший запуск) — ініціалізуємо
      if (profileResponse == null || statsResponse == null) {
        return await _createMissingUserRecords(
          userId,
          profileResponse,
          statsResponse,
        );
      }

      // Безпечний мапінг графіка
      Map<String, double> focusData = {
        'MON': _parseDbDouble(statsResponse['mon']),
        'TUE': _parseDbDouble(statsResponse['tue']),
        'wed': _parseDbDouble(statsResponse['wed'] ?? statsResponse['wen']),
        'THU': _parseDbDouble(statsResponse['thu']),
        'FRI': _parseDbDouble(statsResponse['fri']),
        'SAT': _parseDbDouble(statsResponse['sat']),
        'SUN': _parseDbDouble(statsResponse['sun']),
      };

      return {
        'username': profileResponse['username'] ?? 'Alex V.',
        'title': profileResponse['title'] ?? 'CYBER MONK',
        'level': profileResponse['level'] ?? 12,
        'xp': profileResponse['xp'] ?? 0,
        'bioSync': profileResponse['bio_sync'] ?? true,
        'darkImmersion': profileResponse['dark_immersion'] ?? true,
        'zenNotifications': profileResponse['zen_notifications'] ?? false,
        'avatar_url': profileResponse['avatar_url'],
        'focusData': focusData,
        // НОВЕ: Динамічні дані для статистики
        'day_streak': profileResponse['day_streak'] ?? 0,
        'meditation_minutes': dailyResponse?['meditation_minutes'] ?? 0,
        'clarity_level': dailyResponse?['clarity_level'] ?? 0,
      };
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint("Помилка SupabaseRepository (load): $e");
        debugPrint("Стек викликів: $stackTrace");
      }
      rethrow;
    }
  }

  /// Атомарна перевірка та створення відсутніх таблиць користувача
  Future<Map<String, dynamic>> _createMissingUserRecords(
    String userId,
    Map<String, dynamic>? existingProfile,
    Map<String, dynamic>? existingStats,
  ) async {
    if (existingProfile == null) {
      await _supabase.from('profile').insert({
        'id': userId,
        'username': 'Alex V.',
        'title': 'CYBER MONK',
        'level': 12,
        'xp': 1100,
        'bio_sync': true,
        'dark_immersion': true,
        'zen_notifications': false,
        'day_streak': 0, // Додано ініціалізацію стріка
      });
    }

    if (existingStats == null) {
      await _supabase.from('focus_stats').insert({
        'user_id': userId,
        'mon': 40.0,
        'tue': 35.0,
        'wed': 60.0,
        'thu': 72.0,
        'fri': 78.0,
        'sat': 50.0,
        'sun': 90.0,
      });
    }

    return {
      'username': 'Alex V.',
      'title': 'CYBER MONK',
      'level': 12,
      'xp': 1100,
      'bioSync': true,
      'darkImmersion': true,
      'zenNotifications': false,
      'avatar_url': null,
      'day_streak': 0,
      'meditation_minutes': 0,
      'clarity_level': 0,
      'focusData': {
        'MON': 40.0,
        'TUE': 35.0,
        'wed': 60.0,
        'THU': 72.0,
        'FRI': 78.0,
        'SAT': 50.0,
        'SUN': 90.0,
      },
    };
  }

  // 2. ОНОВЛЕННЯ ТУМБЛЕРІВ В ХМАРІ
  Future<void> saveSetting(String key, bool value) async {
    final Map<String, String> keyToColumnMapping = {
      'bioSync': 'bio_sync',
      'darkImmersion': 'dark_immersion',
      'zenNotifications': 'zen_notifications',
    };

    final columnName = keyToColumnMapping[key];
    if (columnName == null) return;

    await _supabase
        .from('profile')
        .update({columnName: value})
        .eq('id', _currentUserId);
  }

  // 3. ОНОВЛЕННЯ ХП В ХМАРІ
  Future<void> updateXpInCloud(int xp) async {
    await _supabase.from('profile').update({'xp': xp}).eq('id', _currentUserId);
  }

  /// Метод для додавання XP (використовується при завершенні техніки)
  Future<int> addXpAndGetNew(int xpToAdd) async {
    try {
      final profileResponse = await _supabase
          .from('profile')
          .select('xp')
          .eq('id', _currentUserId)
          .maybeSingle();

      final currentXp = (profileResponse?['xp'] as int?) ?? 0;
      final newXp = currentXp + xpToAdd;

      await _supabase
          .from('profile')
          .update({'xp': newXp})
          .eq('id', _currentUserId);

      if (kDebugMode) {
        debugPrint("✅ XP оновлено: $currentXp → $newXp (+$xpToAdd)");
      }

      return newXp;
    } catch (e) {
      if (kDebugMode) {
        debugPrint("⛔ Помилка при додаванні XP: $e");
      }
      rethrow;
    }
  }

  // 4. ОНОВЛЕННЯ ДНЯ ТИЖНЯ В ХМАРІ
  Future<void> updateFocusInCloud(String day, double value) async {
    String dbColumn = day.toLowerCase();

    if (dbColumn == 'wed') {
      // Якщо в БД стовпець називається 'wen', розкоментуйте наступний рядок:
      // dbColumn = 'wen';
    }

    await _supabase
        .from('focus_stats')
        .update({dbColumn: value})
        .eq('user_id', _currentUserId);
  }

  // 5. НОВЕ: ОНОВЛЕННЯ ДЕННОГО ПРОГРЕСУ (Медитація / Фокус)
  Future<void> logDailyProgress({
    required int addMinutes,
    int? clarityLevel,
  }) async {
    final userId = _currentUserId;
    final today = DateTime.now().toIso8601String().split('T').first;

    try {
      // Перевіряємо чи є вже запис на сьогодні
      final existing = await _supabase
          .from('daily_progress')
          .select('meditation_minutes')
          .eq('user_id', userId)
          .eq('date', today)
          .maybeSingle();

      if (existing == null) {
        // Якщо ще немає — створюємо новий запис
        await _supabase.from('daily_progress').insert({
          'user_id': userId,
          'date': today,
          'meditation_minutes': addMinutes,
          'clarity_level':
              clarityLevel ?? 80, // Дефолтна ясність, якщо не передана
        });
      } else {
        // Якщо є — плюсуємо хвилини
        final currentMins = existing['meditation_minutes'] as int? ?? 0;
        final updateData = <String, dynamic>{
          'meditation_minutes': currentMins + addMinutes,
        };

        if (clarityLevel != null) {
          updateData['clarity_level'] = clarityLevel;
        }

        await _supabase
            .from('daily_progress')
            .update(updateData)
            .eq('user_id', userId)
            .eq('date', today);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("⛔ Помилка при логуванні денного прогресу: $e");
      }
    }
  }

  /// Парсер для безпечного отримання double значень із динамічних відповідей БД
  double _parseDbDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return 0.0;
  }
}
