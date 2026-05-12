import 'dart:math';
import 'package:flutter/material.dart';

class SessionPage extends StatefulWidget {
  final Map<String, dynamic> techniqueData;

  const SessionPage({super.key, required this.techniqueData});

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  bool isPlaying = false;
  double breathSpeed = 0.5;
  String breathPhase = "READY";

  late Map<String, int> pattern;

  @override
  void initState() {
    super.initState();

    pattern = Map<String, int>.from(
      widget.techniqueData["pattern"] ??
          {"inhale": 4, "hold": 2, "exhale": 4, "holdAfter": 2},
    );

    // Створюємо контролер без фіксованої тривалості (ми будемо її міняти на льоту)
    _breathingController = AnimationController(vsync: this);

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.2).animate(
      CurvedAnimation(
        parent: _breathingController,
        curve: Curves.easeInOutQuart,
      ),
    );

    // ДОДАНО: Ініціалізація обертання (щоб не було помилки LateInitializationError)
    _rotationAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  // ГОЛОВНИЙ ЦИКЛ ДИХАННЯ
  void _runBreathingCycle() async {
    if (!isPlaying || !mounted) return;

    // 1. ВДИХ
    setState(() => breathPhase = "INHALE");
    _breathingController.duration = Duration(seconds: pattern["inhale"]!);
    await _breathingController.forward();
    if (!isPlaying || !mounted) return;

    // 2. ЗАТРИМКА (ВГОРІ)
    if (pattern["hold"]! > 0) {
      setState(() => breathPhase = "HOLD");
      await Future.delayed(Duration(seconds: pattern["hold"]!));
    }
    if (!isPlaying || !mounted) return;

    // 3. ВИДИХ
    setState(() => breathPhase = "EXHALE");
    _breathingController.duration = Duration(seconds: pattern["exhale"]!);
    await _breathingController.reverse();
    if (!isPlaying || !mounted) return;

    // 4. ЗАТРИМКА (ВНИЗУ)
    if (pattern["holdAfter"]! > 0) {
      setState(() => breathPhase = "HOLD");
      await Future.delayed(Duration(seconds: pattern["holdAfter"]!));
    }

    if (isPlaying && mounted) _runBreathingCycle();
  }

  void _togglePlay() {
    setState(() {
      isPlaying = !isPlaying;
      if (isPlaying) {
        _runBreathingCycle();
      } else {
        _breathingController.stop();
        breathPhase = "PAUSED";
      }
    });
  }

  // Видаляємо стару логіку швидкості або залишаємо порожню функцію, щоб не було помилок в build
  void _updateSpeed(double value) {
    setState(() {
      breathSpeed = value;
      // В цій версії швидкість жорстко прив'язана до патерну техніки.
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color themeColor =
        widget.techniqueData["color"] ?? const Color(0xFFFF007F);
    final String mode = widget.techniqueData["mode"] ?? "PRACTICE";
    final String title = widget.techniqueData["title"] ?? "Breathwork Session";

    return Scaffold(
      backgroundColor: const Color(0xFF0D0510),
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: themeColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        mode,
                        style: TextStyle(
                          color: themeColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 48), // Заглушка для симетрії
                ],
              ),
            ),

            const Spacer(),

            // Фаза дихання
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                breathPhase,
                key: ValueKey<String>(breathPhase),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 4.0,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title.toUpperCase(),
              style: TextStyle(
                color: themeColor.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),

            const Spacer(),

            // Мандала
            AnimatedBuilder(
              animation: _breathingController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: SizedBox(
                    width: 250,
                    height: 250,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Кільця та квадрати використовують _rotationAnimation
                        Transform.rotate(
                          angle: _rotationAnimation.value,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: themeColor.withOpacity(0.3),
                              ),
                            ),
                          ),
                        ),
                        Transform.rotate(
                          angle: -_rotationAnimation.value,
                          child: Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFC9A227).withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                        // Пульсуюче ядро
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: themeColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: themeColor.withOpacity(0.6),
                                blurRadius: 20 * _scaleAnimation.value,
                                spreadRadius: 5 * _scaleAnimation.value,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const Spacer(),

            // Панель плеєра
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 40.0,
              ),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Center(
                child: GestureDetector(
                  onTap: _togglePlay,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: themeColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: themeColor.withOpacity(0.4),
                          blurRadius: 30,
                        ),
                      ],
                    ),
                    child: Icon(
                      isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
