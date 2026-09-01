import 'package:dio/dio.dart';

import '../models/event.dart';

class EventsApi {
  EventsApi(this._dio);

  final Dio _dio;

  Future<List<EventItem>> list() async {
    final response = await _dio.get('/events');
    return (response.data as List)
        .map((e) => EventItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<EventItem> create({
    required String name,
    DateTime? eventDate,
    String? description,
  }) async {
    final response = await _dio.post('/events', data: {
      'name': name,
      if (eventDate != null) 'eventDate': eventDate.toIso8601String(),
      if (description != null && description.isNotEmpty)
        'description': description,
    });
    return EventItem.fromJson(response.data as Map<String, dynamic>);
  }

  Future<EventItem> get(int eventId) async {
    final response = await _dio.get('/events/$eventId');
    return EventItem.fromJson(response.data as Map<String, dynamic>);
  }

  /// Full update, matching the backend's PUT semantics: every field is
  /// replaced, so callers must pass the complete current form state (an
  /// omitted address/location isn't a no-op, it clears the stored value).
  Future<EventItem> update(
    int eventId, {
    required String name,
    String? eventDate,
    String? description,
    String? locationAddress,
    double? locationLat,
    double? locationLng,
  }) async {
    final response = await _dio.put('/events/$eventId', data: {
      'name': name,
      'eventDate': eventDate,
      'description': description,
      'locationAddress': locationAddress,
      'locationLat': locationLat,
      'locationLng': locationLng,
    });
    return EventItem.fromJson(response.data as Map<String, dynamic>);
  }
}
