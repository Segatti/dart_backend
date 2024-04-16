import 'package:dart_backend/src/core/interfaces/service/encrypt_service.dart';
import 'package:dart_backend/src/core/service/encrypt_service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';

import 'core/database/postgres_database.dart';
import 'core/interfaces/database/remote_database.dart';
import 'core/interfaces/service/env_service.dart';
import 'core/service/env_service.dart';
import 'modules/user/user_resource.dart';
import 'swagger_handler.dart';

class AppModule extends Module {
  @override
  List<Bind> get binds => [
        Bind.instance<IEnvService>(EnvService.instance),
        Bind.singleton<IRemoteDatabase>((i) => PostgresDatabase(i())),
        Bind.singleton<IEncryptService>((i) => EncryptService()),
      ];

  @override
  List<ModularRoute> get routes => [
        Route.get("/", () => Response.ok("body")),
        // /** posix para dizer que pode ser qualquer coisa depois do /
        Route.get("/documentation/**", startSwagger),
        Route.resource(UserResource()),
      ];
}
