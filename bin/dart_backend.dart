import 'package:dart_backend/dart_backend.dart';
import 'package:shelf/shelf_io.dart' as io;

void main() async {
  final handler = await startShelfModular();
  final server = await io.serve(handler, "0.0.0.0", 8080);
  print("Servidor iniciado: http://${server.address.address}:${server.port}");
}
