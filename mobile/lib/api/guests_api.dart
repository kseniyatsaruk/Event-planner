import 'package:dio/dio.dart';

import '../models/guest.dart';

class GuestsApi {
  GuestsApi(this._dio);

  final Dio _dio;

  Future<List<Guest>> list(int eventId) async {
    final response = await _dio.get('/events/$eventId/guests');
    return (response.data as List)
        .map((e) => Guest.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Guest> create(
    int eventId, {
    required String name,
    String? phone,
    String? email,
    bool plusOne = false,
  }) async {
    final response = await _dio.post('/events/$eventId/guests', data: {
      'name': name,
      'phone': phone,
      'email': email,
      'plusOne': plusOne,
    });
    return Guest.fromJson(response.data as Map<String, dynamic>);
  }

  /// Full update, matching the backend's PUT semantics: every field is
  /// replaced, so callers must pass the complete current guest state (e.g. an
  /// RSVP-only change still needs to resend name/phone/etc.). The returned
  /// guest is the authoritative post-save state — the backend may clear
  /// tableId/seatNumber as a side effect when plusOne no longer fits where
  /// the guest is currently seated, so callers must apply this response
  /// rather than assume the request payload took effect as sent.
  Future<Guest> update(
    int eventId,
    int guestId, {
    required String name,
    String? phone,
    String? email,
    required String rsvpStatus,
    required bool plusOne,
    String? notes,
  }) async {
    final response = await _dio.put('/events/$eventId/guests/$guestId', data: {
      'name': name,
      'phone': phone,
      'email': email,
      'rsvpStatus': rsvpStatus,
      'plusOne': plusOne,
      'notes': notes,
    });
    return Guest.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> delete(int eventId, int guestId) async {
    await _dio.delete('/events/$eventId/guests/$guestId');
  }

  /// Assigns or clears a guest's table/seat. Pass both null to unassign.
  /// The backend is the source of truth for whether this succeeds — it can
  /// reject with plus_one_no_room (the guest's +1 has no adjacent seat) or
  /// seat_taken (race with another assignment) — and the returned guest
  /// (including any server-adjusted seatNumber) must be applied as-is.
  Future<Guest> assignTable(
    int eventId,
    int guestId, {
    required int? tableId,
    required int? seatNumber,
  }) async {
    final response =
        await _dio.patch('/events/$eventId/guests/$guestId/table', data: {
      'tableId': tableId,
      'seatNumber': seatNumber,
    });
    return Guest.fromJson(response.data as Map<String, dynamic>);
  }
}
