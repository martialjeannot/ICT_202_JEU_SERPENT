
import 'package:flutter/material.dart';
import 'snake.dart'; // Pour le serpent
import 'eat.dart'; // Pour la nourriture
import 'dart:async' as async;
import 'package:flame/components.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import 'dart:math'; // Pour les calculs aléatoires

class GrilleMoyenne extends StatefulWidget {
  final String nomDuJoueur;

  const GrilleMoyenne({super.key, required this.nomDuJoueur});

  @override
  State<GrilleMoyenne> createState() => _GrilleMoyenneState();
}

class _GrilleMoyenneState extends State<GrilleMoyenne> {
  late Snake _snake;
  late Eat _eat;
  late async.Timer _timer;

  int _score = 0;
  int _temps = 0;
  bool _isPaused = false;
  bool _isGameOver = false;

  final double _gameRadius = 200.0; // Rayon du cercle
  final int _snakeSpeed = 150;

  final ScreenshotController _screenshotController = ScreenshotController();
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _snake = Snake();
    _snake.vitesse = _snakeSpeed;

    _eat = Eat(Vector2(0, 0));
    _relocateFood();

    _startGame();
  }

  void _startGame() {
    _timer = async.Timer.periodic(Duration(milliseconds: _snakeSpeed), (timer) {
      if (!_isPaused && !_isGameOver) {
        setState(() {
          _snake.move();
          _temps++;

          if (_checkCollision()) {
            _isGameOver = true;
            _timer.cancel();
            _playSound('sons/game_over.mp3');
            _takeScreenshot();

            _showGameOverDialog();
          }

          if (_snake.body.first.position.distanceTo(_eat.position) < 12) {
            _score += 10;
            _snake.grow();
            _relocateFood();
            _playSound('sons/eat.mp3');
          }
        });
      }
    });
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Game Over"),
        content: Text("Votre score est $_score.\nVoulez-vous rejouer ?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _restartGame();
            },
            child: const Text("Rejouer"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text("Quitter"),
          ),
        ],
      ),
    );
  }

  void _restartGame() {
    setState(() {
      _snake = Snake();
      _snake.vitesse = _snakeSpeed;
      _score = 0;
      _temps = 0;
      _isPaused = false;
      _isGameOver = false;
      _relocateFood();
    });

    _startGame();
  }

  void _playSound(String path) async {
    await _audioPlayer.setSource(AssetSource(path));
    await _audioPlayer.resume();
  }

bool _checkCollision() {
  final head = _snake.body.first;
  final headCenter = head.position + head.size / 2;
  final circleCenter = Vector2(_gameRadius, _gameRadius);

  final distance = headCenter.distanceTo(circleCenter);
  return distance > _gameRadius;
}


  void _pauseGame() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _updateDirection(Vector2 newDirection) {
    if (_isOppositeDirection(_snake.direction, newDirection)) return;

    setState(() {
      _snake.changeDirection(newDirection);
    });
  }

  bool _isOppositeDirection(Vector2 d1, Vector2 d2) {
    return (d1.x + d2.x == 0 && d1.y + d2.y == 0);
  }

void _relocateFood() {
  final rand = Random();
  final safeRadius = _gameRadius - _eat.size.x / 2;

  double radius = safeRadius * sqrt(rand.nextDouble());
  double angle = rand.nextDouble() * 2 * pi;

  double x = _gameRadius + radius * cos(angle) - _eat.size.x / 2;
  double y = _gameRadius + radius * sin(angle) - _eat.size.y / 2;

  _eat.relocate(Vector2(x, y), _snake.body);
}


  Future<void> _takeScreenshot() async {
    try {
      final image = await _screenshotController.capture();
      if (image != null) {
        await Share.share('J’ai obtenu $_score points ! 🎮');
      }
    } catch (e) {
      print("Erreur de capture d'écran : $e");
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Column(
        children: [
          const Divider(color: Colors.white),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.nomDuJoueur,
                    style: const TextStyle(
                        fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                Text("Score: $_score",
                    style: const TextStyle(fontSize: 16, color: Colors.white)),
                Text("Temps: $_temps s",
                    style: const TextStyle(fontSize: 16, color: Colors.white)),
                ElevatedButton(
                  onPressed: _pauseGame,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800]),
                  child: Text(_isPaused ? 'Reprendre' : 'Pause'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Screenshot(
              controller: _screenshotController,
              child: Container(
                width: _gameRadius * 2,
                height: _gameRadius * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[900],
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: Stack(
                  children: [
                    for (var segment in _snake.body)
                      Positioned(
                        left: segment.position.x,
                        top: segment.position.y,
                        child: Container(
                          width: segment.size.x,
                          height: segment.size.y,
                          color: Colors.green,
                        ),
                      ),
                    Positioned(
                      left: _eat.position.x,
                      top: _eat.position.y,
                      child: Container(
                        width: _eat.size.x,
                        height: _eat.size.y,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => _updateDirection(Vector2(-1, 0)),
                  child: Image.asset('assets/images/fleche_gauche.png', width: 40),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => _updateDirection(Vector2(0, -1)),
                      child: Image.asset('assets/images/fleche_haut.png', width: 40),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => _updateDirection(Vector2(0, 1)),
                      child: Image.asset('assets/images/fleche_bas.png', width: 40),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => _updateDirection(Vector2(1, 0)),
                  child: Image.asset('assets/images/fleche_droite.png', width: 40),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.red),
          if (_isGameOver)
            const Text(
              "Game Over",
              style: TextStyle(color: Colors.red, fontSize: 24),
            ),
        ],
      ),
    );
  }
}
