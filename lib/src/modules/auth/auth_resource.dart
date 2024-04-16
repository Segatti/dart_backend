import 'dart:async';
import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';

class AuthResource extends Resource {
  @override
  List<Route> get routes => [
        Route.get("/auth/login", _login),
        Route.get("/auth/refresh_token", _refreshToken),
        Route.get("/auth/check_token", _checkToken),
        Route.post("/auth/update_password", _updatePassword),
      ];
}

FutureOr<Response> _login(Injector injector) async {
  return Response.ok("");
}

FutureOr<Response> _refreshToken(Injector injector) async {
  return Response.ok("");
}

FutureOr<Response> _checkToken(Injector injector) async {
  return Response.ok("");
}

FutureOr<Response> _updatePassword(Injector injector) async {
  return Response.ok("");
}
