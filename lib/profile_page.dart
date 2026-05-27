// ignore_for_file: deprecated_member_use

import 'package:aetheria_graph_app/providers/user_data_provider.dart';
import 'package:aetheria_graph_app/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'supabase_repository.dart'; // Твій репозиторій Supabase
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

// НОВИЙ ПРОВАЙДЕР ДЛЯ РЕЖИМУ РОЗРОБНИКА (ЩОБ ЗВ'ЯЗАТИ НАЛАШТУВАННЯ ТА ГРУ)
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
      debugPrint("Не вдалося дузвукувати графік в хмару: $e");
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

  // --- Змінні міні-гри Geometry Dash ---
  bool _gameStarted = false;
  int _gameScore = 0;
  Timer? _gameTimer;
  double _playerY = 0.0;
  double _velocity = 0.0;
  final double _gravity = 0.009;
  final double _jumpForce = -0.13;
  bool _isJumping = false;
  double _playerRotation = 0.0;
  double _obstacleX = 1.3;
  final double _obstacleSpeed = 0.035;
  int _obstacleType = 0;

  bool _isLoading = true;
  String _selectedPeriod = '7D';

  final Color neonPink = const Color(0xFFFF007F);
  int get _currentDayIndex => DateTime.now().weekday - 1;

  @override
  void initState() {
    super.initState();
    _initAppWithRealData();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
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
      _focusData[day] = value;
    });
    _repository.saveFocusDay(day, value);
  }

  @override
  Widget build(BuildContext context) {
    final userDataAsync = ref.watch(userDataProvider);
    final isDarkImmersion = ref.watch(darkImmersionProvider);
    final isBioSync = ref.watch(bioSyncProvider);
    final isDevMode = ref.watch(
      devModeProvider,
    ); // Слухаємо режим розробника тут

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
            final String title = cloudData['title'] ?? "CYBER MONK";
            final int level = cloudData['level'] ?? 1;

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
              username,
              title,
              level,
              isBioSync,
              isDarkImmersion,
              isDevMode, // Передаємо у контент сторінки
            );
          },
        ),
      ),
      extendBody: false,
    );
  }

  Widget _buildMainContent(
    String username,
    String title,
    int level,
    bool isBioSync,
    bool isDarkImmersion,
    bool isDevMode,
  ) {
    final Color accentColor = isBioSync ? neonPink : Colors.white54;

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
                      border: Border.all(color: accentColor.withOpacity(0.5)),
                    ),
                    child: Text(
                      "LVL $level",
                      style: TextStyle(
                        color: accentColor,
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
            title,
            style: TextStyle(
              color: accentColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
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

          // ГРАФІК
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

          // МІНІ-ГРА (З'ЯВЛЯЄТЬСЯ ТУТ, ЯКЩО АКТИВОВАНО З SETTINGS)
          if (isDevMode) ...[
            const SizedBox(height: 20),
            _buildDataInputSection(),
          ],
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

          // ТУМБЛЕР 1: Bio-Feedback Sync
          _buildSettingsSwitch(
            icon: Icons.bar_chart_rounded,
            title: "Bio-Feedback Sync",
            value: isBioSync,
            onChanged: (val) {
              ref.read(bioSyncProvider.notifier).toggle(val);
            },
          ),

          // ТУМБЛЕР 2: Dark Immersion
          _buildSettingsSwitch(
            icon: Icons.dark_mode_outlined,
            title: "Dark Immersion",
            value: isDarkImmersion,
            onChanged: (val) {
              ref.read(darkImmersionProvider.notifier).toggle(val);
            },
          ),

          // ТУМБЛЕР 3: Zen Notifications
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

          // КНОПКА НАЛАШТУВАНЬ ВІДРАЗУ ПІД ZEN NOTIFICATIONS
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

  Widget _buildDataInputSection() {
    return GestureDetector(
      onTap: _onGameTap,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF0D0D0D),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: neonPink.withOpacity(0.2)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: neonPink.withOpacity(0.5),
                    boxShadow: [BoxShadow(color: neonPink, blurRadius: 10)],
                  ),
                ),
              ),
              AnimatedAlign(
                duration: const Duration(milliseconds: 0),
                alignment: Alignment(-0.6, 0.45 + _playerY),
                child: Transform.rotate(
                  angle: _playerRotation,
                  child: Container(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: neonPink,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              AnimatedAlign(
                duration: const Duration(milliseconds: 0),
                alignment: Alignment(_obstacleX, 0.45),
                child: _buildObstacleWidget(),
              ),
              if (!_gameStarted)
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "⚡ CYBER RUNNER ⚡",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "TAP TO JUMP & UPDATE GRAPH",
                          style: TextStyle(color: Colors.white38, fontSize: 9),
                        ),
                      ],
                    ),
                  ),
                ),
              Positioned(
                top: 12,
                right: 16,
                child: Text(
                  "SYNC RATE: ${_gameScore ~/ 5}%",
                  style: TextStyle(
                    color: neonPink,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
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

  void _startGame() {
    if (_gameStarted) return;
    setState(() {
      _gameStarted = true;
      _gameScore = 0;
      _playerY = 0.0;
      _velocity = 0.0;
      _playerRotation = 0.0;
      _obstacleX = 1.3;
      _obstacleType = 0;
      _isJumping = false;
    });

    _gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      setState(() {
        _gameScore++;
        if (_isJumping || _playerY < 0) {
          _velocity += _gravity;
          _playerY += _velocity;
          _playerRotation += 0.15;
        }
        if (_playerY > 0) {
          _playerY = 0;
          _velocity = 0;
          _isJumping = false;
          _playerRotation = 0.0;
        }
        _obstacleX -= (_obstacleSpeed + (_gameScore / 30000));
        if (_obstacleX < -1.2) {
          _obstacleX = 1.3;
          _obstacleType = DateTime.now().microsecond % 3;
        }
        if (_obstacleX > -0.72 && _obstacleX < -0.48) {
          if (_obstacleType == 0 && _playerY > -0.12) _endGame();
          if (_obstacleType == 1 &&
              _obstacleX > -0.76 &&
              _obstacleX < -0.44 &&
              _playerY > -0.12) {
            _endGame();
          }
          if (_obstacleType == 2 && _playerY > -0.28) _endGame();
        }
      });
    });
  }

  void _onGameTap() {
    if (!_gameStarted) {
      _startGame();
    } else if (!_isJumping && _playerY == 0) {
      setState(() {
        _velocity = _jumpForce;
        _isJumping = true;
      });
    }
  }

  void _endGame() {
    _gameTimer?.cancel();
    setState(() => _gameStarted = false);
    double calculatedFocus = (_gameScore / 5.0).clamp(10.0, 100.0);
    List<String> days = _focusData.keys.toList();
    if (days.isNotEmpty) {
      _updateFocusData(days[_currentDayIndex], calculatedFocus);
    }
  }

  Widget _buildObstacleWidget() {
    if (_obstacleType == 0) {
      return ClipPath(
        clipper: CyberSpikeClipper(),
        child: Container(width: 20, height: 26, color: neonPink),
      );
    } else if (_obstacleType == 1) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipPath(
            clipper: CyberSpikeClipper(),
            child: Container(
              width: 16,
              height: 26,
              color: const Color(0xFFFF0055),
            ),
          ),
          ClipPath(
            clipper: CyberSpikeClipper(),
            child: Container(
              width: 16,
              height: 26,
              color: const Color(0xFFFF0055),
            ),
          ),
        ],
      );
    } else {
      return Container(
        width: 18,
        height: 42,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(color: neonPink.withOpacity(0.5), blurRadius: 6),
          ],
        ),
        child: Center(child: Container(width: 4, height: 30, color: neonPink)),
      );
    }
  }
}

class CyberSpikeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
