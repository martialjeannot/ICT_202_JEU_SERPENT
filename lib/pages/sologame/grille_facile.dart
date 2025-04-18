import 'package:flutter/material.dart';
//import 'package:untitled/pages/sologame/audio.dart'; // Pour le serpent
import 'eat.dart'; // Pour la nourriture
import 'snake.dart';
import 'package:flutter/rendering.dart';
import 'dart:async' as async;
import 'package:flame/components.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data'; // Pour Uint8List

class GrilleFacile extends StatefulWidget {
  final String nomDuJoueur;

  const GrilleFacile({super.key, required this.nomDuJoueur});

  @override
  State<GrilleFacile> createState() => _GrilleFacileState();
}

class _GrilleFacileState extends State<GrilleFacile> {
  late Snake _snake;
  late Eat _eat;
  late async.Timer _timer;
  Vector2 _lastDirection = Vector2(1, 0); // Direction initiale
  final GlobalKey _repaintBoundaryKey = GlobalKey();

  int _score = 0;
  int _temps = 0;
  bool _isPaused = false;
  bool _isGameOver = false;

  final Vector2 _gameSize = Vector2(400, 200);
  final int _snakeSpeed = 150; // Vitesse du serpent (150 ms)

  final ScreenshotController _screenshotController = ScreenshotController();
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _snake = Snake();
    _snake.vitesse = _snakeSpeed;

    _eat = Eat(Vector2(200, 200));
    _eat.relocate(_gameSize, _snake.body); // Relocaliser la nourriture

    _startGame(); // Démarrer le jeu automatiquement
  }

  void _startGame() {
    _lastDirection = _snake.direction;

    _timer = async.Timer.periodic(Duration(milliseconds: _snakeSpeed), (timer) {
      if (!_isPaused && !_isGameOver) {
        setState(() {
          _snake.move();
          _temps++;

          if (_checkCollision()) {
            _isGameOver = true;
            _timer.cancel();
            _playSound('sons/game_over.mp3'); // Jouer son de fin de jeu
            _takeScreenshot(context); // Prendre une capture d'écran

            if (mounted) {
              _showGameOverDialog();
            }
          }

          if (_snake.body.first.position.distanceTo(_eat.position) < 12) {
            _score += 10;
            _snake.grow(); // Ajoute un segment lorsque le serpent mange
            _eat.relocate(_gameSize, _snake.body); // Relocaliser la nourriture
            _playSound('sons/eat.mp3'); // Jouer son de nourriture mangée
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
              Navigator.of(context).pop(); // Retour à la page précédente
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
      _lastDirection = Vector2(1, 0);

      _eat = Eat(Vector2(200, 200));
      _eat.relocate(_gameSize, _snake.body);

      _score = 0;
      _temps = 0;
      _isPaused = false;
      _isGameOver = false;
    });

    _startGame(); // Redémarre le jeu
  }

  void _playSound(String path) async {
    await _audioPlayer.setSource(AssetSource(path));
    await _audioPlayer.resume();
  }

  bool _checkCollision() {
    final head = _snake.body.first.position;

    // Vérifiez si la tête du serpent dépasse les limites de la grille
    return head.x < 0 ||
        head.x + _snake.body.first.size.x > _gameSize.x ||
        head.y < 0 ||
        head.y + _snake.body.first.size.y > _gameSize.y ||
        _snake.body.skip(1).any((segment) => segment.position == head);
  }

  void _pauseGame() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _updateDirection(Vector2 newDirection) {
    if (_isOppositeDirection(_lastDirection, newDirection)) {
      // Ne rien faire si c’est la direction opposée
      return;
    }

    setState(() {
      _snake.changeDirection(newDirection);
      _lastDirection = newDirection; // Mettre à jour la dernière direction
    });
  }

  bool _isOppositeDirection(Vector2 d1, Vector2 d2) {
    return (d1.x + d2.x == 0 && d1.y + d2.y == 0);
  }

  // Prise de la capture d'écran
  Future<void> _takeScreenshot(BuildContext context) async {
    try {
      // Vérifiez que le RepaintBoundary est disponible
      if (_repaintBoundaryKey.currentContext != null) {
        RenderRepaintBoundary boundary =
            _repaintBoundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
        var image = await boundary.toImage();
        ByteData? byteData = await image.toByteData(
          format: ui.ImageByteFormat.png,
        );
        if (byteData != null) {
          Uint8List pngBytes = byteData.buffer.asUint8List();
          await _shareScreenshot(pngBytes);

          // Afficher un message de succès
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Capture d\'écran réussie !'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print("Erreur de capture d'écran : $e");
    }
  }

  Future<void> _shareScreenshot(Uint8List imageBytes) async {
    try {
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/screenshot.png';
      final file = File(imagePath);
      await file.writeAsBytes(imageBytes);

      await Share.share('Voici ma capture d\'écran !\n$imagePath');
    } catch (e) {
      print("Erreur lors du partage : $e");
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
                Text(
                  widget.nomDuJoueur,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Score: $_score",
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
                Text(
                  "Temps: $_temps s",
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
                ElevatedButton(
                  onPressed: _pauseGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                  ),
                  child: Text(_isPaused ? 'Reprendre' : 'Pause'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: RepaintBoundary(
              key: _repaintBoundaryKey, // Ajoutez le GlobalKey ici
              child: Screenshot(
                controller: _screenshotController,
                child: Container(
                  width: _gameSize.x,
                  height: _gameSize.y,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color.fromARGB(255, 59, 2, 2),
                    ),
                    color: Colors.grey[900],
                  ),
                  child: Stack(
                    children: [
                      // Grille de carreaux (10x10)
                      for (int i = 0; i < 10; i++)
                        for (int j = 0; j < 10; j++)
                          Positioned(
                            left: (i * (_gameSize.x / 10)),
                            top: (j * (_gameSize.y / 10)),
                            child: Container(
                              width: _gameSize.x / 10,
                              height: _gameSize.y / 10,
                              color: Colors.lime, // Couleur vert citron
                            ),
                          ),

                      // Segments du serpent
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

                      // Bouffe
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
          ),
          const SizedBox(height: 10),
          // Flèches de direction
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