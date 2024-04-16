import 'dart:io';

import 'package:dart_backend/src/core/interfaces/service/env_service.dart';

class EnvService implements IEnvService {
  final Map<String, String> map = {};
  
  static EnvService instance = EnvService._();
  EnvService._() {
    _init();
  }

  _init() {
    final file = File(".env");
    final fileText = file.readAsStringSync();

    for (var line in fileText.split("\n")) {
      final lineBreak = line.split("=");
      map[lineBreak[0]] = lineBreak[1];
    }
  }

  @override
  String? operator [](String key) {
    return map[key];
  }
}
