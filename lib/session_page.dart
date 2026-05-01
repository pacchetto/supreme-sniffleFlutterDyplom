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
  double breathSpeed = 0.5; // Значення слайдера (0.0 до 1.0)
  String breathPhase = "READY"; // INHALE, EXHALE, HOLD

  @override
  void initState() {
    super.initState();

    // Налаштовуємо анімацію дихання
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // Базовий час вдиху
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.2).animate(
      CurvedAnimation(
        parent: _breathingController,
        curve: Curves.easeInOutSine,
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.linear),
    );

    // Слухаємо фази анімації, щоб змінювати текст
    _breathingController.addStatusListener((status) {
      if (status == AnimationStatus.forward) {
        setState(() => breathPhase = "INHALE");
      } else if (status == AnimationStatus.reverse) {
        setState(() => breathPhase = "EXHALE");
      } else if (status == AnimationStatus.completed) {
        // Затримка на вершині (Hold)
        setState(() => breathPhase = "HOLD");
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && isPlaying) _breathingController.reverse();
        });
      } else if (status == AnimationStatus.dismissed) {
        // Затримка внизу
        setState(() => breathPhase = "HOLD");
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && isPlaying) _breathingController.forward();
        });
      }
    });
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      isPlaying = !isPlaying;
      if (isPlaying) {
        if (_breathingController.status == AnimationStatus.dismissed ||
            _breathingController.status == AnimationStatus.reverse) {
          _breathingController.forward();
        } else {
          _breathingController.reverse();
        }
      } else {
        _breathingController.stop();
        breathPhase = "PAUSED";
      }
    });
  }

  void _updateSpeed(double value) {
    setState(() {
      breathSpeed = value;
      // Змінюємо тривалість анімації в залежності від повзунка
      // 0.0 = 8 секунд (повільно), 1.0 = 2 секунди (швидко)
      int seconds = 8 - (value * 6).toInt();
      _breathingController.duration = Duration(seconds: seconds);
      _breathingController.reverseDuration = Duration(seconds: seconds);
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
            // ВЕРХНЯ ПАНЕЛЬ (App Bar)
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
                          boxShadow: [
                            BoxShadow(color: themeColor, blurRadius: 5),
                          ],
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
                  IconButton(
                    icon: const Icon(Icons.more_horiz, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            const Spacer(),

            // ТЕКСТ ВДИХ/ВИДИХ
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

            // ЦЕНТРАЛЬНА АНІМАЦІЯ (Мандала)
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
                        // Зовнішні кільця
                        Transform.rotate(
                          angle: _rotationAnimation.value,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: themeColor.withOpacity(0.3),
                                width: 1,
                                style: BorderStyle.solid,
                              ),
                            ),
                          ),
                        ),
                        Transform.rotate(
                          angle: -_rotationAnimation.value,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFC9A227).withOpacity(0.5),
                                width: 1,
                              ), // Золотистий квадрат
                            ),
                          ),
                        ),
                        Transform.rotate(
                          angle: _rotationAnimation.value,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: themeColor.withOpacity(0.8),
                                width: 1.5,
                              ), // Рожевий квадрат
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

            // СЛАЙДЕР ШВИДКОСТІ
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "SLOW",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 10,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Text(
                        "BREATH SPEED",
                        style: TextStyle(
                          color: themeColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Text(
                        "FAST",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 10,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: themeColor,
                      inactiveTrackColor: Colors.white.withOpacity(0.1),
                      thumbColor: themeColor,
                      trackHeight: 4,
                      overlayColor: themeColor.withOpacity(0.2),
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 8,
                      ),
                    ),
                    child: Slider(value: breathSpeed, onChanged: _updateSpeed),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ПАНЕЛЬ ПЛЕЄРА
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 30.0,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                children: [
                  // Прогрес бар
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: 0.4, // Тут в майбутньому буде реальний прогрес
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "04:20",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        "10:00",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Кнопки управління
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.replay_5_rounded,
                          color: Colors.white.withOpacity(0.6),
                          size: 32,
                        ),
                        onPressed: () {},
                      ),
                      GestureDetector(
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
                                spreadRadius: 5,
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
                      IconButton(
                        icon: Icon(
                          Icons.forward_5_rounded,
                          color: Colors.white.withOpacity(0.6),
                          size: 32,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
