enum TypeUser {
  none,
  user,
  immobile;

  static TypeUser? getEnum(String value) {
    for (var item in TypeUser.values) {
      if (item.name == value) {
        return item;
      }
    }
    return null;
  }
}