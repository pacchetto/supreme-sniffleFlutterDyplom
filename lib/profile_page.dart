// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Імпортуємо пакет для графіків

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Стани для перемикачів
  bool _bioSync = true;
  bool _darkImmersion = true;
  bool _zenNotifications = false;

  final Color neonPink = const Color(0xFFFF007F);

  // ІМІТАЦІЯ БЕКЕНДУ: дані фокусу по днях тижня (Пн - Нд)
  // Значення від 0 до 100, як на твоєму макеті
  final Map<String, double> _focusData = {
    'MON': 40,
    'TUE': 38,
    'WED': 55,
    'THU': 70,
    'FRI': 75,
    'SAT': 80,
    'SUN': 85,
  };

  // Метод для оновлення даних (імітація запису в БД)
  void _updateFocusData(String day, double value) {
    setState(() {
      _focusData[day] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              // 1. АВАТАР ТА РІВЕНЬ
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

              // ІМ'Я ТА ПІДПИС
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

              // 2. БЛОК СТАТИСТИКИ
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatCard("42h", "MEDITATED"),
                  _buildStatCard("12", "DAY STREAK", isMain: true),
                  _buildStatCard("85%", "CLARITY"),
                ],
              ),
              const SizedBox(height: 35),

              // 3. ЗАГОЛОВОК ГРАФІКА
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
                  const Text(
                    "7D   1M   ALL",
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // РЕАЛЬНИЙ КІБЕРПАНК ГРАФІК (Focus Level)
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
                    gridData: const FlGridData(
                      show: false,
                    ), // Прибираємо сітку заднього фону
                    borderData: FlBorderData(
                      show: false,
                    ), // Прибираємо рамку графіка
                    titlesData: FlTitlesData(
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      // Налаштування лівої осі (25, 50, 75, 100)
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
                      // Налаштування нижньої осі (Дні тижня)
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            List<String> days = _focusData.keys.toList();
                            if (value.toInt() >= 0 &&
                                value.toInt() < days.length) {
                              // Підсвічуємо неділю (SUN) рожевим, як на макеті
                              bool isSun = days[value.toInt()] == 'SUN';
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  days[value.toInt()],
                                  style: TextStyle(
                                    color: isSun ? neonPink : Colors.white38,
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
                        // Перетворюємо наші дані з Map у точки для графіка
                        spots: _focusData.values
                            .toList()
                            .asMap()
                            .entries
                            .map((e) => FlSpot(e.key.toDouble(), e.value))
                            .toList(),
                        isCurved: true, // Згладжена кіберпанк лінія
                        color: neonPink,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, index, barData, size) {
                            // Показуємо білу крапку лише на останній точці (Неділя), як на макеті
                            if (index == barData.spots.length - 1) {
                              return FlDotCirclePainter(
                                color: Colors.white,
                                strokeColor: neonPink,
                                strokeWidth: 3,
                                radius: 5,
                              );
                            }
                            // Для п'ятниці (індекс 4) покажемо маленьку рожеву цятку
                            if (index == 4) {
                              return FlDotCirclePainter(
                                color: neonPink,
                                strokeColor: neonPink,
                                radius: 3,
                              );
                            }
                            return FlDotCirclePainter(
                              radius: 0,
                              color: Colors.transparent,
                            );
                          },
                        ),
                        // Градієнт під лінією графіка
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
              const SizedBox(height: 20),

              // 🛠️ КАСТOМНИЙ ІНПУТ ДЛЯ ВНЕСЕННЯ ДАНИХ (Локальний бек)
              _buildDataInputSection(),

              const SizedBox(height: 35),

              // 4. СИСТЕМНІ НАЛАШТУВАННЯ
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
                icon: Icons.analytics_outlined,
                title: "Bio-Feedback Sync",
                value: _bioSync,
                onChanged: (val) => setState(() => _bioSync = val),
              ),
              _buildSettingsSwitch(
                icon: Icons.dark_mode_outlined,
                title: "Dark Immersion",
                value: _darkImmersion,
                onChanged: (val) => setState(() => _darkImmersion = val),
              ),
              _buildSettingsSwitch(
                icon: Icons.notifications_off_outlined,
                title: "Zen Notifications",
                value: _zenNotifications,
                onChanged: (val) => setState(() => _zenNotifications = val),
              ),

              const SizedBox(height: 25),

              // КНОПКА ВИХОДУ
              OutlinedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.logout, size: 16, color: neonPink),
                label: const Text(
                  "SIGN OUT",
                  style: TextStyle(
                    color: Color(0xFFFF007F),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: BorderSide(color: neonPink.withOpacity(0.4)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
              const SizedBox(height: 120), // Відступ під кастомний BottomBar
            ],
          ),
        ),
      ),
      extendBody: true,
    );
  }

  // Віджет для швидкої зміни даних (повзунки для кожного дня)
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
            "DEV PANEL: ADJUST FOCUS LEVEL",
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
                      SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 2,
                          activeTrackColor: neonPink,
                          inactiveTrackColor: Colors.white12,
                          thumbColor: neonPink,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 4,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 10,
                          ),
                        ),
                        child: SizedBox(
                          height: 80,
                          child: RotatedBox(
                            quarterTurns: 3, // Робимо повзунки вертикальними
                            child: Slider(
                              value: entry.value,
                              min: 0,
                              max: 100,
                              onChanged: (newValue) {
                                _updateFocusData(entry.key, newValue);
                              },
                            ),
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

  // Картка статистики
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
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // Перемикач налаштувань
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
        border: Border.all(color: Colors.white.withOpacity(0.02)),
      ),
      child: Theme(
        data: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
        child: SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          secondary: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: value ? neonPink : Colors.white54,
              size: 20,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(value ? 1 : 0.5),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          value: value,
          activeColor: neonPink,
          activeTrackColor: neonPink.withOpacity(0.2),
          inactiveTrackColor: Colors.white12,
          inactiveThumbColor: Colors.grey,
          onChanged: onChanged,
          splashRadius: 0.0,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
        ),
      ),
    );
  }
}
