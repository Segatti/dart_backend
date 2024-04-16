import 'package:dart_backend/src/core/interfaces/service/env_service.dart';
import 'package:dart_backend/src/core/service/env_service.dart';
import 'package:shelf_modular/shelf_modular.dart';

import 'database/postgres_database.dart';
import 'interfaces/database/remote_database.dart';

class CoreModule extends Module {
  @override
  List<Bind> get binds => [
        Bind.instance<IEnvService>(EnvService.instance),
        Bind.singleton<IRemoteDatabase>((i) => PostgresDatabase(i())),
      ];
}
