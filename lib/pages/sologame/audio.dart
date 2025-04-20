import 'package:audioplayers/audioplayers.dart';

class GameAudio {
  final AudioPlayer _eatSound = AudioPlayer();
  final AudioPlayer _backgroundMusic = AudioPlayer();
  final AudioPlayer _gameSound = AudioPlayer(); // Player pour le son de jeu

  Future<void> playEatSound() async {
    await _eatSound.play(AssetSource('sons/eat.mp3'), volume: 1.0);
  }

  Future<void> startBackgroundMusic() async {
    await _backgroundMusic.setReleaseMode(ReleaseMode.loop);
    await _backgroundMusic.play(
      AssetSource('sons/game_music.mp3'),
      volume: 0.5,
    );
  }

  Future<void> playGameSound() async {
    // Configurer le mode de lecture en boucle avant de jouer le son
    await _gameSound.setReleaseMode(ReleaseMode.loop);
    await _gameSound.play(AssetSource('sons/tp.mp3'), volume: 0.5);
  }

  // Méthode pour mettre en pause le son du jeu
  Future<void> pauseGameSound() async {
    await _gameSound.pause();
  }

  // Méthode pour reprendre le son du jeu
  Future<void> resumeGameSound() async {
    await _gameSound.resume();
  }

  Future<void> stopGameSound() async {
    await _gameSound.stop();
  }

  Future<void> stopBackgroundMusic() async {
    await _backgroundMusic.stop();
  }

  Future<void> dispose() async {
    await _eatSound.dispose();
    await _backgroundMusic.dispose();
    await _gameSound.dispose();
  }
}