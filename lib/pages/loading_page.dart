import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:snake_game/pages/home_page.dart';

class MyLoadingPage extends StatefulWidget {
  const MyLoadingPage({super.key, required this.title});

  final String title;

  @override
  State<MyLoadingPage> createState() => _MyLoadingPageState();
}

class _MyLoadingPageState extends State<MyLoadingPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    playSound();
    loadAnimation();
  }

  void playSound() async {
    await _audioPlayer.stop(); // Arrêter toute musique avant de commencer
    await _audioPlayer.play(
      AssetSource('sons/son_animation.mp3'),
    ); // Jouer le son d'animation
    print("🎵 Son d’animation lancé !");
  }

  Future<Timer> loadAnimation() async {
    return Timer(const Duration(seconds: 7), onloaded);
  }

  void onloaded() {
    _audioPlayer.stop(); // Arrêter le son à la fin
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => HomePageChoix()
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Lottie.asset("assets/lotties/snake_lottie.json", repeat: false),
      ),
    );
  }
}
