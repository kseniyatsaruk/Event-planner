import 'user_info.dart';

class AuthResult {
  AuthResult({required this.token, required this.user});

  final String token;
  final UserInfo user;

  factory AuthResult.fromJson(Map<String, dynamic> json) => AuthResult(
        token: json['token'] as String,
        user: UserInfo.fromJson(json['user'] as Map<String, dynamic>),
      );
}
