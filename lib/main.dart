import 'package:flutter/material.dart';
import 'package:snake_game/pages/loading_page.dart';
import 'package:snake_game/pages/home_page.dart';
import 'package:snake_game/pages/network_game/start_server_page.dart';
import 'package:snake_game/pages/network_game/network_home_page.dart'; // à créer
import 'package:snake_game/pages/network_game/client_connected_page.dart';
import 'package:snake_game/pages/network_game/join_game_page.dart';
import 'package:snake_game/pages/network_game/multiplayer_game_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Snake Game',
      theme: ThemeData(
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // Page d’accueil
      home: const MyLoadingPage(title: 'loading ..'),

      // 🔗 ROUTES NOMMÉES
      routes: {
        '/loading': (context) => const MyLoadingPage(title: 'loading ..'), 
        '/homeChoix': (context) => const HomePageChoix(),
        '/join_game': (context) => const JoinGamePage(),
        "/multiplayer_game": (context) => const MultiplayerGamePage(isHost: false),

        '/client_connected': (context) => const ClientConnectedPage(),
        '/soloGame': (context) => const HomePageChoix(), // solo_player
        '/networkHome': (context) => const NetworkHomePage(), // à créer
        '/startServer': (context) => const StartServerPage(), // héberger
        // '/joinGame': (context) => const JoinGamePage(), // à venir
      },
    );
  }
}
