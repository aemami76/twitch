class MyUser {
  String email;
  String username;
  String uid;

  MyUser({required this.email, required this.username, required this.uid});

  static MyUser fromMap(Map<String, dynamic> map) =>
      MyUser(email: map['email'], username: map['username'], uid: map['uid']);

  static MyUser? instance;
}
