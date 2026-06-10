// lib/web_main_screen.dart
// WEB-ONLY MAIN SCREEN WITH 3-TAB NAVIGATION (Dashboard + AI Chat + Settings)

import 'package:flutter/material.dart';
import 'dart:ui';
import 'dashboard_page.dart';
import 'ai_chat_page.dart';
import 'web_settings_page.dart';

class WebMainScreen extends StatefulWidget {
  const WebMainScreen({super.key});

  @override
  State<WebMainScreen> createState() => _WebMainScreenState();
}

class _WebMainScreenState extends State<WebMainScreen> {
  int _currentIndex = 0;
  final Color neonPink = const Color(0xFFFF007F);

  // Список екранів (3: Dashboard, AI Chat, Settings)
  final List<Widget> _screens = [
    const DashboardPage(),
    const AiChatPage(),
    const WebSettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    // Перевіряємо, чи відкрита зараз клавіатура
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: const Color(0xFF000000), // Pure AMOLED Black background
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Scaffold(
            backgroundColor: const Color(0xFF050505),
            resizeToAvoidBottomInset: true,
            body: Stack(
              children: [
                // 1. Основний контент сторінки (Dashboard або AI Chat)
                IndexedStack(index: _currentIndex, children: _screens),

                // 2. Плаваюча напівпрозора панель (Liquid Glass Drop)
                // Показуємо навбар ТІЛЬКИ якщо клавіатура закрита
                if (!isKeyboardOpen)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      bottom: true,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 280, // Ширина для 3 іконок
                              height: 70,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // --- ЕФЕКТ LIQUID GLASS (Рідкого Скла) ---
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(35),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: 6,
                                        sigmaY: 9,
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: neonPink.withOpacity(0.05),
                                          borderRadius: BorderRadius.circular(
                                            35,
                                          ),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(
                                              0.12,
                                            ),
                                            width: 1.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.1,
                                              ),
                                              blurRadius: 30,
                                              spreadRadius: 5,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // --- ІКОНКИ НАВІГАЦІЇ (3 ІКОНКИ) ---
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildNavItem(
                                        0,
                                        Icons.space_dashboard_rounded,
                                      ),
                                      _buildNavItem(1, Icons.auto_awesome),
                                      _buildNavItem(2, Icons.settings_rounded),
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
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon) {
    final isActive = _currentIndex == index;
    const activeColor = Colors.white;
    final inactiveColor = Colors.white.withOpacity(0.4);

    return GestureDetector(
      onTap: () {
        setState(() {
          // Обмежуємо індекс до 0-2 (3 екрани)
          if (index >= 0 && index < _screens.length) {
            _currentIndex = index;
          }
        });
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? activeColor : inactiveColor,
              size: 28,
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
              const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
