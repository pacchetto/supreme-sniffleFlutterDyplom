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

  // 1. ЗАВАНТАЖЕННЯ ДАНИХ (ПРОФІЛЬ + ГРАФІК)
  Future<Map<String, dynamic>> loadUserData() async {
    final userId = _currentUserId;

    try {
      // Паралельний запуск запитів для мінімізації затримки мережі
      final responses = await Future.wait([
        _supabase.from('profile').select().eq('id', userId).maybeSingle(),
        _supabase
            .from('focus_stats')
            .select()
            .eq('user_id', userId)
            .maybeSingle(),
      ]);

      final profileResponse = responses[0];
      final statsResponse = responses[1];

      // Якщо якихось даних немає (перший запуск або збій створення) — ініціалізуємо
      if (profileResponse == null || statsResponse == null) {
        return await _createMissingUserRecords(
          userId,
          profileResponse,
          statsResponse,
        );
      }

      // Безпечний мапінг з підтримкою альтернативного написання середи ('wen')
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
        'bioSync': profileResponse['bio_sync'] ?? true,
        'darkImmersion': profileResponse['dark_immersion'] ?? true,
        'zenNotifications': profileResponse['zen_notifications'] ?? false,
        'focusData': focusData,
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
        'bio_sync': true,
        'dark_immersion': true,
        'zen_notifications': false,
      });
    }

    if (existingStats == null) {
      await _supabase.from('focus_stats').insert({
        'user_id': userId,
        'mon': 40.0,
        'tue': 35.0,
        'wed':
            60.0, // Сюди запишеться 'wed', або змініть на 'wen' відповідно до назви стовпця у вашій БД
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
      'bioSync': true,
      'darkImmersion': true,
      'zenNotifications': false,
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

  // 3. ОНОВЛЕННЯ ДНЯ ТИЖНЯ В ХМАРІ (Уніфікований метод)
  Future<void> updateFocusInCloud(String day, double value) async {
    String dbColumn = day.toLowerCase();

    // Обробка костиля/специфіки назви стовпця середи в базі даних
    if (dbColumn == 'wed') {
      // Якщо в БД стовпець називається 'wen', розкоментуйте наступний рядок:
      // dbColumn = 'wen';
    }

    await _supabase
        .from('focus_stats')
        .update({dbColumn: value})
        .eq('user_id', _currentUserId);
  }

  /// Парсер для безпечного отримання double значень із динамічних відповідей БД
  double _parseDbDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return 0.0;
  }
}
