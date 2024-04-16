import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';

import 'core/database/postgres_database.dart';
import 'core/interfaces/database/remote_database.dart';
import 'core/interfaces/service/env_service.dart';
import 'core/service/env_service.dart';
import 'modules/user/user_resource.dart';

class AppModule extends Module {
  @override
  List<Bind> get binds => [
        Bind.instance<IEnvService>(EnvService.instance),
        Bind.singleton<IRemoteDatabase>((i) => PostgresDatabase(i())),
      ];

  @override
  List<ModularRoute> get routes => [
        Route.get("/", () => Response.ok("body")),
        Route.resource(UserResource()),
      ];
}
