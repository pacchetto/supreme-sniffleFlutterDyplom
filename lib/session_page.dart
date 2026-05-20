import 'dart:async'; // Додано для роботи таймера сесії
import 'dart:math' as math;
import 'package:flutter/material.dart';

class SessionPage extends StatefulWidget {
  final Map<String, dynamic> techniqueData;

  const SessionPage({super.key, required this.techniqueData});

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage>
    with TickerProviderStateMixin {
  // Єдиний контролер для всього циклу дихання
  late AnimationController _breathingController;
  // Контролер для крутіння мандали
  late AnimationController _rotationController;

  // Нотифікатор для зміни тексту фази БЕЗ викликання загального setState
  final ValueNotifier<String> _phaseNotifier = ValueNotifier("READY");
  // РАБОЧИЙ ТАЙМEР СЕСІЇ
  Timer? _sessionTimer;
  final ValueNotifier<int> _elapsedSecondsNotifier = ValueNotifier(0);
  int get _totalSeconds => widget.techniqueData["durationSeconds"] ?? 300;

  bool isPlaying = false;
  double breathSpeed = 1.0;
  late Map<String, int> pattern;
  late double _totalDuration;

  @override
  void initState() {
    super.initState();

    pattern = Map<String, int>.from(
      widget.techniqueData["pattern"] ??
          {"inhale": 4, "hold": 7, "exhale": 8, "holdAfter": 0},
    );

    // Рахуємо загальний час одного повного циклу в секундах
    _totalDuration =
        (pattern["inhale"]! +
                pattern["hold"]! +
                pattern["exhale"]! +
                pattern["holdAfter"]!)
            .toDouble();

    _breathingController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: ((_totalDuration / breathSpeed) * 1000).round(),
      ),
    );

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );

    // СЛУХАЧ ДЛЯ ПЛАВНОЇ ЗМІНИ ТЕКСТУ ФАЗИ
    _breathingController.addListener(() {
      double t = _breathingController.value;
      double inhaleEnd = pattern["inhale"]! / _totalDuration;
      double holdEnd = (pattern["inhale"]! + pattern["hold"]!) / _totalDuration;
      double exhaleEnd =
          (pattern["inhale"]! + pattern["hold"]! + pattern["exhale"]!) /
          _totalDuration;

      String currentPhase = "READY";
      if (t <= inhaleEnd) {
        currentPhase = "INHALE";
      } else if (t <= holdEnd) {
        currentPhase = "HOLD";
      } else if (t <= exhaleEnd) {
        currentPhase = "EXHALE";
      } else {
        currentPhase = "HOLD";
      }

      if (_phaseNotifier.value != currentPhase) {
        _phaseNotifier.value = currentPhase;
      }
    });

    // Автоматичне безшовне зациклення анімації
    _breathingController.addStatusListener((status) {
      if (status == AnimationStatus.completed && isPlaying) {
        _breathingController.forward(from: 0.0);
      }
    });
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _rotationController.dispose();
    _phaseNotifier.dispose();
    _sessionTimer?.cancel(); // Очищення таймера
    _elapsedSecondsNotifier.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      isPlaying = !isPlaying;
      if (isPlaying) {
        _rotationController.repeat();
        _breathingController.forward(
          from: _breathingController.value == 1.0
              ? 0.0
              : _breathingController.value,
        );

        // Запуск підрахунку часу плеєра
        _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (_elapsedSecondsNotifier.value < _totalSeconds) {
            _elapsedSecondsNotifier.value++;
          } else {
            _togglePlay(); // Автопауза по завершенню
          }
        });
      } else {
        _breathingController.stop();
        _rotationController.stop();
        _sessionTimer?.cancel(); // Зупинка таймера
        _phaseNotifier.value = "PAUSED";
      }
    });
  }

  // Форматування секунд у гарний вигляд ММ:СС
  String _formatDuration(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Математичний прорахунок прогресу стиснення/розширення для художника
  double _calculateBreathingProgress(double globalValue) {
    double inhaleEnd = pattern["inhale"]! / _totalDuration;
    double holdEnd = (pattern["inhale"]! + pattern["hold"]!) / _totalDuration;
    double exhaleEnd =
        (pattern["inhale"]! + pattern["hold"]! + pattern["exhale"]!) /
        _totalDuration;

    if (globalValue <= inhaleEnd) {
      return globalValue / inhaleEnd;
    } else if (globalValue <= holdEnd) {
      return 1.0;
    } else if (globalValue <= exhaleEnd) {
      double factor = (globalValue - holdEnd) / (exhaleEnd - holdEnd);
      return 1.0 - factor;
    } else {
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color themeColor =
        widget.techniqueData["color"] ?? const Color(0xFF4AF2A1);
    final String title = widget.techniqueData["title"] ?? "4-7-8 Relax";
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF09110F),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // ВЕРХНЯ ПАНЕЛЬ
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
                        color: Colors.white60,
                        size: 32,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: themeColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "RELAXATION",
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // ТЕКСТ СТАНУ ДИХАННЯ
              ValueListenableBuilder<String>(
                valueListenable: _phaseNotifier,
                builder: (context, phase, child) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      phase,
                      key: ValueKey<String>(phase),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 44,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 8.0,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 4),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2.0,
                ),
              ),

              const SizedBox(height: 20),

              // АДАПТИВНИЙ КОНТЕЙНЕР ДЛЯ МАНДАЛИ (Замінено Expanded на SizedBox для сумісності зі скролом)
              SizedBox(
                height: screenWidth * 0.85,
                width: screenWidth * 0.85,
                child: Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double dynamicSize =
                          math.min(
                            constraints.maxWidth,
                            constraints.maxHeight,
                          ) *
                          0.92;

                      return AnimatedBuilder(
                        animation: Listenable.merge([
                          _breathingController,
                          _rotationController,
                        ]),
                        builder: (context, child) {
                          double breathProgress = _calculateBreathingProgress(
                            _breathingController.value,
                          );

                          return CustomPaint(
                            size: Size(dynamicSize, dynamicSize),
                            painter: PremiumMandalaPainter(
                              breathingProgress: breathProgress,
                              rotationProgress: _rotationController.value,
                              color: themeColor,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ПАНЕЛЬ КЕРУВАННЯ ШВИДКІСТЮ
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  children: [
                    Text(
                      "BREATH SPEED",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Slider(
                      value: breathSpeed,
                      min: 0.5,
                      max: 1.5,
                      activeColor: themeColor,
                      inactiveColor: Colors.white.withOpacity(0.05),
                      onChanged: (value) {
                        setState(() {
                          breathSpeed = value;
                          final double currentProgress =
                              _breathingController.value;
                          _breathingController.duration = Duration(
                            milliseconds:
                                ((_totalDuration / breathSpeed) * 1000).round(),
                          );
                          if (isPlaying) {
                            _breathingController.forward(from: currentProgress);
                          }
                        });
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "STILL",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.2),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "DYNAMIC",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.2),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // РОБОЧИЙ ПРОГРЕС СЕСІЇ
              Padding(
                padding: const EdgeInsets.only(
                  left: 32.0,
                  right: 32.0,
                  top: 20.0,
                ),
                child: ValueListenableBuilder<int>(
                  valueListenable: _elapsedSecondsNotifier,
                  builder: (context, elapsed, child) {
                    return Column(
                      children: [
                        LinearProgressIndicator(
                          value: elapsed / _totalSeconds,
                          backgroundColor: Colors.white.withOpacity(0.03),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            themeColor.withOpacity(0.6),
                          ),
                          minHeight: 2,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(elapsed),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.3),
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              _formatDuration(_totalSeconds),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.3),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),

              // ШИРОКА КНОПКА КЕРУВАННЯ
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 24.0,
                  top: 16.0,
                  left: 32.0,
                  right: 32.0,
                ),
                child: GestureDetector(
                  onTap: _togglePlay,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 62,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isPlaying ? Colors.transparent : themeColor,
                      borderRadius: BorderRadius.circular(31),
                      border: Border.all(color: themeColor, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: themeColor.withOpacity(isPlaying ? 0.1 : 0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: isPlaying ? themeColor : Colors.black87,
                      size: 36,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ХУДОЖНИК З МІКРО-ПУЛЬСАЦІЄЮ
class PremiumMandalaPainter extends CustomPainter {
  final double breathingProgress;
  final double rotationProgress;
  final Color color;

  PremiumMandalaPainter({
    required this.breathingProgress,
    required this.rotationProgress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final double smoothBreath = Curves.easeInOut.transform(breathingProgress);
    final double microPulse = 0.02 * math.sin(rotationProgress * math.pi * 4);

    for (int i = 1; i <= 8; i++) {
      final path = Path();

      double breathScale = 0.3 + (0.7 * smoothBreath) + microPulse;
      double baseRadius = maxRadius * (i / 8) * breathScale;

      if (baseRadius <= 5) continue;

      int wavePoints = 3 + (i % 4);
      double dynamicAmplitude =
          (5.0 + (i * 2.2)) *
          (0.8 + 0.5 * smoothBreath) *
          (1.0 + 0.2 * math.sin(rotationProgress * math.pi * 2 + i));

      double direction = i % 2 == 0 ? 1.0 : -1.0;
      double currentRotation =
          rotationProgress * 2 * math.pi * direction * (0.7 + i * 0.2);

      for (int angleDegrees = 0; angleDegrees <= 360; angleDegrees += 2) {
        double angleRadians = angleDegrees * math.pi / 180;

        double waveModulation =
            math.sin(angleRadians * wavePoints + currentRotation) +
            0.35 * math.sin(angleRadians * (wavePoints * 2) - currentRotation);

        double finalRadius = baseRadius + (waveModulation * dynamicAmplitude);

        double x = center.dx + finalRadius * math.cos(angleRadians);
        double y = center.dy + finalRadius * math.sin(angleRadians);

        if (angleDegrees == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();

      paint.color = color.withOpacity(0.04 + (1.0 - (i / 8)) * 0.55);
      canvas.drawPath(path, paint);
    }

    final innerGoldPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.amber.withOpacity(0.55);

    double goldRadius = 20 + (45 * smoothBreath) + (microPulse * 40);
    canvas.drawCircle(center, goldRadius, innerGoldPaint);

    final corePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    final coreRadius = 15.0 + (6.0 * smoothBreath) + (microPulse * 8);

    final shadowPaint = Paint()
      ..color = color.withOpacity(0.35)
      ..maskFilter = MaskFilter.blur(
        BlurStyle.normal,
        22 * (smoothBreath + 0.5),
      );

    canvas.drawCircle(center, coreRadius + 14, shadowPaint);
    canvas.drawCircle(center, coreRadius, corePaint);
  }

  @override
  bool shouldRepaint(covariant PremiumMandalaPainter oldDelegate) {
    return oldDelegate.breathingProgress != breathingProgress ||
        oldDelegate.rotationProgress != rotationProgress;
  }
}
