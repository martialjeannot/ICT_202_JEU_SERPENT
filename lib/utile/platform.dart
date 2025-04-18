import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

final bool isWeb = kIsWeb;
final bool isAndroid = !kIsWeb && Platform.isAndroid;
final bool isIOS = !kIsWeb && Platform.isIOS;
final bool isWindows = !kIsWeb && Platform.isWindows;
final bool isLinux = !kIsWeb && Platform.isLinux;
final bool isMacOS = !kIsWeb && Platform.isMacOS;
