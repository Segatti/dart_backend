import 'dart:convert';

import 'package:dart_backend/src/core/interfaces/service/jwt_service.dart';
import 'package:dart_backend/src/core/service/request_extractor_service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';

class GuardMiddleware extends ModularMiddleware {
  final List<String> roles;
  final bool isRefreshToken;

  const GuardMiddleware({this.roles = const [], this.isRefreshToken = false});

  @override
  Handler call(Handler handler, [ModularRoute? route]) {
    final extractor = Modular.get<RequestExtractorService>();
    final jwt = Modular.get<IJwtService>();

    return (Request request) {
      if (!request.headers.containsKey("authorization")) {
        return Response.forbidden(jsonEncode(
          {"error": "not authorization header"},
        ));
      }

      final token = extractor.getAuthorizationBearer(request);
      try {
        jwt.verifyToken(token, isRefreshToken ? "refreshToken" : "accessToken");
        final payload = jwt.getPayload(token);
        final role = payload['typeUser'];
        if (roles.isEmpty || roles.contains(role)) {
          return handler(request);
        } else {
          return Response.forbidden(jsonEncode(
            {"error": "userType not authorizated"},
          ));
        }
      } catch (e) {
        return Response.forbidden(jsonEncode(
          {"error": e.toString()},
        ));
      }
    };
  }
}
