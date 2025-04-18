import 'package:flame/components.dart';
import 'dart:math';
import 'snake.dart'; // Importer pour accéder à SnakeSegment

class Eat {
  Vector2 position;
  Vector2 size;

  Eat(this.position) : size = Vector2(10, 10); // Taille de la nourriture

void relocate(Vector2 gameSize, List<SnakeSegment> snakeBody) {
  final rand = Random();
  int maxX = (gameSize.x ~/ 20); // Nombre de cases horizontales
  int maxY = (gameSize.y ~/ 20);

  Vector2 newPosition;
  do {
    newPosition = Vector2(
      rand.nextInt(maxX) * 20.0,
      rand.nextInt(maxY) * 20.0,
    );
  } while (snakeBody.any((seg) => seg.position == newPosition));

  position = newPosition;
}

}