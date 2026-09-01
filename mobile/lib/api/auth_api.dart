import 'package:dio/dio.dart';

import '../models/auth_result.dart';
import '../models/user_info.dart';

class AuthApi {
  AuthApi(this._dio);

  final Dio _dio;

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return AuthResult.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AuthResult> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await _dio.post('/auth/register', data: {
      'email': email,
      'password': password,
      'name': name,
    });
    return AuthResult.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserInfo> me() async {
    final response = await _dio.get('/auth/me');
    return UserInfo.fromJson(response.data as Map<String, dynamic>);
  }
}
