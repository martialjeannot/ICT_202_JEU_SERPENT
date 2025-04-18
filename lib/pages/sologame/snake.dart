import 'package:flame/components.dart';

class Snake {
  List<SnakeSegment> body = [];
  late Vector2 direction;
  int _vitesse = 10; // Valeur par défaut

  // Getter
  int get vitesse => _vitesse;

  // Setter
  set vitesse(int newVitesse) {
    _vitesse = newVitesse;
  }

  final Vector2 segmentSize = Vector2.all(10); // grille de 10x10
  bool isDead = false;

  Snake() {
    // Initialiser le serpent avec un segment
    body.add(SnakeSegment(position: Vector2(100, 100), size: segmentSize));

    direction = Vector2(1, 0); // droite
  }

  void move() {
    if (isDead) return;

    Vector2 newHeadPosition = body.first.position + direction * segmentSize.x;

    // Vérifier collision avec le corps
    if (_isCollidingWithSelf(newHeadPosition)) {
      isDead = true;
      print("💀 Le serpent s'est mordu !");
      return;
    }

    body.insert(0, SnakeSegment(position: newHeadPosition, size: segmentSize));
    body.removeLast();
  }

  void grow() {
    if (isDead) return;

    Vector2 lastSegmentPosition = body.last.position;
    body.add(SnakeSegment(position: lastSegmentPosition, size: segmentSize));
  }

  void changeDirection(Vector2 newDirection) {
    if (newDirection != -direction) {
      direction = newDirection;
    }
  }

  bool _isCollidingWithSelf(Vector2 newHeadPos) {
    for (int i = 0; i < body.length; i++) {
      if (body[i].position == newHeadPos) {
        return true;
      }
    }
    return false;
  }
}

class SnakeSegment {
  Vector2 position;
  Vector2 size;

  SnakeSegment({required this.position, required this.size});
}
