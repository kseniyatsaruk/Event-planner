import 'package:dio/dio.dart';

import '../models/checklist_item.dart';

class ChecklistApi {
  ChecklistApi(this._dio);

  final Dio _dio;

  Future<List<ChecklistItem>> list(int eventId) async {
    final response = await _dio.get('/events/$eventId/checklist');
    return (response.data as List)
        .map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ChecklistItem> create(
    int eventId, {
    required String title,
    String? category,
    String? dueDate,
  }) async {
    final response = await _dio.post('/events/$eventId/checklist', data: {
      'title': title,
      'category': category,
      'dueDate': dueDate,
    });
    return ChecklistItem.fromJson(response.data as Map<String, dynamic>);
  }

  /// Full update, matching the backend's PUT semantics: every field is
  /// replaced, so callers must pass the complete current item state (e.g. a
  /// status-only toggle still needs to resend title/description/etc.).
  Future<ChecklistItem> update(
    int eventId,
    int itemId, {
    required String title,
    String? description,
    String? category,
    String? dueDate,
    required String status,
    int? vendorId,
  }) async {
    final response = await _dio.put('/events/$eventId/checklist/$itemId', data: {
      'title': title,
      'description': description,
      'category': category,
      'dueDate': dueDate,
      'status': status,
      'vendorId': vendorId,
    });
    return ChecklistItem.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> delete(int eventId, int itemId) async {
    await _dio.delete('/events/$eventId/checklist/$itemId');
  }
}
