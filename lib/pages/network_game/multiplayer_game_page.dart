import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
//import 'package:flutter/foundation.dart'; // Pour kIsWeb

class MultiplayerGamePage extends StatefulWidget {
  final bool isHost;
  final String? serverAddress; // Gardez ceci comme String

  const MultiplayerGamePage({
    super.key,
    required this.isHost,
    this.serverAddress,
  });

  @override
  State<MultiplayerGamePage> createState() => _MultiplayerGamePageState();
}

class _MultiplayerGamePageState extends State<MultiplayerGamePage> {
  late RawDatagramSocket socket;
  late InternetAddress opponentAddress;
  bool isGameStarted = false;
  String status = "En attente de connexion...";
  Timer? gameLoopTimer;
  final int rows = 20;
  final int cols = 20;
  final Duration tickRate = const Duration(milliseconds: 200);

  List<Point<int>> mySnake = [const Point(5, 10)];
  List<Point<int>> opponentSnake = [const Point(15, 10)];
  Point<int> food = const Point(10, 10);
  String direction = "right";
  int myScore = 0;

  @override
  void initState() {
    super.initState();
    initNetwork();
  }

  void initNetwork() async {
    try {
      if (widget.isHost) {
        // Vérifiez si nous sommes sur le web
        socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 4567);
        status = "En attente d'un joueur...";
        socket.listen(handleSocketEvent);
      } else {
        // Pour le client
        socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
        opponentAddress = InternetAddress(widget.serverAddress!); // Convertir String en InternetAddress
        socket.send(utf8.encode("JOIN_REQUEST"), opponentAddress, 4567);
        socket.listen(handleSocketEvent);
      }
      setState(() {});
    } catch (e) {
      setState(() {
        status = "Erreur réseau : $e";
      });
    }
  }

  void handleSocketEvent(RawSocketEvent event) {
    if (event == RawSocketEvent.read) {
      final datagram = socket.receive();
      if (datagram == null) return;
      final message = utf8.decode(datagram.data);

      if (widget.isHost && message == "JOIN_REQUEST") {
        opponentAddress = datagram.address;
        socket.send(utf8.encode("JOIN_ACCEPTED"), opponentAddress, 4567);
        startGame();
      } else if (!widget.isHost && message == "JOIN_ACCEPTED") {
        startGame();
      } else if (message.startsWith("SNAKE:")) {
        final coords = message.substring(6).split("|");
        opponentSnake = coords.map((c) {
          final parts = c.split(",");
          return Point(int.parse(parts[0]), int.parse(parts[1]));
        }).toList();
      } else if (message.startsWith("FOOD:")) {
        final parts = message.substring(5).split(",");
        food = Point(int.parse(parts[0]), int.parse(parts[1]));
      }
    }
  }

  void startGame() {
    setState(() {
      status = "Partie en cours !";
      isGameStarted = true;
    });

    gameLoopTimer = Timer.periodic(tickRate, (_) => updateGame());
  }

  void updateGame() {
    setState(() {
      final head = mySnake.first;
      Point<int> newHead;

      switch (direction) {     
        case "up":
          newHead = Point(head.x, head.y - 1);
          break;
        case "down":
          newHead = Point(head.x, head.y + 1);
          break;
        case "left":
          newHead = Point(head.x - 1, head.y);
          break;
        case "right":
        default:
          newHead = Point(head.x + 1, head.y);
      }

      mySnake.insert(0, newHead);

      if (newHead == food) {
        myScore += 10;
        generateFood();
      } else {
        mySnake.removeLast();
      }

      // Collision simple
      if (mySnake.skip(1).contains(newHead) ||
          newHead.x < 0 ||
          newHead.y < 0 ||
          newHead.x >= cols ||
          newHead.y >= rows) {
        status = "💥 Collision ! Vous avez perdu.";
        isGameStarted = false;
        gameLoopTimer?.cancel();
        return;
      }

      // Envoyer la position du serpent
      final snakeMessage = "SNAKE:${mySnake.map((p) => "${p.x},${p.y}").join("|")}";
      socket.send(utf8.encode(snakeMessage), opponentAddress, 4567);
    });
  }

  void generateFood() {
    final rand = Random();
    food = Point(rand.nextInt(cols), rand.nextInt(rows));
    socket.send(utf8.encode("FOOD:${food.x},${food.y}"), opponentAddress, 4567);
  }

  void changeDirection(String newDir) {
    if ((direction == "up" && newDir == "down") ||
        (direction == "down" && newDir == "up") ||
        (direction == "left" && newDir == "right") ||
        (direction == "right" && newDir == "left")) {
      return;
    }

    direction = newDir;
  }

  @override
  void dispose() {
    gameLoopTimer?.cancel();
    socket.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Multijoueur Snake"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: isGameStarted
          ? Column(
              children: [
                const SizedBox(height: 10),
                Text("Score: $myScore",
                    style: const TextStyle(color: Colors.white)),
                Expanded(
                  child: GestureDetector(
                    onVerticalDragUpdate: (details) {
                      if (details.delta.dy < 0) changeDirection("up");
                      if (details.delta.dy > 0) changeDirection("down");
                    },
                    onHorizontalDragUpdate: (details) {
                      if (details.delta.dx < 0) changeDirection("left");
                      if (details.delta.dx > 0) changeDirection("right");
                    },
                    child: GridView.builder(
                      itemCount: rows * cols,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                      ),
                      itemBuilder: (context, index) {
                        final x = index % cols;
                        final y = index ~/ cols;
                        final cell = Point(x, y);

                        Color color = Colors.grey.shade800;
                        if (mySnake.contains(cell)) {
                          color = Colors.green;
                        } else if (opponentSnake.contains(cell)) {
                          color = Colors.red;
                        } else if (food == cell) {
                          color = Colors.amber;
                        }

                        return Container(
                          margin: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            )
          : Center(
              child: Text(
                status,
                style: const TextStyle(color: Colors.white, fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
    );
  }
}  

/* PS C:\Users\Parfait\StudioProjects\untitled> flutter build apk

Your project is configured with Android NDK 26.3.11579264, but the following plugin(s) depend on a different Android NDK version:
- audioplayers_android requires Android NDK 27.0.12077973
- flutter_native_splash requires Android NDK 27.0.12077973
- network_info_plus requires Android NDK 27.0.12077973
- path_provider_android requires Android NDK 27.0.12077973
- permission_handler_android requires Android NDK 27.0.12077973
- share_plus requires Android NDK 27.0.12077973
- sqflite_android requires Android NDK 27.0.12077973
Fix this issue by using the highest Android NDK version (they are backward compatible).
Add the following to C:\Users\Parfait\StudioProjects\untitled\android\app\build.gradle.kts:

    android {
        ndkVersion = "27.0.12077973"
        ...
    }
 */