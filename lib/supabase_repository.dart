import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_repository.dart';

class SupabaseRepository {
  /// Дефолтні дані для гостьового (локального) профілю.
  /// Не зберігаються в БД — повертаються лише для відображення.
  static Map<String, dynamic> get guestDefaultData => {
    'username': 'Guest',
    'title': 'CYBER MONK',
    'xp': 0,
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

  /// Повертає ID поточної сесії користувача. Якщо не авторизований — тестовий UUID.
  String get _currentUserId {
    if (!isSupabaseInitialized) {
      return '00000000-0000-0000-0000-000000000000';
    }
    final sessionUserId = _supabase.auth.currentUser?.id;
    if (sessionUserId != null) return sessionUserId;
    return '00000000-0000-0000-0000-000000000000';
  }

  // 1. ЗАВАНТАЖЕННЯ ДАНИХ (ПРОФІЛЬ + ГРАФІК + ПРОГРЕС ЗА СЬОГОДНІ)
  Future<Map<String, dynamic>> loadUserData() async {
    // ГОСТЬОВИЙ РЕЖИМ: повертаємо локальні дефолтні дані без запитів до БД
    if (await AuthRepository.isGuestMode()) {
      if (kDebugMode) {
        debugPrint("👤 Гостьовий режим: повертаємо локальні дані (без БД)");
      }
      return guestDefaultData;
    }

    // Якщо немає валідної авторизованої сесії (наприклад, у момент переходу
    // між акаунтами / виходу) — повертаємо безпечні дефолтні дані замість
    // запиту до БД, який впав би через RLS і викликав екран помилки.
    if (!isSupabaseInitialized || _supabase.auth.currentUser == null) {
      if (kDebugMode) {
        debugPrint("⚠️ Немає активної сесії — повертаємо дефолтні дані");
      }
      return guestDefaultData;
    }

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

      // Якщо базових даних немає (перший запуск) — ініціалізуємо
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
        'xp': profileResponse['xp'] ?? 0,
        'bioSync': profileResponse['bio_sync'] ?? true,
        'darkImmersion': profileResponse['dark_immersion'] ?? true,
        'zenNotifications': profileResponse['zen_notifications'] ?? false,
        'avatar_url': profileResponse['avatar_url'],
        'focusData': focusData,
        'day_streak': profileResponse['day_streak'] ?? 0,
        'meditation_minutes': dailyResponse?['meditation_minutes'] ?? 0,
        'clarity_level': dailyResponse?['clarity_level'] ?? 0,
      };
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint("Помилка SupabaseRepository (load): $e");
        debugPrint("Стек викликів: $stackTrace");
      }
      // Не "ламаємо" UI помилкою (червоний екран / діалог).
      // Повертаємо безпечні дефолтні дані; реальні дані підвантажаться
      // при наступному refresh/invalidate, коли сесія стабілізується.
      return guestDefaultData;
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
        'username': 'Traveler',
        'title': 'CYBER NOVICE',
        'xp': 0,
        'bio_sync': true,
        'dark_immersion': true,
        'zen_notifications': false,
        'day_streak': 0,
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
      'username': 'Traveler',
      'title': 'CYBER NOVICE',
      'xp': 0,
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
      // dbColumn = 'wen'; // розкоментуй, якщо в БД стовпець називається 'wen'
    }

    await _supabase
        .from('focus_stats')
        .update({dbColumn: value})
        .eq('user_id', _currentUserId);
  }

  // 5. ОНОВЛЕННЯ ДЕННОГО ПРОГРЕСУ (Медитація / Фокус)
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
        // --- ПЕРША ТЕХНІКА ЗА СЬОГОДНІ ---
        await _supabase.from('daily_progress').insert({
          'user_id': userId,
          'date': today,
          'meditation_minutes': addMinutes,
          'clarity_level': clarityLevel ?? 80,
        });

        // Оновлюємо day_streak у таблиці profile
        final profileResponse = await _supabase
            .from('profile')
            .select('day_streak')
            .eq('id', userId)
            .maybeSingle();

        final currentStreak = (profileResponse?['day_streak'] as int?) ?? 0;

        await _supabase
            .from('profile')
            .update({'day_streak': currentStreak + 1})
            .eq('id', userId);

        if (kDebugMode) {
          debugPrint(
            "🔥 Новий день! Серія днів збільшена до: ${currentStreak + 1}",
          );
        }
      } else {
        // --- СЕСІЯ ВЖЕ НЕ ПЕРША ЗА СЬОГОДНІ ---
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
