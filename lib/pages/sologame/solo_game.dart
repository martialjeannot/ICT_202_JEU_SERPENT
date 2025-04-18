import 'package:flutter/material.dart';
import 'package:snake_game/pages/sologame/game.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:share_plus/share_plus.dart'; 

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedDifficulty = 'Facile';
  final AudioPlayer _audioPlayer = AudioPlayer();

  final List<String> _difficulties = ['Facile', 'Moyen', 'Difficile'];

  @override
  void initState() {
    super.initState();
    _playBackgroundMusic();
  }

  void _playBackgroundMusic() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(AssetSource('sons/son_d_accueil.mp3'));
  }

  void _startGame() {
    String playerName = _nameController.text.trim();
    if (playerName.isEmpty) {
      _showMessage("Veuillez entrer votre nom");
    } else {
      _audioPlayer.stop();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MySnakeGame(
            userName: playerName,
            level: _selectedDifficulty,
          ),
        ),
      );
    }
  }

  void _showMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Attention"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Snake Game 🐍"),
        backgroundColor: Colors.deepPurple.withOpacity(0.8),
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Text(
                'Menu Principal',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Accueil'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.videogame_asset),
              title: const Text('Jouer'),
              onTap: () {
                Navigator.pop(context);
                _startGame();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Paramètres'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Paramètres"),
                    content:
                        const Text("Les paramètres seront bientôt disponibles."),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("OK"),
                      ),
                    ],
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('À propos'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("À propos du jeu"),
                    content: const Text(
                        "🐍 Bienvenue dans Flutter Snake game !\n\nUn jeu classique de serpent avec des niveaux de difficulté différents.\nAmusez-vous à éviter les murs et à manger des fruits pour grandir."),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Fermer"),
                      ),
                    ],
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Partager'),
              onTap: () async {
                Navigator.pop(context);
                await Share.share(
                  '🔥 Viens jouer à Flutter Snake avec moi ! Télécharge l’app ici : https://',
                  subject: 'Jeu Flutter Snake 🐍',
                );
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/image_fond.png',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            color: Colors.black.withOpacity(0.6),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Bienvenue dans le jeu Snake 🐍",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Entrez votre nom',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      dropdownColor: Colors.deepPurple.shade700,
                      value: _selectedDifficulty,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.deepPurple.withOpacity(0.3),
                        labelText: 'Niveau de difficulté',
                        labelStyle: const TextStyle(color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.amber, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      iconEnabledColor: Colors.white,
                      items: _difficulties.map((diff) {
                        Color itemColor;
                        switch (diff) {
                          case 'Facile':
                            itemColor = Colors.greenAccent;
                            break;
                          case 'Moyen':
                            itemColor = Colors.orangeAccent;
                            break;
                          case 'Difficile':
                            itemColor = Colors.redAccent;
                            break;
                          default:
                            itemColor = Colors.white;
                        }
                        return DropdownMenuItem(
                          value: diff,
                          child: Text(
                            diff,
                            style: TextStyle(
                              color: itemColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedDifficulty = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 30),
                    GestureDetector(
                      onTap: _startGame,
                      child: Image.asset(
                        'assets/images/play_button.png',
                        width: 150,
                        height: 150,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
