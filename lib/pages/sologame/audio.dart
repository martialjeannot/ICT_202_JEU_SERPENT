import 'package:audioplayers/audioplayers.dart';

class GameAudio {
  final AudioPlayer _eatSound = AudioPlayer();
  final AudioPlayer _backgroundMusic = AudioPlayer();

  Future<void> playEatSound() async {
    await _eatSound.play(AssetSource('sons/eat.mp3'), volume: 1.0);
  }

  Future<void> startBackgroundMusic() async {
    await _backgroundMusic.setReleaseMode(ReleaseMode.loop);
    await _backgroundMusic.play(AssetSource('sons/game_music.mp3'), volume: 0.5);
  }

  Future<void> stopBackgroundMusic() async {
    await _backgroundMusic.stop();
  }

  Future<void> dispose() async {
    await _eatSound.dispose();
    await _backgroundMusic.dispose();
  }
}
