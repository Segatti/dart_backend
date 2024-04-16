import 'dart:io';

class EnvService {
  static EnvService instance = EnvService._();
  final Map<String, String> map = {};
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

  String? operator [](String key) {
    return map[key];
  }
}
