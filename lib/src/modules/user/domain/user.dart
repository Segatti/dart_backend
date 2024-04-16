import 'dart:convert';

import 'package:postgres/postgres.dart';

import 'type_user.dart';

class User {
  final int? id;
  final String? name;
  final String? email;
  final String? password;
  final TypeUser? typeUser;

  const User({
    this.id,
    this.name,
    this.email,
    this.password,
    this.typeUser,
  });

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    TypeUser? typeUser,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      typeUser: typeUser ?? this.typeUser,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'typeUser': typeUser?.name,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] != null ? map['id'] as int : null,
      name: map['name'] != null ? map['name'] as String : null,
      email: map['email'] != null ? map['email'] as String : null,
      password: map['password'] != null ? map['password'] as String : null,
      typeUser: map['typeUser'] != null
          ? TypeUser.getEnum((map['typeUser'] as UndecodedBytes).asString)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) =>
      User.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, password: $password, typeUser: $typeUser)';
  }

  @override
  bool operator ==(covariant User other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.email == email &&
        other.password == password &&
        other.typeUser == typeUser;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        email.hashCode ^
        password.hashCode ^
        typeUser.hashCode;
  }
}
