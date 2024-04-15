import 'package:shelf/shelf.dart';
import 'package:shelf_swagger_ui/shelf_swagger_ui.dart';

Handler startSwagger(Request request) {
  final path = 'specs/swagger.yaml';
  final handler = SwaggerUI(path, title: 'Swagger Test');
  return handler;
}
