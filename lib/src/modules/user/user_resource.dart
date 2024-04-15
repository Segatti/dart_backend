import 'dart:async';

import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';

class UserResource extends Resource {
  @override
  List<Route> get routes => [
        Route.get("/user", _getAllUsers),
        Route.get("/user/:id", _getUser),
        Route.post("/user", _createUser),
        Route.put("/user", _updateUser),
        Route.delete("/user/:id", _deleteUser),
      ];
}

FutureOr<Response> _getAllUsers() {
  return Response.ok("All users");
}

FutureOr<Response> _getUser(ModularArguments args) {
  return Response.ok("User id: ${args.params['id']}");
}

FutureOr<Response> _createUser(ModularArguments args) {
  return Response.ok("User: ${args.data}");
}

FutureOr<Response> _updateUser(ModularArguments args) {
  return Response.ok("User: ${args.data}");
}

FutureOr<Response> _deleteUser(ModularArguments args) {
  return Response.ok("User deletado: ${args.params['id']}");
}
