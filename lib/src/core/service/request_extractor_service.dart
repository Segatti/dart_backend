// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:shelf/shelf.dart';

class RequestExtractorService {
  String getAuthorizationBearer(Request request) {
    var authorization = request.headers['authorization'] ?? '';
    authorization = authorization.split(" ").last;
    return authorization;
  }

  LoginCredential getAuthorizationBasic(Request request) {
    var authorization = request.headers['authorization'] ?? '';
    authorization = authorization.split(" ").last;
    authorization = String.fromCharCodes(base64Decode(authorization));
    final credential = authorization.split(":");
    var loginCredential = LoginCredential(
      email: credential.first,
      password: credential.last,
    );
    return loginCredential;
  }
}

class LoginCredential {
  final String email;
  final String password;

  const LoginCredential({
    required this.email,
    required this.password,
  });
}
