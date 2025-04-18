import 'package:flutter/material.dart';

class NetworkHomePage extends StatelessWidget {
  const NetworkHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade900,
      appBar: AppBar(
        title: const Text("Multiplayer Mode - Snake Game 🐍"),
        centerTitle: true,
        backgroundColor: Colors.indigo.shade700,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Bouton Serveur
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/startServer');
              },
              icon: const Icon(Icons.wifi_tethering),
              label: const Text("Héberger une partie (Serveur)"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                backgroundColor: Colors.green,
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 30),
            // Bouton Client
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/joinGame');
              },
              icon: const Icon(Icons.connect_without_contact),
              label: const Text("Rejoindre une partie (Client)"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                backgroundColor: Colors.orange,
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
