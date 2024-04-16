abstract class IEncryptService {
  String encrypt(String value);
  bool verify(String value, String hash);
}
