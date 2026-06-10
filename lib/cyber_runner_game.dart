import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class CyberRunnerGame extends StatefulWidget {
  final Function(double score)
  onGameFinished; // Колбек для передачі результату в профіль
  final Color neonPink;

  const CyberRunnerGame({
    super.key,
    required this.onGameFinished,
    this.neonPink = const Color(0xFFFF007F),
  });

  @override
  State<CyberRunnerGame> createState() => _CyberRunnerGameState();
}

class _CyberRunnerGameState extends State<CyberRunnerGame> {
  bool _gameStarted = false;
  int _gameScore = 0;
  Timer? _gameTimer;
  double _playerY = 0.0;
  double _velocity = 0.0;
  final double _gravity = 0.009;
  final double _jumpForce = -0.10;
  bool _isJumping = false;
  double _playerRotation = 0.0;

  // Множинні перешкоди
  final List<Map<String, dynamic>> _obstacles = [];
  final double _obstacleSpeed = 0.035;
  final double _minObstacleDistance =
      1.5; // Мінімальна відстань між перешкодами
  final Random _random = Random();

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  void _startGame() {
    if (_gameStarted) return;
    setState(() {
      _gameStarted = true;
      _gameScore = 0;
      _playerY = 0.0;
      _velocity = 0.0;
      _playerRotation = 0.0;
      _isJumping = false;
      _obstacles.clear();

      // Створюємо початкові перешкоди (тільки одна на старті)
      _spawnObstacle(1.5);
    });

    _gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      setState(() {
        _gameScore++;

        // Фізика гравця
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

        // Оновлення перешкод
        double speedBoost = _gameScore / 30000;
        for (var obstacle in _obstacles) {
          obstacle['x'] -= (_obstacleSpeed + speedBoost);
        }

        // Видалення перешкод, що вийшли за екран
        _obstacles.removeWhere((obstacle) => obstacle['x'] < -1.2);

        // Створення нових перешкод (рідше)
        if (_obstacles.isEmpty || _obstacles.last['x'] < 0.5) {
          double newX = _obstacles.isEmpty
              ? 1.5
              : _obstacles.last['x'] +
                    _minObstacleDistance +
                    (_random.nextDouble() * 0.6);
          _spawnObstacle(newX);
        }

        // Перевірка колізій
        _checkCollisions();
      });
    });
  }

  void _spawnObstacle(double x) {
    int type = _random.nextInt(5); // 5 типів перешкод
    _obstacles.add({'x': x, 'type': type});
  }

  void _checkCollisions() {
    for (var obstacle in _obstacles) {
      double obstacleX = obstacle['x'];
      int obstacleType = obstacle['type'];

      // Перевірка, чи гравець перетинається з перешкодою
      if (obstacleX > -0.72 && obstacleX < -0.48) {
        bool collision = false;

        switch (obstacleType) {
          case 0: // Трикутник
            if (_playerY > -0.12) collision = true;
            break;
          case 1: // Подвійний трикутник
            if (obstacleX > -0.76 && obstacleX < -0.44 && _playerY > -0.12) {
              collision = true;
            }
            break;
          case 2: // Висока коробка
            if (_playerY > -0.28) collision = true;
            break;
          case 3: // Круг
            if (_playerY > -0.15) collision = true;
            break;
          case 4: // Діамант
            if (_playerY > -0.18) collision = true;
            break;
        }

        if (collision) {
          _endGame();
          break;
        }
      }
    }
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

    // Передаємо фінальний результат назад у батьківський віджет профілю
    widget.onGameFinished(calculatedFocus);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'CYBER RUNNER',
          style: TextStyle(
            color: widget.neonPink,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          child: GestureDetector(
            onTap: _onGameTap,
            child: Container(
              margin: const EdgeInsets.all(20),
              height: 400,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF0D0D0D),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: widget.neonPink.withOpacity(0.2)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    // Лінія підлоги
                    Positioned(
                      bottom: 80,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          color: widget.neonPink.withOpacity(0.5),
                          boxShadow: [
                            BoxShadow(color: widget.neonPink, blurRadius: 10),
                          ],
                        ),
                      ),
                    ),
                    // Гравець (Куб)
                    AnimatedAlign(
                      duration: const Duration(milliseconds: 0),
                      alignment: Alignment(-0.6, 0.25 + _playerY),
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
                                color: widget.neonPink,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Всі перешкоди
                    ..._obstacles.map((obstacle) {
                      return AnimatedAlign(
                        duration: const Duration(milliseconds: 0),
                        alignment: Alignment(obstacle['x'], 0.25),
                        child: _buildObstacleWidget(obstacle['type']),
                      );
                    }).toList(),
                    // Екран старту
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
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "⚡ CYBER RUNNER ⚡",
                                style: TextStyle(
                                  color: widget.neonPink,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 2,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "TAP TO JUMP",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Поточний рахунок / Sync Rate
                    Positioned(
                      top: 12,
                      right: 16,
                      child: Text(
                        "SYNC RATE: ${_gameScore ~/ 5}%",
                        style: TextStyle(
                          color: widget.neonPink,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildObstacleWidget(int type) {
    switch (type) {
      case 0: // Трикутник (рожевий)
        return ClipPath(
          clipper: CyberSpikeClipper(),
          child: Container(width: 20, height: 26, color: widget.neonPink),
        );

      case 1: // Подвійний трикутник (червоний)
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

      case 2: // Висока коробка (рожева)
        return Container(
          width: 22,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: widget.neonPink, width: 2),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: widget.neonPink.withOpacity(0.6),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 6,
              height: 34,
              decoration: BoxDecoration(
                color: widget.neonPink,
                boxShadow: [
                  BoxShadow(
                    color: widget.neonPink.withOpacity(0.8),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
        );

      case 3: // Круг (блакитний)
        return Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF00D9FF), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00D9FF).withOpacity(0.6),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF00D9FF),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00D9FF).withOpacity(0.8),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
        );

      case 4: // Діамант (фіолетовий)
        return ClipPath(
          clipper: DiamondClipper(),
          child: Container(
            width: 26,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: const Color(0xFFAA00FF), width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFAA00FF).withOpacity(0.6),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFAA00FF),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFAA00FF).withOpacity(0.8),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

      default:
        return Container();
    }
  }
}

// Трикутник
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

// Діамант
class DiamondClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width, 0); // Верх
    path.lineTo(size.width, size.height / 2); // Право
    path.lineTo(size.width, size.height); // Низ
    path.lineTo(0, size.height / 2); // Ліво
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
