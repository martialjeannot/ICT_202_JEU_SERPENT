// lib/pages/network_game/join_game_page.dart
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';

class JoinGamePage extends StatefulWidget {
  const JoinGamePage({super.key});

  @override
  State<JoinGamePage> createState() => _JoinGamePageState();
}

class _JoinGamePageState extends State<JoinGamePage> {
  final TextEditingController _ipController = TextEditingController();
  String status = "";

  void connectToServer(String ip) async {
    setState(() {
      status = "Connexion au serveur $ip ...";
    });

    try {
      // Envoie un message au serveur via UDP
      final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      socket.send(utf8.encode("JOIN_REQUEST"), InternetAddress(ip), 4567); // port par défaut du serveur

      socket.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          final datagram = socket.receive();
          if (datagram != null) {
            final message = utf8.decode(datagram.data);
            if (message == "JOIN_ACCEPTED") {
              setState(() {
                status = "Connecté au serveur !";
              });
              socket.close();
              Navigator.pushNamed(context, "/client_connected");
            } else {
              setState(() {
                status = "Réponse inattendue du serveur.";
              });
              socket.close();
            }
          }
        }
      });
    } catch (e) {
      setState(() {
        status = "Erreur lors de la connexion : $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade900,
      appBar: AppBar(
        title: const Text("Rejoindre une partie"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Entrer l'adresse IP de l'hôte :",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _ipController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.deepPurple.shade700,
                hintText: "Exemple : 192.168.1.100",
                hintStyle: const TextStyle(color: Colors.white54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                final ip = _ipController.text.trim();
                if (ip.isNotEmpty) {
                  connectToServer(ip);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text("Se connecter"),
            ),
            const SizedBox(height: 30),
            Text(
              status,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
