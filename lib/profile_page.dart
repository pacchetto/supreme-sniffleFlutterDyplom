// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'supabase_repository.dart';

// ---------------------------------------------------------------------
// 1. РЕПОЗИТОРІЙ ДЛЯ ЛОКАЛЬНОГО ЗБЕРЕЖЕННЯ ДАНИХ (ПРОДАКШЕН ВАРІАНТ)
// ---------------------------------------------------------------------
class CyberRepository {
  // Ключі для збереження в SharedPreferences
  static const String _keyBioSync = 'bio_sync';
  static const String _keyDarkImmersion = 'dark_immersion';
  static const String _keyZenNotifications = 'zen_notifications';
  static const String _keyFocusPrefix = 'focus_level_';

  // Стандартні дефолтні значення, якщо додаток запускається вперше
  final Map<String, double> _defaultFocus = {
    'MON': 40.0,
    'TUE': 35.0,
    'WED': 60.0,
    'THU': 72.0,
    'FRI': 78.0,
    'SAT': 50.0,
    'SUN': 90.0,
  };

  // Завантаження всіх налаштувань користувача разом
  Future<Map<String, dynamic>> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    // Читаємо булеві значення налаштувань (якщо їх немає — беремо дефолт)
    bool bioSync = prefs.getBool(_keyBioSync) ?? true;
    bool darkImmersion = prefs.getBool(_keyDarkImmersion) ?? true;
    bool zenNotifications = prefs.getBool(_keyZenNotifications) ?? false;

    // Читаємо дані графіка по днях тижня
    Map<String, double> focusData = {};
    for (String day in _defaultFocus.keys) {
      focusData[day] =
          prefs.getDouble('$_keyFocusPrefix$day') ?? _defaultFocus[day]!;
    }

    return {
      'bioSync': bioSync,
      'darkImmersion': darkImmersion,
      'zenNotifications': zenNotifications,
      'focusData': focusData,
    };
  }

  // Збереження окремого налаштування (світч)
  Future<void> saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    String realKey = '';
    if (key == 'bioSync') realKey = _keyBioSync;
    if (key == 'darkImmersion') realKey = _keyDarkImmersion;
    if (key == 'zenNotifications') realKey = _keyZenNotifications;

    if (realKey.isNotEmpty) {
      await prefs.setBool(realKey, value);
    }
  }

  // Збереження оновленого значення фокусу для конкретного дня
  Future<void> saveFocusDay(String day, double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('$_keyFocusPrefix$day', value);
  }
}

// ---------------------------------------------------------------------
// 2. ІНТЕРФЕЙС СТОРІНКИ ПРОФІЛЮ
// ---------------------------------------------------------------------
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final SupabaseRepository _repository = SupabaseRepository();

  // Стани, які будуть синхронізуватися з базою даних
  Map<String, double> _focusData = {};
  bool _bioSync = true;
  bool _darkImmersion = true;
  bool _zenNotifications = false;

  bool _isLoading = true; // Екран завантаження при старті
  String _selectedPeriod = '7D';

  // Логіка адмін-панелі
  int _versionTapCount = 0;
  bool _isDevMode = false;

  final Color neonPink = const Color(0xFFFF007F);

  // Визначення поточного дня (0 = MON, 6 = SUN)
  int get _currentDayIndex => DateTime.now().weekday - 1;

  @override
  void initState() {
    super.initState();
    _initAppWithRealData();
  }

  // Асинхронне зчитування даних при запуску додатка
  Future<void> _initAppWithRealData() async {
    try {
      final data = await _repository.loadUserData();
      setState(() {
        _bioSync = data['bioSync'];
        _darkImmersion = data['darkImmersion'];
        _zenNotifications = data['zenNotifications'];
        _focusData = data['focusData'];
        _isLoading = false; // Вимикаємо завантаження
      });
    } catch (e) {
      debugPrint("Помилка ініціалізації бази даних: $e");
    }
  }

  // Функція зміни налаштувань користувача з миттєвим збереженням
  void _toggleSetting(String settingType, bool newValue) {
    setState(() {
      if (settingType == 'bioSync') _bioSync = newValue;
      if (settingType == 'darkImmersion') _darkImmersion = newValue;
      if (settingType == 'zenNotifications') _zenNotifications = newValue;
    });
    // Записуємо фізично на диск телефону
    _repository.saveSetting(settingType, newValue);
  }

  // Функція зміни рівня фокусу (наприклад, через повзунок в адмінці)
  void _updateFocusData(String day, double value) {
    setState(() {
      _focusData[day] = value;
    });
    // Записуємо фізично на диск телефону
    _repository.saveFocusDay(day, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(neonPink),
                ),
              )
            : _buildMainContent(),
      ),
      extendBody: true,
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        children: [
          // АВАТАР
          Center(
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: neonPink, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: neonPink.withOpacity(0.3),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: const CircleAvatar(
                    radius: 50,
                    backgroundColor: Color(0xFF151515),
                    backgroundImage: NetworkImage(
                      'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=150',
                    ),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF050505),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: neonPink.withOpacity(0.5)),
                    ),
                    child: Text(
                      "LVL 12",
                      style: TextStyle(
                        color: neonPink,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),

          const Text(
            "Alex V.",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "CYBER MONK",
            style: TextStyle(
              color: neonPink,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 30),

          // СТАТИСТИКА
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatCard("42h", "MEDITATED"),
              _buildStatCard("12", "DAY STREAK", isMain: true),
              _buildStatCard("85%", "CLARITY"),
            ],
          ),
          const SizedBox(height: 35),

          // ШАПКА ГРАФІКА ТА ФІЛЬТРИ
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(
                      color: neonPink,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Focus Level",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: ['7D', '1M', 'ALL'].map((period) {
                  bool isSelected = _selectedPeriod == period;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedPeriod = period),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: Text(
                        period,
                        style: TextStyle(
                          color: isSelected ? neonPink : Colors.white38,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // РЕАЛЬНИЙ ДИНАМІЧНИЙ ГРАФІК
          Container(
            height: 180,
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 20,
              right: 20,
              left: 10,
              bottom: 10,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF101010),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.03)),
            ),
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 25,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox();
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: Colors.white24,
                            fontSize: 10,
                          ),
                        );
                      },
                      reservedSize: 28,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        List<String> days = _focusData.keys.toList();
                        int index = value.toInt();
                        if (index >= 0 && index < days.length) {
                          bool isToday = index == _currentDayIndex;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              days[index],
                              style: TextStyle(
                                color: isToday ? neonPink : Colors.white38,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                      reservedSize: 24,
                    ),
                  ),
                ),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: _focusData.values
                        .toList()
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value))
                        .toList(),
                    isCurved: true,
                    color: neonPink,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        if (index == _currentDayIndex) {
                          return FlDotCirclePainter(
                            color: Colors.white,
                            strokeColor: neonPink,
                            strokeWidth: 3,
                            radius: 5,
                          );
                        }
                        if (index == (_currentDayIndex - 2 + 7) % 7) {
                          return FlDotCirclePainter(
                            color: neonPink,
                            strokeColor: neonPink,
                            radius: 3,
                          );
                        }
                        return FlDotCirclePainter(
                          radius: 0,
                          color: Colors.transparent,
                          strokeColor: Colors.transparent,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          neonPink.withOpacity(0.2),
                          neonPink.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // АДМІН-ПАНЕЛЬ (для тестування збереження)
          if (_isDevMode) ...[
            const SizedBox(height: 20),
            _buildDataInputSection(),
          ],
          const SizedBox(height: 35),

          // НАЛАШТУВАННЯ ТУМБЛЕРІВ
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "SYSTEM PREFERENCES",
              style: TextStyle(
                color: Colors.white38,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 12),

          _buildSettingsSwitch(
            icon: Icons.bar_chart_rounded,
            title: "Bio-Feedback Sync",
            value: _bioSync,
            onChanged: (val) => _toggleSetting('bioSync', val),
          ),
          _buildSettingsSwitch(
            icon: Icons.dark_mode_outlined,
            title: "Dark Immersion",
            value: _darkImmersion,
            onChanged: (val) => _toggleSetting('darkImmersion', val),
          ),
          _buildSettingsSwitch(
            icon: Icons.notifications_off_outlined,
            title: "Zen Notifications",
            value: _zenNotifications,
            onChanged: (val) => _toggleSetting('zenNotifications', val),
          ),
          const SizedBox(height: 25),

          // ВЕРСІЯ (Клікни 7 разів поспіль, щоб відкрити панель тестування даних)
          GestureDetector(
            onTap: () {
              if (_isDevMode) return;
              setState(() {
                _versionTapCount++;
                if (_versionTapCount >= 7) {
                  _isDevMode = true;
                }
              });
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "v1.0.4 - PRODUCTION RUNTIME",
                style: TextStyle(
                  color: Colors.white24,
                  fontSize: 10,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildDataInputSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: neonPink.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "LIVE DATA SIMULATOR (SAVES TO MEMORY)",
            style: TextStyle(
              color: Colors.white30,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _focusData.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Column(
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 9,
                        ),
                      ),
                      SizedBox(
                        height: 80,
                        child: RotatedBox(
                          quarterTurns: 3,
                          child: Slider(
                            value: entry.value,
                            min: 0,
                            max: 100,
                            activeColor: neonPink,
                            onChanged: (newValue) =>
                                _updateFocusData(entry.key, newValue),
                          ),
                        ),
                      ),
                      Text(
                        entry.value.toInt().toString(),
                        style: TextStyle(color: neonPink, fontSize: 10),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, {bool isMain = false}) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.28,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: isMain ? neonPink.withOpacity(0.05) : const Color(0xFF101010),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: isMain
              ? neonPink.withOpacity(0.4)
              : Colors.white.withOpacity(0.03),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: isMain ? neonPink : Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSwitch({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF101010),
        borderRadius: BorderRadius.circular(20),
      ),
      child: SwitchListTile(
        secondary: Icon(icon, color: value ? neonPink : Colors.white54),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(value ? 1 : 0.5),
            fontSize: 14,
          ),
        ),
        value: value,
        activeColor: neonPink,
        onChanged: onChanged,
      ),
    );
  }
}
