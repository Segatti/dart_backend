import 'package:bcrypt/bcrypt.dart';

import '../interfaces/service/encrypt_service.dart';

class EncryptService implements IEncryptService {
  @override
  String encrypt(String value) {
    final String hashed = BCrypt.hashpw(value , BCrypt.gensalt());
    return hashed;
  }

  @override
  bool verify(String value, String hash) {
    final bool check = BCrypt.checkpw('password', hash);
    return check;
  }
}
