import 'package:flutter/material.dart';
import 'package:snake_game/pages/sologame/solo_game.dart'; 
import 'package:snake_game/pages/network_game/network_home_page.dart';

class HomePageChoix extends StatefulWidget {
  const HomePageChoix({super.key});

  @override
  State<HomePageChoix> createState() => _HomePageStateChoix();
}

class _HomePageStateChoix extends State<HomePageChoix> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("Snake Game 🐍"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple.withOpacity(0.7),
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3E1E68), Color(0xFF9C27B0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // SOLO PLAYER
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/images/players1.png", height: 150),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomePage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 44, 12, 99),
                    ),
                    child: const Text("Solo Player"),
                  ),
                ],
              ),

              // RÉSEAU PLAYERS
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/images/players1.png", height: 150),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NetworkHomePage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 48, 3, 56),
                    ),
                    child: const Text("Réseau Players"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
