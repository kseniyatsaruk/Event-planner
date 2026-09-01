class Guest {
  Guest({
    required this.id,
    required this.eventId,
    required this.name,
    this.phone,
    this.email,
    required this.rsvpStatus,
    required this.plusOne,
    this.notes,
    this.tableId,
    this.seatNumber,
    required this.createdAt,
  });

  final int id;
  final int eventId;
  final String name;
  final String? phone;
  final String? email;
  final String rsvpStatus;
  final bool plusOne;
  final String? notes;
  final int? tableId;
  final int? seatNumber;
  final DateTime createdAt;

  factory Guest.fromJson(Map<String, dynamic> json) => Guest(
        id: json['id'] as int,
        eventId: json['eventId'] as int,
        name: json['name'] as String,
        phone: json['phone'] as String?,
        email: json['email'] as String?,
        rsvpStatus: json['rsvpStatus'] as String,
        plusOne: json['plusOne'] as bool,
        notes: json['notes'] as String?,
        tableId: json['tableId'] as int?,
        seatNumber: json['seatNumber'] as int?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  /// A copy with the table assignment cleared, for optimistically reflecting
  /// a table deletion locally (mirrors the backend's ON DELETE SET NULL).
  Guest unseated() => Guest(
        id: id,
        eventId: eventId,
        name: name,
        phone: phone,
        email: email,
        rsvpStatus: rsvpStatus,
        plusOne: plusOne,
        notes: notes,
        tableId: null,
        seatNumber: null,
        createdAt: createdAt,
      );
}
