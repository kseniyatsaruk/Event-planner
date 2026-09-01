import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../state/auth_store.dart';
import '../state/settings_store.dart';

/// Wraps a [Dio] instance whose base URL and Authorization header are
/// resolved from [SettingsStore] / [AuthStore] on every request, since the
/// server address and the logged-in session can both change at runtime.
class ApiClient {
  ApiClient({
    required this.settings,
    required this.auth,
    this.onUnauthorized,
  }) : dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        )) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.baseUrl = _resolveBaseUrl();
          final token = auth.token;
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          final path = error.requestOptions.path;
          final isAuthEntryPoint =
              path.endsWith('/auth/login') || path.endsWith('/auth/register');
          if (error.response?.statusCode == 401 && !isAuthEntryPoint) {
            auth.logout();
            onUnauthorized?.call();
          }
          handler.next(error);
        },
      ),
    );
  }

  final Dio dio;
  final SettingsStore settings;
  final AuthStore auth;
  final VoidCallback? onUnauthorized;

  String _resolveBaseUrl() {
    var value = settings.baseUrl.trim();
    if (value.isEmpty) return '';
    if (!value.startsWith('http://') && !value.startsWith('https://')) {
      value = 'http://$value';
    }
    if (value.endsWith('/')) {
      value = value.substring(0, value.length - 1);
    }
    return '$value/api';
  }
}
