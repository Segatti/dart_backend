import 'package:postgres/postgres.dart';

abstract class IRemoteDatabase {
  Future<Result> query(
    String queryText, {
    Map<String, dynamic> variables = const {},
  });
}
