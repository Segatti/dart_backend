import 'package:dart_backend/src/core/interfaces/service/env_service.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import '../interfaces/service/jwt_service.dart';

class JwtService implements IJwtService {
  final IEnvService envService;

  const JwtService(this.envService);

  @override
  String generateToken(Map claims, String audiance) {
    final jwt = JWT(
      claims,
      audience: Audience.one(audiance),
    );

    return jwt.sign(SecretKey(envService['JWT_SECRET']!));
  }

  @override
  Map getPayload(String token) {
    final jwt = JWT.verify(
      token,
      SecretKey(envService['JWT_SECRET']!),
      checkExpiresIn: false,
      checkHeaderType: false,
      checkNotBefore: false,
    );

    return jwt.payload;
  }

  @override
  void verifyToken(String token, String audiance) {
    JWT.verify(
      token,
      SecretKey(envService['JWT_SECRET']!),
      audience: Audience.one(audiance),
    );
  }
}
