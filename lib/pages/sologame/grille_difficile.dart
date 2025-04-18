import 'package:flutter/material.dart';
import 'snake.dart';
import 'eat.dart';
import 'dart:async' as async;
import 'package:flame/components.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:math';

class GrilleDifficile extends StatefulWidget {
  final String nomDuJoueur;

  const GrilleDifficile({super.key, required this.nomDuJoueur});

  @override
  State<GrilleDifficile> createState() => _GrilleDifficileState();
}

class _GrilleDifficileState extends State<GrilleDifficile> {
  late Snake _snake;
  late Eat _eat;
  late async.Timer _timer;

  int _score = 0;
  int _temps = 0;
  bool _isPaused = false;
  bool _isGameOver = false;

  final Vector2 _gameSize = Vector2(350, 310);
  final ScreenshotController _screenshotController = ScreenshotController();
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    _snake = Snake();
    _snake.vitesse = 150;
    _eat = Eat(Vector2(0, 0));
    _relocateFood();
    _score = 0;
    _temps = 0;
    _isPaused = false;
    _isGameOver = false;
    _startGame();
  }

  void _startGame() {
    _timer = async.Timer.periodic(Duration(milliseconds: _snake.vitesse), (timer) {
      if (!_isPaused && !_isGameOver) {
        setState(() {
          _snake.move();
          _temps++;

          if (_checkCollision()) {
            _isGameOver = true;
            _timer.cancel();
            _playSound('sons/game_over.mp3');
            _takeScreenshot();
          }

          if (_snake.body.first.position.distanceTo(_eat.position) < 20) {
            _score += 10;
            _snake.grow();
            _relocateFood();
            _playSound('sons/eat.mp3');
          }

          if (_temps % 100 == 0 && _snake.vitesse > 50) {
            _snake.vitesse -= 10;
            _restartTimer();
          }
        });
      }
    });
  }

  void _restartTimer() {
    _timer.cancel();
    _timer = async.Timer.periodic(Duration(milliseconds: _snake.vitesse), (timer) {
      if (!_isPaused && !_isGameOver) {
        setState(() {
          _snake.move();
          _temps++;

          if (_checkCollision()) {
            _isGameOver = true;
            _timer.cancel();
            _playSound('sons/game_over.mp3');
            _takeScreenshot();
          }

          if (_snake.body.first.position.distanceTo(_eat.position) < 20) {
            _score += 10;
            _snake.grow();
            _relocateFood();
            _playSound('sons/eat.mp3');
          }

          if (_temps % 100 == 0 && _snake.vitesse > 50) {
            _snake.vitesse -= 10;
            _restartTimer();
          }
        });
      }
    });
  }

  bool _checkCollision() {
    final head = _snake.body.first;
    final centerX = head.position.x + head.size.x / 2;
    final centerY = head.position.y + head.size.y / 2;
    return !_isInsideTriangle(centerX, centerY, _gameSize.x, _gameSize.y);
  }

  bool _isInsideTriangle(double x, double y, double width, double height) {
    Vector2 p = Vector2(x, y);
    Vector2 a = Vector2(width / 2, 0);
    Vector2 b = Vector2(width, height);
    Vector2 c = Vector2(0, height);

    double sign(Vector2 p1, Vector2 p2, Vector2 p3) {
      return (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y);
    }

    double d1 = sign(p, a, b);
    double d2 = sign(p, b, c);
    double d3 = sign(p, c, a);

    bool hasNeg = (d1 < 0) || (d2 < 0) || (d3 < 0);
    bool hasPos = (d1 > 0) || (d2 > 0) || (d3 > 0);

    return !(hasNeg && hasPos);
  }

  void _relocateFood() {
    final rand = Random();
    double x, y;
    const padding = 10;

    do {
      x = padding + rand.nextDouble() * (_gameSize.x - 2 * padding);
      y = padding + rand.nextDouble() * (_gameSize.y - 2 * padding);
    } while (!_isInsideTriangle(x, y, _gameSize.x, _gameSize.y));

    _eat.relocate(Vector2(x, y), _snake.body);
  }

  void _pauseGame() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _updateDirection(Vector2 direction) {
    setState(() {
      _snake.changeDirection(direction);
    });
  }

  void _playSound(String path) async {
    await _audioPlayer.setSource(AssetSource(path));
    await _audioPlayer.resume();
  }

  Future<void> _takeScreenshot() async {
    final image = await _screenshotController.capture();
    if (image != null) {
      await Share.share('J’ai obtenu $_score points ! 🎮');
    }
  }

  void _restartOrQuit() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Fin du jeu"),
          content: Text("Votre score: $_score\n\nVoulez-vous rejouer ?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme le dialogue
                _startNewGame(); // Redémarre le jeu
              },
              child: const Text("Rejouer"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme le dialogue
                Navigator.of(context).pop(); // Quitte le jeu
              },
              child: const Text("Quitter"),
            ),
          ],
        );
      },
    );
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
              child: CustomPaint(
                size: Size(_gameSize.x, _gameSize.y),
                painter: TrianglePainter(),
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
                          color: Colors.orange,
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
                SizedBox(
                  width: 50,
                  child: GestureDetector(
                    onTap: () => _updateDirection(Vector2(-1, 0)),
                    child: Image.asset(
                      'assets/images/fleche_gauche.png',
                      width: 30,
                      height: 30,
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 50,
                      child: GestureDetector(
                        onTap: () => _updateDirection(Vector2(0, -1)),
                        child: Image.asset(
                          'assets/images/fleche_haut.png',
                          width: 30,
                          height: 30,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 50,
                      child: GestureDetector(
                        onTap: () => _updateDirection(Vector2(0, 1)),
                        child: Image.asset(
                          'assets/images/fleche_bas.png',
                          width: 30,
                          height: 30,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 50,
                  child: GestureDetector(
                    onTap: () => _updateDirection(Vector2(1, 0)),
                    child: Image.asset(
                      'assets/images/fleche_droite.png',
                      width: 30,
                      height: 30,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.red),
          if (_isGameOver) ...[
            // Afficher le message de fin de jeu ici
            Text(
              "Game Over",
              style: TextStyle(color: Colors.red, fontSize: 24),
            ),
            // Appeler la méthode pour redémarrer ou quitter
            ElevatedButton(
              onPressed: _restartOrQuit,
              child: const Text("Rejouer"),
            ),
          ],
        ],
      ),
    );
  }
}

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}