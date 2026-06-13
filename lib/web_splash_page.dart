// lib/web_splash_page.dart
// BEAUTIFUL WEB SPLASH SCREEN WITH ANIMATED CIRCLES

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:aetheria_graph_app/l10n/app_localizations.dart';
import 'web_main_screen.dart';

class WebSplashPage extends StatefulWidget {
  const WebSplashPage({super.key});

  @override
  State<WebSplashPage> createState() => _WebSplashPageState();
}

class _WebSplashPageState extends State<WebSplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToApp() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const WebMainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF2D1B3D), // Deep purple
                const Color(0xFF000000), // Pure black
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  // ANIMATED CIRCLES
                  SizedBox(
                    width: 280,
                    height: 280,
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: ConcentricCirclesPainter(
                            progress: _controller.value,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 60),

                  // APP TITLE
                  const Text(
                    'Aetheria\nGraph',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w300,
                      height: 1.2,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // SUBTITLE
                  Text(
                    'CYBERPUNK ZEN',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFFFF007F).withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 4,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // DESCRIPTION
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Find peace in the noise.\nBreathwork for the digital age.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  // GET STARTED BUTTON
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: GestureDetector(
                      onTap: _navigateToApp,
                      child: Container(
                        width: double.infinity,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF007F), Color(0xFFFF0055)],
                          ),
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF007F).withOpacity(0.5),
                              blurRadius: 30,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'GET STARTED',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // VERSION INFO
                  Text(
                    'Web Demo v1.0.0',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.2),
                      fontSize: 11,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ConcentricCirclesPainter extends CustomPainter {
  final double progress;

  ConcentricCirclesPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // Draw 5 concentric circles
    for (int i = 1; i <= 5; i++) {
      final radius = maxRadius * (i / 5);
      final opacity = 0.15 + (0.15 * math.sin(progress * 2 * math.pi + i));

      // Outer glow
      final glowPaint = Paint()
        ..color = const Color(0xFFFF007F).withOpacity(opacity * 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawCircle(center, radius, glowPaint);

      // Main circle
      final paint = Paint()
        ..color = const Color(0xFFFF007F).withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawCircle(center, radius, paint);
    }

    // Central glowing dot
    final centralGlow = Paint()
      ..color = const Color(0xFFFF007F).withOpacity(0.8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    canvas.drawCircle(center, 8, centralGlow);

    final centralDot = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 6, centralDot);
  }

  @override
  bool shouldRepaint(ConcentricCirclesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
