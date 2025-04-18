// lib/pages/network_game/client_connected_page.dart
import 'package:flutter/material.dart';

class ClientConnectedPage extends StatelessWidget {
  const ClientConnectedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade900,
      appBar: AppBar(
        title: const Text("Connecté 🎉"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 100),
            const SizedBox(height: 20),
            const Text(
              "Connexion au serveur réussie !",
              style: TextStyle(fontSize: 20, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // TODO: Aller à la page multijoueur
                Navigator.pushNamed(context, "/multiplayer_game");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text("Rejoindre la partie"),
            )
          ],
        ),
      ),
    );
  }
}
