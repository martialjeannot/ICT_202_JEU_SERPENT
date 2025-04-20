import 'package:flame/components.dart';

class Bomb extends PositionComponent {
  Bomb(Vector2 position) {
    this.position = position;
    this.size = Vector2(16.0, 16.0); // Taille de la bombe
  }
}
