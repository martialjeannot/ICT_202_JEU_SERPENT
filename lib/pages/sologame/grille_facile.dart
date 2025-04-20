import 'package:flutter/material.dart';
import 'eat.dart'; // Pour la nourriture
import 'snake.dart';
import 'package:flutter/rendering.dart';
import 'dart:async' as async;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flame/components.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:typed_data'; // Pour Uint8List
import 'audio.dart'; // Importer le fichier audio

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
  final AudioPlayer _audioPlayer = AudioPlayer();

  int _score = 0;
  int _temps = 0;
  bool _isPaused = false;
  bool _isGameOver = false;

  final Vector2 _gameSize = Vector2(400, 300);
  final int _snakeSpeed = 350; // Vitesse du serpent (150 ms)

  // Définir les dimensions d'une cellule de la grille
  final double _cellSize =
      20.0; // Taille d'une cellule de la grille (petit cercle)

  // Grille pour stocker les positions des cercles
  List<Vector2> _gridPositions = [];

  final ScreenshotController _screenshotController = ScreenshotController();
  late GameAudio _gameAudio;
  @override
  void initState() {
    super.initState();
    _initializeGrid(); // Initialiser la grille de cercles

    _snake = Snake();
    _snake.vitesse = _snakeSpeed;
    _snake.cellSize = _cellSize; // Définir la taille des segments du serpent
    _snake.initializeOnGrid(
      _gridPositions,
    ); // Initialiser le serpent sur la grille

    _eat = Eat(Vector2(0, 0));
    _eat.size = Vector2(
      _cellSize * 0.8,
      _cellSize * 0.8,
    ); // Taille de la nourriture légèrement plus petite
    _placeFoodOnGrid(); // Placer la nourriture sur la grille
    _gameAudio = GameAudio();
    _gameAudio.playGameSound();
    _startGame(); // Démarrer le jeu automatiquement
  }

  void _initializeGrid() {
    _gridPositions.clear();
    int cols = (_gameSize.x / _cellSize).floor();
    int rows = (_gameSize.y / _cellSize).floor();

    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        // Calculer les coordonnées centrales de chaque cellule
        double x = i * _cellSize;
        double y = j * _cellSize;
        _gridPositions.add(Vector2(x, y));
      }
    }
  }

  void _placeFoodOnGrid() {
    // Filtrer les positions de la grille qui ne sont pas occupées par le serpent
    List<Vector2> availablePositions =
        _gridPositions.where((pos) {
          return !_snake.body.any(
            (segment) =>
                segment.position.x == pos.x && segment.position.y == pos.y,
          );
        }).toList();

    if (availablePositions.isNotEmpty) {
      // Sélectionner une position aléatoire parmi les positions disponibles
      availablePositions.shuffle();
      Vector2 foodPosition = availablePositions.first;
      _eat.position = foodPosition;
    }
  }

  void _startGame() {
    _lastDirection = _snake.direction;

    _timer = async.Timer.periodic(Duration(milliseconds: _snakeSpeed), (timer) {
      if (!_isPaused && !_isGameOver) {
        setState(() {
          _snake.moveOnGrid(
            _gridPositions,
            _cellSize,
          ); // Déplacer le serpent sur la grille
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

          if (_snake.body.first.position.distanceTo(_eat.position) <
              _cellSize * 0.5) {
            _score += 10;
            _snake.grow(); // Ajoute un segment lorsque le serpent mange
            _placeFoodOnGrid(); // Relocaliser la nourriture sur la grille
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
      builder:
          (_) => AlertDialog(
            backgroundColor: Colors.black54,
            title: const Text(
              "Game Over",
              style: TextStyle(color: Colors.redAccent, fontSize: 24),
            ),
            content: Column(
              mainAxisSize:
                  MainAxisSize.min, // Ajuste la taille de la boîte de dialogue
              children: [
                Text(
                  "Votre score est $_score .\nVoulez-vous rejouer ?",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Image.asset(
                  'assets/images/images.jpg', // Assurez-vous d'avoir une image ici
                  height: 200,

                  fit: BoxFit.cover,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _restartGame();
                },
                child: const Text(
                  "Rejouer",
                  style: TextStyle(color: Colors.green),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Retour à la page précédente
                },
                child: const Text(
                  "Quitter",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void _restartGame() {
    setState(() {
      _initializeGrid();
      _snake = Snake();
      _snake.vitesse = _snakeSpeed;
      _snake.cellSize = _cellSize;
      _snake.initializeOnGrid(_gridPositions);
      _lastDirection = Vector2(1, 0);

      _eat = Eat(Vector2(0, 0));
      _eat.size = Vector2(_cellSize * 0.8, _cellSize * 0.8);
      _placeFoodOnGrid();

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
    if (head.x < 0 ||
        head.x + _cellSize > _gameSize.x ||
        head.y < 0 ||
        head.y + _cellSize > _gameSize.y) {
      return true;
    }

    // Vérifiez si la tête touche un autre segment du corps (sauf le dernier segment qui se déplace)
    for (int i = 1; i < _snake.body.length - 1; i++) {
      if (_snake.body[i].position.distanceTo(head) < _cellSize * 0.5) {
        return true;
      }
    }

    return false;
  }

  void _pauseGame() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _updateDirection(Vector2 newDirection) {
    if (_isOppositeDirection(_lastDirection, newDirection)) {
      // Ne rien faire si c'est la direction opposée
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

  // Ajoutez cette fonction pour demander les permissions
Future<bool> _requestPermissions() async {
  if (Platform.isAndroid) {
    if (await Permission.storage.request().isGranted) {
      return true;
    }
  } else if (Platform.isIOS) {
    if (await Permission.photos.request().isGranted) {
      return true;
    }
  }
  return false;
}


  // Prise de la capture d'écran
 Future<void> _takeScreenshot(BuildContext context) async {
  if (!kIsWeb) {
    // Demandez les permissions
    bool hasPermissions = await _requestPermissions();
    if (!hasPermissions) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Permissions refusées pour la capture d\'écran'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
  }
  
  try {
    // Vérifiez que le RepaintBoundary est disponible
    if (_repaintBoundaryKey.currentContext != null) {
      RenderRepaintBoundary boundary =
          _repaintBoundaryKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      var image = await boundary.toImage();
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData != null) {
        Uint8List pngBytes = byteData.buffer.asUint8List();
        
        // Vérifier la plateforme
        if (kIsWeb) {
          // Logique spécifique au web si nécessaire
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('La capture d\'écran n\'est pas encore supportée sur le web'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
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
    }
  } catch (e) {
    print("Erreur de capture d'écran : $e");
    // Afficher un message d'erreur à l'utilisateur
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erreur lors de la capture d\'écran: $e'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }
}

Future<void> _shareScreenshot(Uint8List imageBytes) async {
  try {
    // Vérifier si nous ne sommes pas sur le web
    if (!kIsWeb) {
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/screenshot.png';
      final file = File(imagePath);
      await file.writeAsBytes(imageBytes);

      await Share.share('Voici ma capture d\'écran !\n$imagePath');
    } else {
      // Pour le web, vous pourriez implémenter une solution alternative
      print("Le partage d'écran n'est pas disponible sur le web");
    }
  } catch (e) {
    print("Erreur lors du partage : $e");
  }
}
@override
void deactivate() {
  _gameAudio.stopGameSound(); // Arrêter le son du jeu
  _gameAudio.stopBackgroundMusic(); // Arrêter la musique de fond
  super.deactivate();
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
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Score: $_score",
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                ),
                Text(
                  "Temps: $_temps s",
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                ),
                ElevatedButton(
                  onPressed: _pauseGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(_isPaused ? 'Reprendre' : 'Pause'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: RepaintBoundary(
              key: _repaintBoundaryKey,
              child: Screenshot(
                controller: _screenshotController,
                child: Container(
                  width: _gameSize.x,
                  height: _gameSize.y,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.grey[900],
                  ),
                  child: Stack(
                    children: [
                      // Grille de cercles
                      ..._gridPositions.map(
                        (position) => Positioned(
                          left: position.x,
                          top: position.y,
                          child: Container(
                            width: _cellSize,
                            height: _cellSize,
                            decoration: BoxDecoration(
                              color: Colors.lime.withOpacity(0.3),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.lime, width: 1),
                            ),
                          ),
                        ),
                      ),

                      // Corps du serpent (segments)
                      ..._snake.body.asMap().entries.map((entry) {
                        int index = entry.key;
                        var segment = entry.value;

                        if (index == 0) {
                          // Tête du serpent
                          return Positioned(
                            left: segment.position.x,
                            top: segment.position.y,
                            child: Container(
                              width: _cellSize,
                              height: _cellSize,
                              decoration: BoxDecoration(
                                color: Colors.green[700],
                                shape: BoxShape.circle,
                              ),
                              child: Stack(
                                children: [
                                  // Œil gauche
                                  Positioned(
                                    left:
                                        _snake.direction.x > 0
                                            ? _cellSize * 0.6
                                            : _cellSize * 0.2,
                                    top:
                                        _snake.direction.y > 0
                                            ? _cellSize * 0.6
                                            : _cellSize * 0.2,
                                    child: Container(
                                      width: _cellSize * 0.25,
                                      height: _cellSize * 0.25,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Container(
                                          width: _cellSize * 0.1,
                                          height: _cellSize * 0.1,
                                          decoration: const BoxDecoration(
                                            color: Colors.black,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Œil droit
                                  Positioned(
                                    right:
                                        _snake.direction.x < 0
                                            ? _cellSize * 0.6
                                            : _cellSize * 0.2,
                                    top:
                                        _snake.direction.y > 0
                                            ? _cellSize * 0.6
                                            : _cellSize * 0.2,
                                    child: Container(
                                      width: _cellSize * 0.25,
                                      height: _cellSize * 0.25,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Container(
                                          width: _cellSize * 0.1,
                                          height: _cellSize * 0.1,
                                          decoration: const BoxDecoration(
                                            color: Colors.black,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else if (index == _snake.body.length - 1) {
                          // Queue du serpent
                          return Positioned(
                            left: segment.position.x + _cellSize * 0.1,
                            top: segment.position.y + _cellSize * 0.1,
                            child: Container(
                              width: _cellSize * 0.8,
                              height: _cellSize * 0.8,
                              decoration: BoxDecoration(
                                color: Colors.green[300],
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        } else {
                          // Corps du serpent
                          return Positioned(
                            left: segment.position.x,
                            top: segment.position.y,
                            child: Container(
                              width: _cellSize,
                              height: _cellSize,
                              decoration: BoxDecoration(
                                color:
                                    index % 2 == 0
                                        ? Colors.green
                                        : Colors.green[500],
                                shape:
                                    index % 3 == 0
                                        ? BoxShape.circle
                                        : BoxShape.rectangle,
                                borderRadius:
                                    index % 3 != 0
                                        ? BorderRadius.circular(5)
                                        : null,
                              ),
                            ),
                          );
                        }
                      }),

                      // Nourriture (cercle orange)
                      Positioned(
                        left: _eat.position.x + _cellSize * 0.1,
                        top: _eat.position.y + _cellSize * 0.1,
                        child: Container(
                          width: _eat.size.x,
                          height: _eat.size.y,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Container(
                              width: _eat.size.x * 0.5,
                              height: _eat.size.y * 0.5,
                              decoration: const BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Zone de contrôle par glissement occupe tout l'espace
          GestureDetector(
            onHorizontalDragUpdate: (details) {
              if (details.delta.dx > 0) {
                _updateDirection(Vector2(1, 0)); // Droite
              } else if (details.delta.dx < 0) {
                _updateDirection(Vector2(-1, 0)); // Gauche
              }
            },
            onVerticalDragUpdate: (details) {
              if (details.delta.dy > 0) {
                _updateDirection(Vector2(0, 1)); // Bas
              } else if (details.delta.dy < 0) {
                _updateDirection(Vector2(0, -1)); // Haut
              }
            },
            child: Container(
              height: 80, // Ajuste la hauteur si nécessaire
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey[700]!, Colors.black],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: const Center(
                child: Text(
                  'Glissez pour contrôler le serpent',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),

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
