import 'dart:async';
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
  final double _jumpForce = -0.13;
  bool _isJumping = false;
  double _playerRotation = 0.0;
  double _obstacleX = 1.3;
  final double _obstacleSpeed = 0.035;
  int _obstacleType = 0;

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
                      bottom: 40,
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
                                color: widget.neonPink,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Перешкода
                    AnimatedAlign(
                      duration: const Duration(milliseconds: 0),
                      alignment: Alignment(_obstacleX, 0.45),
                      child: _buildObstacleWidget(),
                    ),
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
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 9,
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
                          fontSize: 11,
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

  Widget _buildObstacleWidget() {
    if (_obstacleType == 0) {
      return ClipPath(
        clipper: CyberSpikeClipper(),
        child: Container(width: 20, height: 26, color: widget.neonPink),
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
            BoxShadow(color: widget.neonPink.withOpacity(0.5), blurRadius: 6),
          ],
        ),
        child: Center(
          child: Container(width: 4, height: 30, color: widget.neonPink),
        ),
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
