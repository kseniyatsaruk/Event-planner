import 'package:dio/dio.dart';

import '../models/table_model.dart';

class TablesApi {
  TablesApi(this._dio);

  final Dio _dio;

  Future<List<EventTable>> list(int eventId) async {
    final response = await _dio.get('/events/$eventId/tables');
    return (response.data as List)
        .map((e) => EventTable.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<EventTable> create(
    int eventId, {
    required String label,
    int capacity = 8,
    String shape = 'round',
  }) async {
    final response = await _dio.post('/events/$eventId/tables', data: {
      'label': label,
      'capacity': capacity,
      'shape': shape,
    });
    return EventTable.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> delete(int eventId, int tableId) async {
    await _dio.delete('/events/$eventId/tables/$tableId');
  }
}
