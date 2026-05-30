// ignore_for_file: deprecated_member_use

import 'package:aetheria_graph_app/providers/user_data_provider.dart';
import 'package:aetheria_graph_app/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'supabase_repository.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aetheria_graph_app/utils/level_system.dart';
import 'cyber_runner_game.dart';

// ---------------------------------------------------------------------
// 1. ГЛОБАЛЬНІ РІВЕРПОД-ПРОВАЙДЕРИ ДЛЯ ТЕМИ ТА СИНХРОНІЗАЦІЇ
// ---------------------------------------------------------------------

final darkImmersionProvider =
    StateNotifierProvider<DarkImmersionNotifier, bool>((ref) {
      return DarkImmersionNotifier();
    });

class DarkImmersionNotifier extends StateNotifier<bool> {
  DarkImmersionNotifier() : super(true) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('dark_immersion') ?? true;
  }

  Future<void> toggle(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_immersion', value);
  }
}

final bioSyncProvider = StateNotifierProvider<BioSyncNotifier, bool>((ref) {
  return BioSyncNotifier();
});

class BioSyncNotifier extends StateNotifier<bool> {
  BioSyncNotifier() : super(true) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('bio_sync') ?? true;
  }

  Future<void> toggle(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('bio_sync', value);
  }
}

final devModeProvider = StateNotifierProvider<DevModeNotifier, bool>((ref) {
  return DevModeNotifier();
});

class DevModeNotifier extends StateNotifier<bool> {
  DevModeNotifier() : super(false);

  void enable() {
    state = true;
  }
}

// ---------------------------------------------------------------------
// 2. РЕПОЗИТОРІЙ ДЛЯ ІНШИХ ДАНИХ (Zen, Focus)
// ---------------------------------------------------------------------
class CyberRepository {
  static const String _keyZenNotifications = 'zen_notifications';
  static const String _keyFocusPrefix = 'focus_level_';
  final SupabaseRepository _supabaseRepo = SupabaseRepository();

  final Map<String, double> _defaultFocus = {
    'MON': 40.0,
    'TUE': 35.0,
    'WED': 60.0,
    'THU': 72.0,
    'FRI': 78.0,
    'SAT': 50.0,
    'SUN': 90.0,
  };

  Future<Map<String, dynamic>> loadLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    bool zenNotifications = prefs.getBool(_keyZenNotifications) ?? false;

    Map<String, double> focusData = {};
    for (String day in _defaultFocus.keys) {
      focusData[day] =
          prefs.getDouble('$_keyFocusPrefix$day') ?? _defaultFocus[day]!;
    }

    return {'zenNotifications': zenNotifications, 'focusData': focusData};
  }

  Future<void> saveZenSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyZenNotifications, value);
  }

  Future<void> saveFocusDay(String day, double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('$_keyFocusPrefix$day', value);

    try {
      await _supabaseRepo.updateFocusInCloud(day, value);
    } catch (e) {
      debugPrint("Не вдалося дублювати графік в хмару: $e");
    }
  }
}

// ---------------------------------------------------------------------
// 3. ІНТЕРФЕЙС СТОРІНКИ ПРОФІЛЮ
// ---------------------------------------------------------------------
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final CyberRepository _repository = CyberRepository();

  Map<String, double> _focusData = {
    'MON': 40.0,
    'TUE': 35.0,
    'WED': 60.0,
    'THU': 72.0,
    'FRI': 78.0,
    'SAT': 50.0,
    'SUN': 90.0,
  };

  bool _zenNotifications = false;
  bool _isLoading = true;
  String _selectedPeriod = '7D';

  final Color neonPink = const Color(0xFFFF007F);
  // Видимість міні-гри (за замовчуванням прихована)
  bool _isGameVisible = false;
  int get _currentDayIndex => DateTime.now().weekday - 1;

  @override
  void initState() {
    super.initState();
    _initAppWithRealData();

    // Слідкуємо за зміною режиму розробника в налаштуваннях, щоб показати гру
    ref.listen<SettingsState>(settingsProvider, (previous, next) {
      if (next.isDevMode == true && !_isGameVisible) {
        setState(() {
          _isGameVisible = true;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _initAppWithRealData() async {
    try {
      final data = await _repository.loadLocalData();
      setState(() {
        _zenNotifications = data['zenNotifications'];
        if (data['focusData'] != null &&
            (data['focusData'] as Map).isNotEmpty) {
          _focusData = Map<String, double>.from(data['focusData']);
        }
      });
    } catch (e) {
      debugPrint("Помилка ініціалізації: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _updateFocusData(String day, double value) {
    setState(() {
      _focusData[day] = double.parse(value.toStringAsFixed(1));
    });
    _repository.saveFocusDay(day, value);
  }

  @override
  Widget build(BuildContext context) {
    final userDataAsync = ref.watch(userDataProvider);
    final isDarkImmersion = ref.watch(darkImmersionProvider);
    final isBioSync = ref.watch(bioSyncProvider);
    final isDevMode = ref.watch(devModeProvider);

    final Color backgroundColor = isDarkImmersion
        ? const Color(0xFF000000)
        : const Color(0xFF1A1A1A);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: userDataAsync.when(
          loading: () => Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(neonPink),
            ),
          ),
          error: (err, stack) => Center(
            child: Text(
              "Помилка з'єднання: $err",
              style: TextStyle(color: neonPink),
            ),
          ),
          data: (cloudData) {
            final String username = cloudData['username'] ?? "Unknown User";
            final int userXp = cloudData['xp'] ?? 0;
            final levelInfo = getUserLevelInfo(xp: userXp);
            final String? avatarUrl = cloudData['avatar_url'];

            debugPrint("🔷 ProfilePage DEBUG: avatar_url = $avatarUrl");

            if (cloudData['focusData'] != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _focusData = Map<String, double>.from(
                      cloudData['focusData'],
                    );
                  });
                }
              });
            }

            return _buildMainContent(
              cloudData,
              username,
              levelInfo,
              isBioSync,
              isDarkImmersion,
              isDevMode,
            );
          },
        ),
      ),
      extendBody: false,
    );
  }

  Widget _buildMainContent(
    Map<String, dynamic> user,
    String username,
    UserLevelData levelInfo,
    bool isBioSync,
    bool isDarkImmersion,
    bool isDevMode,
  ) {
    final Color accentColor = isBioSync ? neonPink : Colors.white54;
    final Color rankColor = levelInfo.rank.color;
    final String? realAvatarUrl = user['avatar_url'];

    debugPrint("🔸 _buildMainContent: realAvatarUrl = $realAvatarUrl");

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
                    border: Border.all(color: accentColor, width: 2),
                    boxShadow: [
                      if (isBioSync)
                        BoxShadow(
                          color: neonPink.withOpacity(0.3),
                          blurRadius: 15,
                        ),
                    ],
                  ),
                  child: Container(
                    width: 108,
                    height: 108,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.06),
                    ),
                    child: ClipOval(
                      child: realAvatarUrl != null && realAvatarUrl.isNotEmpty
                          ? Image.network(
                              realAvatarUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                debugPrint(
                                  "❌ Помилка завантаження аватару: $error",
                                );
                                return Icon(
                                  Icons.person,
                                  size: 50,
                                  color: accentColor,
                                );
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value:
                                            loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                            : null,
                                        color: accentColor,
                                      ),
                                    );
                                  },
                            )
                          : Icon(Icons.person, size: 50, color: accentColor),
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
                      border: Border.all(color: rankColor.withOpacity(0.5)),
                    ),
                    child: Text(
                      "LVL ${levelInfo.level} - ${levelInfo.rank.titleUa.toUpperCase()}",
                      style: TextStyle(
                        color: rankColor,
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

          Text(
            username,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            levelInfo.rank.titleUa.toUpperCase(),
            style: TextStyle(
              color: rankColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
              shadows: [
                BoxShadow(color: rankColor.withOpacity(0.4), blurRadius: 10),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ПРОГРЕС БАР
          SizedBox(
            width: 160,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: levelInfo.progressPercent / 100.0,
                    backgroundColor: Colors.white.withOpacity(0.05),
                    color: rankColor,
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "${levelInfo.xp} XP / ${levelInfo.xpForNextLevel} XP to next lvl",
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // СТАТИСТИКА
          Opacity(
            opacity: _zenNotifications ? 0.5 : 1.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard("42h", "MEDITATED"),
                _buildStatCard("12", "DAY STREAK", isMain: true),
                _buildStatCard("85%", "CLARITY"),
              ],
            ),
          ),
          const SizedBox(height: 35),

          // ШАПКА ГРАФІКА
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(22),
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
                          color: isSelected ? accentColor : Colors.white38,
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

          // ГРАФІК FL_CHART
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
                                color: isToday ? accentColor : Colors.white38,
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
                    color: accentColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        if (index == _currentDayIndex) {
                          return FlDotCirclePainter(
                            color: Colors.white,
                            strokeColor: accentColor,
                            strokeWidth: 3,
                            radius: 5,
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
                          accentColor.withOpacity(0.2),
                          accentColor.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ІНТЕГРОВАНА МІНІ-ГРА (ТЕПЕР ЗАПУСКАЄТЬСЯ ЗАВЖДИ ЯК У МИНУЛИХ ВЕРСІЯХ)
          const SizedBox(height: 25),
          if (_isGameVisible)
            CyberRunnerGame(
            neonPink: neonPink,
            onGameFinished: (calculatedFocus) {
              List<String> days = _focusData.keys.toList();
              if (days.isNotEmpty &&
                  _currentDayIndex >= 0 &&
                  _currentDayIndex < days.length) {
                _updateFocusData(days[_currentDayIndex], calculatedFocus);
              }
            },
          ),
          const SizedBox(height: 35),

          // НАЛАШТУВАННЯ СИСТЕМИ
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
            value: isBioSync,
            onChanged: (val) {
              ref.read(bioSyncProvider.notifier).toggle(val);
            },
          ),

          _buildSettingsSwitch(
            icon: Icons.dark_mode_outlined,
            title: "Dark Immersion",
            value: isDarkImmersion,
            onChanged: (val) {
              ref.read(darkImmersionProvider.notifier).toggle(val);
            },
          ),

          _buildSettingsSwitch(
            icon: Icons.notifications_off_outlined,
            title: "Zen Notifications",
            value: _zenNotifications,
            onChanged: (val) {
              setState(() => _zenNotifications = val);
              _repository.saveZenSetting(val);
            },
          ),
          const SizedBox(height: 12),

          // КНОПКА НАЛАШТУВАНЬ
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.05),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.settings_outlined,
                    color: isBioSync ? neonPink : Colors.white54,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Settings & Privacy",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white24,
                    size: 12,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 80),
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
      clipBehavior: Clip.antiAlias,
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
