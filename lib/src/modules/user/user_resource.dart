import 'dart:async';
import 'dart:convert';

import 'package:dart_backend/src/core/interfaces/service/encrypt_service.dart';
import 'package:dart_backend/src/modules/user/domain/user.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';

import '../../core/interfaces/database/remote_database.dart';

class UserResource extends Resource {
  @override
  List<Route> get routes => [
        Route.get("/user", _getAllUsers),
        Route.get("/user/:id", _getUser),
        Route.post("/user", _createUser),
        Route.put("/user", _updateUser),
        Route.delete("/user/:id", _deleteUser),
      ];
}

FutureOr<Response> _getAllUsers(Injector injector) async {
  final database = injector.get<IRemoteDatabase>();
  final result = await database.query(
    'select id, name, email, "typeUser" from "User"',
  );
  List<User> users = result.map((e) => User.fromMap(e.toColumnMap())).toList();
  return Response.ok(jsonEncode(users.map((e) => e.toMap()).toList()));
}

FutureOr<Response> _getUser(ModularArguments args, Injector injector) async {
  final id = args.params['id'];
  final database = injector.get<IRemoteDatabase>();
  final result = await database.query(
    'select id, name, email, "typeUser" from "User" where id = @id',
    variables: {"id": id},
  );

  List<User> users = result.map((e) => User.fromMap(e.toColumnMap())).toList();

  if (users.isNotEmpty) {
    return Response.ok(jsonEncode(users.first.toMap()));
  } else {
    return Response.notFound("User not found");
  }
}

FutureOr<Response> _createUser(ModularArguments args, Injector injector) async {
  final Map<String, dynamic> data = args.data;
  data.remove("id");

  final encryptService = injector.get<IEncryptService>();
  data['password'] = encryptService.encrypt(data['password']);
  
  final database = injector.get<IRemoteDatabase>();
  final result = await database.query(
    'insert into "User" (name, email, password, "typeUser") values (@name, @email, @password, @typeUser)',
    variables: data,
  );

  if (result.affectedRows > 0) {
    return Response.ok("User created!");
  } else {
    return Response.badRequest(body: "User not created");
  }
}

FutureOr<Response> _updateUser(ModularArguments args, Injector injector) async {
  final Map<String, dynamic> data = args.data;
  final id = data['id'];
  data.remove("id");
  data.remove("userType");

  final database = injector.get<IRemoteDatabase>();
  final List<String> columns = data.keys.map((key) => "$key=@$key").toList();
  final result = await database.query(
    'update "User" set ${columns.join(", ")} where id = @id',
    variables: {
      "id": id,
      ...data,
    },
  );

  if (result.affectedRows > 0) {
    return Response.ok("User updated!");
  } else {
    return Response.notFound("User not found");
  }
}

FutureOr<Response> _deleteUser(ModularArguments args, Injector injector) async {
  final id = args.params['id'];
  final database = injector.get<IRemoteDatabase>();
  final result = await database.query(
    'delete from "User" where id = @id',
    variables: {"id": id},
  );

  if (result.affectedRows > 0) {
    return Response.ok("User deleted! id: $id");
  } else {
    return Response.notFound("User not found");
  }
}
