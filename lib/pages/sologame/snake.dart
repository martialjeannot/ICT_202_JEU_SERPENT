import 'package:flame/components.dart';

class SnakeSegment {
  Vector2 position;
  Vector2 size;

  SnakeSegment({required this.position, required this.size});
}

class Snake {
  List<SnakeSegment> body = [];
  Vector2 direction = Vector2(1, 0); // Direction initiale: vers la droite
  int vitesse = 150; // Vitesse du serpent (ms)
  double cellSize = 16.0; // Taille d'une cellule de la grille
  // Position de la dernière queue pour la croissance
  Vector2? lastTailPosition;

  Snake() {
    // Initialisation du serpent avec 3 segments
    body = [
      SnakeSegment(position: Vector2(0, 0), size: Vector2(cellSize, cellSize)),
      SnakeSegment(position: Vector2(-cellSize, 0), size: Vector2(cellSize, cellSize)),
      SnakeSegment(position: Vector2(-cellSize * 2, 0), size: Vector2(cellSize, cellSize)),
    ];
  }

  void initializeOnGrid(List<Vector2> gridPositions) {
    if (gridPositions.isEmpty) return;
    
    // Trouver une position de départ vers le centre de la grille
    Vector2 centerPos = Vector2(0, 0);
    
    // Calculer le centre approximatif de la grille
    for (var pos in gridPositions) {
      centerPos += pos;
    }
    centerPos /= gridPositions.length.toDouble();
    
    // Trouver une position de départ proche du centre
    Vector2 startPos = findClosestGridPosition(centerPos, gridPositions);
    
    // Vider le corps du serpent
    body.clear();
    
    // Ajouter la tête à la position de départ
    body.add(SnakeSegment(position: startPos.clone(), size: Vector2(cellSize, cellSize)));
    
    // Trouver des positions valides pour les autres segments
    // Essayer d'abord vers la gauche
    Vector2 direction = Vector2(-1, 0);
    
    for (int i = 1; i < 3; i++) {
      Vector2? nextPos;
      // Essayer différentes directions pour placer les segments
      List<Vector2> directions = [
        Vector2(-1, 0), Vector2(0, -1), Vector2(0, 1), Vector2(1, 0)
      ];
      
      for (var dir in directions) {
        // Position théorique du prochain segment
        Vector2 theoreticalPos = body.last.position + dir * cellSize;
        
        // Trouver la position de grille la plus proche
        nextPos = findClosestValidGridPosition(theoreticalPos, gridPositions, body);
        
        if (nextPos != null) {
          body.add(SnakeSegment(position: nextPos.clone(), size: Vector2(cellSize, cellSize)));
          break;
        }
      }
      
      // Si on n'a pas pu ajouter le segment, dupliquer la position du dernier
      if (nextPos == null && body.isNotEmpty) {
        body.add(SnakeSegment(
          position: body.last.position.clone(),
          size: Vector2(cellSize, cellSize)
        ));
      }
    }
    
    // Réinitialiser la direction pour aller vers la droite
    direction = Vector2(1, 0);
  }

  Vector2 findClosestGridPosition(Vector2 target, List<Vector2> gridPositions) {
    Vector2 closest = gridPositions[0];
    double minDistance = (closest - target).length;
    
    for (var pos in gridPositions) {
      double distance = (pos - target).length;
      if (distance < minDistance) {
        minDistance = distance;
        closest = pos;
      }
    }
    
    return closest;
  }

  Vector2? findClosestValidGridPosition(Vector2 target, List<Vector2> gridPositions, List<SnakeSegment> occupiedPositions) {
    Vector2? closest;
    double minDistance = double.infinity;
    
    // Vérifier toutes les positions de la grille
    for (var pos in gridPositions) {
      // Vérifier que cette position n'est pas déjà occupée
      bool isOccupied = false;
      for (var segment in occupiedPositions) {
        if ((segment.position - pos).length < cellSize * 0.5) {
          isOccupied = true;
          break;
        }
      }
      
      if (!isOccupied) {
        double distance = (pos - target).length;
        if (distance < minDistance) {
          minDistance = distance;
          closest = pos;
        }
      }
    }
    
    return closest;
  }

  void moveOnGrid(List<Vector2> gridPositions, double spacing) {
    if (body.isEmpty || gridPositions.isEmpty) return;
    
    // Sauvegarder la dernière position de la queue
    lastTailPosition = body.last.position.clone();
    
    // Déplacer chaque segment à la position du segment précédent
    for (int i = body.length - 1; i > 0; i--) {
      body[i].position.x = body[i - 1].position.x;
      body[i].position.y = body[i - 1].position.y;
    }
    
    // Calculer la nouvelle position théorique de la tête
    Vector2 newHeadPos = body.first.position + direction * spacing;
    
    // Trouver la position de grille la plus proche dans la direction du mouvement
    Vector2? validGridPos = findClosestGridPositionInDirection(body.first.position, newHeadPos, gridPositions);
    
    if (validGridPos != null) {
      // Mettre à jour la position de la tête
      body.first.position.x = validGridPos.x;
      body.first.position.y = validGridPos.y;
    }
  }

  Vector2? findClosestGridPositionInDirection(Vector2 currentPos, Vector2 targetPos, List<Vector2> gridPositions) {
    Vector2 moveDirection = targetPos - currentPos;
    moveDirection.normalize();
    
    Vector2? closest;
    double minDistance = double.infinity;
    
    for (var pos in gridPositions) {
      Vector2 dirToPos = pos - currentPos;
      
      // Calculer le produit scalaire pour voir si la position est dans la direction du mouvement
      double dotProduct = dirToPos.x * moveDirection.x + dirToPos.y * moveDirection.y;
      
      // Si le produit scalaire est positif, la position est dans la bonne direction
      if (dotProduct > 0) {
        double distance = (pos - targetPos).length;
        
        if (distance < minDistance) {
          minDistance = distance;
          closest = pos;
        }
      }
    }
    
    // Si aucune position n'est trouvée dans la direction, prendre simplement la plus proche
    if (closest == null) {
      closest = findClosestGridPosition(targetPos, gridPositions);
    }
    
    return closest;
  }

  void changeDirection(Vector2 newDirection) {
    // Empêcher le serpent de faire demi-tour sur lui-même
    if (direction.x + newDirection.x != 0 || direction.y + newDirection.y != 0) {
      direction = newDirection;
    }
  }

  void grow() {
    // Utiliser la dernière position de la queue sauvegardée pour ajouter un nouveau segment
    if (lastTailPosition != null) {
      body.add(SnakeSegment(
        position: lastTailPosition!.clone(),
        size: Vector2(cellSize, cellSize)
      ));
    } else if (body.isNotEmpty) {
      // Fallback: dupliquer la position du dernier segment
      Vector2 tailPos = body.last.position.clone();
      body.add(SnakeSegment(position: tailPos, size: Vector2(cellSize, cellSize)));
    }
  }
}