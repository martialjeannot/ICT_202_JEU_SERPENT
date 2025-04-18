import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:udp/udp.dart';
import 'package:snake_game/utile/platform.dart';

class StartServerPage extends StatefulWidget {
  const StartServerPage({super.key});

  @override
  State<StartServerPage> createState() => _StartServerPageState();
}

class _StartServerPageState extends State<StartServerPage> {
  String status = "Initialisation du serveur...";
  String? serverIP;
  String? localIP;
  UDP? receiver;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    if (!isWeb && (isAndroid || isIOS)) {
      var locationStatus = await Permission.location.request();
      if (!locationStatus.isGranted) {
        setState(() {
          status = "Permission de localisation refusée.";
        });
        return;
      }
    }

    _startHosting();
  }

  Future<void> _startHosting() async {
    try {
      // Obtenir l'IP locale pour tout type de plateforme
      await _getLocalIP();
      
      // Si on est sur le web, obtenir aussi l'IP publique mais garder l'IP locale comme prioritaire
      if (isWeb) {
        await _getPublicIP();
      }

      await _startUDPServer();

      setState(() {
        status += "\n✅ Serveur UDP actif";
      });
    } catch (e) {
      setState(() => status = "Erreur lors du démarrage : $e");
    }
  }

  Future<void> _getLocalIP() async {
    final info = NetworkInfo();
    String? ip;

    try {
      if (isWeb) {
        // Pour le web, on utilise une approche différente
        // Adresse par défaut pour les connexions locales Web
        ip = "127.0.0.1";
        localIP = ip;
        serverIP = ip; // Utilisez l'IP locale comme serverIP par défaut
        
        setState(() {
          status = "✅ Serveur Web démarré à l'adresse locale : $serverIP";
        });
        return;
      }
      
      // Pour les plateformes natives
      ip = await info.getWifiIP();
      print("getWifiIP() retourne : $ip");

      if (ip == null || ip.isEmpty || ip.startsWith("154.")) {
        print("💡 IP non valide, on essaie avec NetworkInterface...");

        final interfaces = await NetworkInterface.list(
          includeLinkLocal: false,
          type: InternetAddressType.IPv4,
        );

        print("Interfaces réseau disponibles : $interfaces");

        for (var interface in interfaces) {
          for (var addr in interface.addresses) {
            print("Adresse trouvée : ${addr.address}");
            if (!addr.isLoopback &&
                (addr.address.startsWith("192.") ||
                 addr.address.startsWith("10.") ||
                 addr.address.startsWith("172."))) {
              ip = addr.address;
              break;
            }
          }
        }
      }

      if (ip == null || ip.isEmpty) {
        setState(() {
          status = "❌ Impossible de récupérer l'adresse IP locale.\n"
              "💡 Vérifie ta connexion Wi-Fi ou essaie en mode admin.";
        });
        return;
      }

      localIP = ip;
      serverIP = ip;

      // Détection plateforme
      String platformText = "Appareil inconnu";
      if (isWindows) platformText = "Windows";
      if (isAndroid) platformText = "Android";
      if (isIOS) platformText = "iOS";
      if (isLinux) platformText = "Linux";
      if (isMacOS) platformText = "macOS";

      setState(() {
        status = "✅ Serveur $platformText démarré à l'adresse locale : $serverIP";
      });
    } catch (e) {
      setState(() {
        status = "❌ Erreur lors de la récupération de l'adresse IP locale : $e";
      });
    }
  }

  Future<void> _getPublicIP() async {
    try {
      final response = await http.get(Uri.parse('https://api64.ipify.org?format=json'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String publicIP = data['ip'];
        
        // Stocker l'IP publique mais ne pas remplacer serverIP qui doit rester l'IP locale
        setState(() {
          status += "\n🌐 Adresse IP publique disponible : $publicIP";
        });
      } else {
        setState(() {
          status += "\nErreur récupération IP publique : ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        status += "\nErreur de connexion API publique : $e";
      });
    }
  }

  Future<void> _startUDPServer() async {
    try {
      if (serverIP == null) {
        setState(() {
          status = "❌ Impossible de démarrer le serveur UDP sans IP locale.";
        });
        return;
      }

      // Si web, utiliser une approche différente ou avertir l'utilisateur
      if (isWeb) {
        setState(() {
          status += "\n⚠️ Le serveur UDP n'est pas compatible avec le web. Utilisez plutôt la version native.";
        });
        return;
      }

      final localAddress = InternetAddress(
        serverIP!,
        type: InternetAddressType.IPv4,
      );

      receiver = await UDP.bind(
        Endpoint.unicast(localAddress, port: Port(8080)),
      );

      receiver!.asStream().listen((datagram) {
        final data = String.fromCharCodes(datagram!.data);
        setState(() {
          status = "📩 Message reçu : $data";
        });
      });
    } catch (e) {
      setState(() {
        status = "Erreur UDP : $e";
      });
    }
  }

  void _copyToClipboard() {
    final ip = serverIP;
    if (ip != null) {
      Clipboard.setData(ClipboardData(text: ip));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Adresse IP copiée dans le presse-papiers ✅"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    receiver?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Héberger une partie"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.deepPurple.shade900,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_tethering, size: 100, color: Colors.white),
              const SizedBox(height: 20),
              const Text(
                "Votre jeu est en cours d'hébergement...",
                style: TextStyle(color: Colors.white, fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Text(
                status,
                style: const TextStyle(color: Colors.amber, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              if (serverIP == null) ...[
                const SizedBox(height: 20),
                const CircularProgressIndicator(color: Colors.white),
              ],
              const SizedBox(height: 30),
              if (serverIP != null)
                ElevatedButton.icon(
                  onPressed: _copyToClipboard,
                  icon: const Icon(Icons.copy),
                  label: const Text("Copier l'adresse IP"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    foregroundColor: Colors.black,
                  ),
                ),
              if (isWeb) ...[
                const SizedBox(height: 20),
                const Text(
                  "⚠️ Pour une utilisation optimale, exécutez l'application sur un appareil mobile ou de bureau.",
                  style: TextStyle(color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}