import 'dart:async';
import 'dart:convert';
import 'package:dart_backend/src/core/interfaces/service/encrypt_service.dart';
import 'package:dart_backend/src/core/interfaces/service/jwt_service.dart';
import 'package:dart_backend/src/core/service/request_extractor_service.dart';
import 'package:dart_backend/src/modules/auth/middleware/guard_middleware.dart';
import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';

import '../../core/interfaces/database/remote_database.dart';

class AuthResource extends Resource {
  @override
  List<Route> get routes => [
        Route.get("/auth/login", _login),
        Route.get("/auth/refresh_token", _refreshToken),
        Route.get("/auth/check_token", _checkToken, middlewares: [
          GuardMiddleware(),
        ]),
        Route.post("/auth/update_password", _updatePassword),
      ];
}

FutureOr<Response> _login(Injector injector, Request request) async {
  final extractor = injector.get<RequestExtractorService>();
  final database = injector.get<IRemoteDatabase>();
  final encrypt = injector.get<IEncryptService>();
  final jwt = injector.get<IJwtService>();

  final credential = extractor.getAuthorizationBasic(request);
  final result = await database.query(
    'select id, password, "typeUser" from "User" where email = @email',
    variables: {"email": credential.email},
  );

  if (result.isEmpty) {
    return Response.notFound("Email or Password Wrong");
  }

  Map<String, dynamic> data = result.first.toColumnMap();

  final String password = data['password'];

  final bool logged = encrypt.verify(credential.password, password);
  if (logged) {
    final Map<String, dynamic> claims = data..remove("password");
    claims['typeUser'] = (claims['typeUser'] as UndecodedBytes).asString;
    claims['exp'] = _determineExpiration(Duration(minutes: 10));
    final accessToken = jwt.generateToken(claims, "accessToken");
    claims['exp'] = _determineExpiration(Duration(days: 7));
    final refreshToken = jwt.generateToken(claims, "refreshToken");
    return Response.ok(jsonEncode({
      "accessToken": accessToken,
      "refreshToken": refreshToken,
    }));
  } else {
    return Response.notFound("Email or Password Wrong");
  }
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

int _determineExpiration(Duration duration) {
  final expireDate = DateTime.now().add(duration);
  final expireIn =
      Duration(milliseconds: expireDate.millisecondsSinceEpoch).inSeconds;
  return expireIn;
}
