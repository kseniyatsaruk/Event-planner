class UserInfo {
  UserInfo({required this.id, required this.email, required this.name});

  final int id;
  final String email;
  final String name;

  factory UserInfo.fromJson(Map<String, dynamic> json) => UserInfo(
        id: json['id'] as int,
        email: json['email'] as String,
        name: json['name'] as String,
      );
}
