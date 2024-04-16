import 'dart:async';

import 'package:shelf_modular/shelf_modular.dart';
import 'package:postgres/postgres.dart';

import '../interfaces/database/remote_database.dart';
import '../interfaces/service/env_service.dart';

class PostgresDatabase implements IRemoteDatabase, Disposable {
  final completer = Completer<Connection>();
  final IEnvService env;

  PostgresDatabase(this.env) {
    _init();
  }

  _init() async {
    final conn = await Connection.open(
      Endpoint(
        host: env['POSTGRES_HOST'] ?? '',
        database: env['POSTGRES_DATABASE'] ?? '',
        username: env['POSTGRES_USER'],
        password: env['POSTGRES_PASS'],
      ),
      settings: ConnectionSettings(
        sslMode: SslMode.disable,
      ),
    );

    completer.complete(conn);
  }

  @override
  Future<Result> query(
    String queryText, {
    Map<String, dynamic> variables = const {},
  }) async {
    final connection = await completer.future;

    return await connection.execute(
      Sql.named(queryText),
      parameters: variables,
    );
  }

  @override
  void dispose() async {
    final connection = await completer.future;
    await connection.close();
  }
}
