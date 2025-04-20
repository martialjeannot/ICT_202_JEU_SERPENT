import 'package:flame/components.dart';
import 'dart:math' as math;

class Eat {
  Vector2 position;
  Vector2 size;

  Eat(this.position) : size = Vector2(10, 10);

  void relocate(Vector2 gameSize, List<dynamic> snakeBody) {
    // Cette méthode est conservée pour compatibilité, mais nous utiliserons
    // la méthode _placeFoodOnGrid dans la classe GrilleFacile à la place
    final random = math.Random();
    
    double x = random.nextDouble() * (gameSize.x - size.x);
    double y = random.nextDouble() * (gameSize.y - size.y);
    
    // Arrondir aux multiples de 20 (taille de la cellule)
    x = (x / 20).round() * 20;
    y = (y / 20).round() * 20;
    
    position = Vector2(x, y);
  }
  // Relocaliser la nourriture dans le cercle en évitant le serpent
  void relocateInCircle(double centerX, double centerY, double radius, List<dynamic> snakeBody) {
    final rand = math.Random();
    final safeRadius = radius - size.x;
    bool validPosition = false;
    
    // Essayer de trouver une position valide (pas sur le serpent)
    int maxAttempts = 50;
    int attempts = 0;
    
    while (!validPosition && attempts < maxAttempts) {
      // Génération d'un point aléatoire dans le cercle
      // r = √(random) * radius pour une distribution uniforme
      double r = math.sqrt(rand.nextDouble()) * safeRadius;
      double angle = rand.nextDouble() * 2 * math.pi;
      
      double x = centerX + r * math.cos(angle) - size.x / 2;
      double y = centerY + r * math.sin(angle) - size.y / 2;
      
      position = Vector2(x, y);
      
      // Vérifier si la position est valide (pas sur le serpent)
      validPosition = true;
      for (var segment in snakeBody) {
        if ((position - segment.position).length < size.x) {
          validPosition = false;
          break;
        }
      }
      
      attempts++;
    }
    
    // Si après 50 tentatives, aucune position valide n'est trouvée,
    // on utilise la dernière position calculée
  }
}