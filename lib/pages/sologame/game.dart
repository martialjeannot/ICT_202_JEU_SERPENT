import 'package:flutter/material.dart';
import 'grille_facile.dart'; // Import du fichier contenant le niveau facile
import 'grille_moyenne.dart'; // Vous pouvez créer un fichier pour niveau moyen
import 'grille_difficile.dart'; // Vous pouvez créer un fichier pour niveau difficile

class MySnakeGame extends StatelessWidget {
  final String userName;
  final String level;

  // Constructeur pour récupérer le nom du joueur et le niveau
  const MySnakeGame({super.key, required this.userName, required this.level});

  @override
  Widget build(BuildContext context) {
    // Affichage de la page du jeu avec les paramètres du nom et du niveau
    return Scaffold(
      appBar: AppBar(
        title: Text("Snake Game - $userName"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Affichage du niveau sélectionné
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'Niveau: $level',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: _getGameWidget(level, userName), // Récupère le widget en fonction du niveau
          ),
        ],
      ),
    );
  }

  // Fonction qui retourne le widget du jeu en fonction du niveau
  Widget _getGameWidget(String level, String userName) {
    if (level == 'Facile') {
      return GrilleFacile(nomDuJoueur: userName);
    }
    //  les niveaux moyen et difficile
    else if (level == 'Moyen') {
      return GrilleMoyenne(nomDuJoueur: userName); 
    } else if (level == 'Difficile') {
      return GrilleDifficile(nomDuJoueur: userName); 
    } else {
      return Center(
        child: Text(
          'Niveau inconnu',
          style: TextStyle(fontSize: 24, color: Colors.red),
        ),
      );
    }
  }
}
