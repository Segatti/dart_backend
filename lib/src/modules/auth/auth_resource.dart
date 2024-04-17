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
        Route.get(
          "/auth/refresh_token",
          _refreshToken,
          middlewares: [GuardMiddleware(isRefreshToken: true)],
        ),
        Route.get(
          "/auth/check_token",
          _checkToken,
          middlewares: [GuardMiddleware()],
        ),
        Route.put(
          "/auth/update_password",
          _updatePassword,
          middlewares: [GuardMiddleware()],
        ),
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

  try {
    final bool logged = encrypt.verify(credential.password, password);
    if (logged) {
      final Map<String, dynamic> claims = data..remove("password");

      return Response.ok(jsonEncode(generateTokens(claims, jwt)));
    } else {
      return Response.notFound("Email or Password Wrong");
    }
  } catch (e) {
    return Response.notFound("Email or Password Wrong");
  }
}

Map generateTokens(Map claims, IJwtService jwt) {
  claims['typeUser'] = (claims['typeUser'] as UndecodedBytes).asString;
  claims['exp'] = _determineExpiration(Duration(minutes: 10));
  final accessToken = jwt.generateToken(claims, "accessToken");
  claims['exp'] = _determineExpiration(Duration(days: 7));
  final refreshToken = jwt.generateToken(claims, "refreshToken");
  return {
    "accessToken": accessToken,
    "refreshToken": refreshToken,
  };
}

FutureOr<Response> _refreshToken(Injector injector, Request request) async {
  final extractor = injector.get<RequestExtractorService>();
  final database = injector.get<IRemoteDatabase>();
  final jwt = injector.get<IJwtService>();

  final token = extractor.getAuthorizationBearer(request);
  var payload = jwt.getPayload(token);

  final result = await database.query(
    'select id, "typeUser" from "User" where id = @id',
    variables: {"id": payload['id']},
  );

  if (result.affectedRows > 0) {
    payload = result.first.toColumnMap();
    return Response.ok(jsonEncode(generateTokens(payload, jwt)));
  } else {
    return Response.notFound("User not found");
  }
}

FutureOr<Response> _checkToken(Injector injector) async {
  return Response.ok("Token valid");
}

FutureOr<Response> _updatePassword(
    Injector injector, Request request, ModularArguments arguments) async {
  final extractor = injector.get<RequestExtractorService>();
  final database = injector.get<IRemoteDatabase>();
  final encrypt = injector.get<IEncryptService>();
  final jwt = injector.get<IJwtService>();
  if (arguments.data == null) return Response.badRequest();
  final Map data = arguments.data as Map<String, dynamic>;

  final token = extractor.getAuthorizationBearer(request);
  final payload = jwt.getPayload(token);
  final result = await database.query(
    'select password from "User" where id=@id',
    variables: {"id": payload['id']},
  );
  if (result.affectedRows < 0) return Response.notFound("User not found");
  final passwordEncrypt = result.first.toColumnMap()['password'];
  if (encrypt.verify(data['password'], passwordEncrypt)) {
    final result = await database.query(
      'update "User" set password=@password where id = @id',
      variables: {
        "password": encrypt.encrypt(data['newPassword']),
        "id": payload['id'],
      },
    );
    if (result.affectedRows > 0) {
      return Response.ok("Password changed");
    } else {
      return Response.notFound("User not found");
    }
  } else {
    return Response.badRequest(body: "Password wrong");
  }
}

int _determineExpiration(Duration duration) {
  final expireDate = DateTime.now().add(duration);
  final expireIn =
      Duration(milliseconds: expireDate.millisecondsSinceEpoch).inSeconds;
  return expireIn;
}
