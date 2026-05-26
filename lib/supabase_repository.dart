import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ТИМЧАСОВИЙ ТЕСТОВИЙ ID. Коли зробимо екран входу, замінимо цей рядок на:
  // String? get _currentUserId => _supabase.auth.currentUser?.id;
  // Зараз ми використовуємо згенерований UUID для тестів без авторизації:
  String get _testUserId => '00000000-0000-0000-0000-000000000000';

  // 1. ЗАВАНТАЖЕННЯ ДАНИХ (ПРОФІЛЬ + ГРАФІК)
  Future<Map<String, dynamic>> loadUserData() async {
    final userId = _testUserId;

    try {
      // Спробуємо прочитати профіль користувача
      final profileResponse = await _supabase
          .from('profile')
          .select()
          .eq('id', userId)
          .maybeSingle(); // maybeSingle не викидає помилку, якщо рядка немає

      // Якщо користувача взагалі немає в базі (перший запуск) — створюємо його автоматично!
      if (profileResponse == null) {
        return await _createNewTestUser(userId);
      }

      // Якщо профіль є, завантажуємо його тижневий графік
      final statsResponse = await _supabase
          .from('focus_stats')
          .select()
          .eq('user_id', userId)
          .single();

      // Мапимо дані графіка з Postgres (float8) у Dart (Map<String, double>)
      Map<String, double> focusData = {
        'MON': (statsResponse['mon'] as num).toDouble(),
        'TUE': (statsResponse['tue'] as num).toDouble(),
        'WED': (statsResponse['wed'] as num).toDouble(),
        'THU': (statsResponse['thu'] as num).toDouble(),
        'FRI': (statsResponse['fri'] as num).toDouble(),
        'SAT': (statsResponse['sat'] as num).toDouble(),
        'SUN': (statsResponse['sun'] as num).toDouble(),
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

  // Функція створення дефолтного тестового юзера, якщо таблиці пусті
  Future<Map<String, dynamic>> _createNewTestUser(String userId) async {
    // 1. Вставляємо рядок у profile
    await _supabase.from('profile').insert({
      'id': userId,
      'username': 'Alex V.',
      'title': 'CYBER MONK',
      'level': 12,
      'bio_sync': true,
      'dark_immersion': true,
      'zen_notifications': false,
    });

    // 2. Вставляємо початковий графік у focus_stats
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

    // Повертаємо початкові дані
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
        'WED': 60.0,
        'THU': 72.0,
        'FRI': 78.0,
        'SAT': 50.0,
        'SUN': 90.0,
      },
    };
  }

  // 2. ОНОВЛЕННЯ ТУМБЛЕРІВ В ХМАРІ
  Future<void> saveSetting(String key, bool value) async {
    String columnName = '';
    if (key == 'bioSync') columnName = 'bio_sync';
    if (key == 'darkImmersion') columnName = 'dark_immersion';
    if (key == 'zenNotifications') columnName = 'zen_notifications';

    if (columnName.isNotEmpty) {
      await _supabase
          .from('profile')
          .update({columnName: value})
          .eq('id', _testUserId);
    }
  }

  // 3. ОНОВЛЕННЯ ДНЯ ТИЖНЯ В ХМАРІ
  Future<void> saveFocusDay(String day, double value) async {
    String columnName = day.toLowerCase(); // 'MON' -> 'mon'
    await _supabase
        .from('focus_stats')
        .update({columnName: value})
        .eq('user_id', _testUserId);
  }

  Future<void> updateFocusInCloud(String day, double value) async {
    String dbColumn = day.toLowerCase();

    // Мапінг для твого костиля 'wen' в базі даних
    if (dbColumn == 'wed') dbColumn = 'wen';

    await _supabase
        .from('focus_stats')
        .update({dbColumn: value})
        .eq(
          'user_id',
          _testUserId,
        ); // Або id, залежно як у тебе зв'язані таблиці
  }
}
