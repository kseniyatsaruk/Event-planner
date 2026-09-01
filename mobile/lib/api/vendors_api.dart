import 'package:dio/dio.dart';

import '../models/vendor.dart';

class VendorsApi {
  VendorsApi(this._dio);

  final Dio _dio;

  Future<List<Vendor>> list(int eventId) async {
    final response = await _dio.get('/events/$eventId/vendors');
    return (response.data as List)
        .map((e) => Vendor.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Vendor> create(
    int eventId, {
    required String name,
    String? category,
    String? contactName,
    String? phone,
    double? price,
  }) async {
    final response = await _dio.post('/events/$eventId/vendors', data: {
      'name': name,
      'category': category,
      'contactName': contactName,
      'phone': phone,
      'price': price,
    });
    return Vendor.fromJson(response.data as Map<String, dynamic>);
  }

  /// Full update, matching the backend's PUT semantics: every field is
  /// replaced, so callers must pass the complete current vendor state (e.g.
  /// a status-only change still needs to resend name/category/etc.).
  Future<Vendor> update(
    int eventId,
    int vendorId, {
    required String name,
    String? category,
    String? contactName,
    String? phone,
    String? email,
    double? price,
    required String status,
    String? notes,
  }) async {
    final response = await _dio.put('/events/$eventId/vendors/$vendorId', data: {
      'name': name,
      'category': category,
      'contactName': contactName,
      'phone': phone,
      'email': email,
      'price': price,
      'status': status,
      'notes': notes,
    });
    return Vendor.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> delete(int eventId, int vendorId) async {
    await _dio.delete('/events/$eventId/vendors/$vendorId');
  }
}
