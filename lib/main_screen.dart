// lib/main_screen.dart

import 'package:flutter/material.dart';
import 'dart:ui';
import 'dashboard_page.dart';
import 'ai_chat_page.dart';
import 'profile_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final Color neonPink = const Color(0xFFFF007F);

  // Список екранів
  final List<Widget> _screens = [
    const DashboardPage(),
    const AiChatPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    // ВАЖЛИВО: Перевіряємо, чи відкрита зараз клавіатура
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: const Color(0xFF050505),

      // ЗМІНЕНО: Дозволяємо екрану стискатися, щоб чат піднімався над клавіатурою
      resizeToAvoidBottomInset: true,

      // Використовуємо Stack, щоб плаваючий навбар був поверх контенту
      body: Stack(
        children: [
          // 1. Основний контент сторінки (Dashboard, Chat або Profile)
          IndexedStack(index: _currentIndex, children: _screens),

          // 2. Плаваюча напівпрозора панель (Liquid Glass Drop)
          // Показуємо навбар ТІЛЬКИ якщо клавіатура закрита
          if (!isKeyboardOpen)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: true, // Враховуємо "чубчик" знизу (SafeArea)
                child: Padding(
                  padding: const EdgeInsets.only(
                    bottom: 10.0,
                  ), // Маленький відступ від самого низу
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Центруємо по горизонталі
                    children: [
                      SizedBox(
                        width: 300, // Фіксована ширина панелі (капсули)
                        height: 70, // Висота панелі
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // --- ЕФЕКТ LIQUID GLASS (Рідкого Скла) ---
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                35,
                              ), // Створюємо форму капсули
                              child: BackdropFilter(
                                // Розмиття фону ПІД панеллю ( sigmaX і sigmaY)
                                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 9),
                                child: Container(
                                  decoration: BoxDecoration(
                                    // Колір "скла" (дуже світлий, напівпрозорий білий)
                                    color: neonPink.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(35),
                                    // Тонкий прозорий кордон (створює "відблиск" по краю)
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.12),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      // М'яка, розсіяна чорна тінь знизу (для об'єму)
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 30,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // --- ІКОНКИ НАВІГАЦІЇ ---
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildNavItem(0, Icons.space_dashboard_rounded),
                                _buildNavItem(1, Icons.auto_awesome),
                                _buildNavItem(2, Icons.person_rounded),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon) {
    final isActive = _currentIndex == index;
    const activeColor = Colors.white; // У склі іконки білі
    final inactiveColor = Colors.white.withOpacity(0.4);

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 80, // Збільшуємо зону кліку
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? activeColor : inactiveColor,
              size: 28,
              // М'яке світіння навколо активної іконки
              shadows: isActive
                  ? [
                      BoxShadow(
                        color: neonPink.withOpacity(0.8),
                        blurRadius: 10,
                      ),
                    ]
                  : [],
            ),
            const SizedBox(height: 4),
            // Маленький індикатор (крапка) під активною іконкою
            if (isActive)
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: activeColor,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(
                height: 4,
              ), // Заповнювач місця, щоб іконки не стрибали
          ],
        ),
      ),
    );
  }
}
