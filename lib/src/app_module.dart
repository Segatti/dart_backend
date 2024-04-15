import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';

import 'modules/user/user_resource.dart';

class AppModule extends Module {
  @override
  List<ModularRoute> get routes => [
        Route.get("/", () => Response.ok("body")),
        Route.resource(UserResource()),
      ];
}
