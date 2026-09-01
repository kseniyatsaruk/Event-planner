/// Named EventTable to avoid clashing with Flutter's own Table widget.
class EventTable {
  EventTable({
    required this.id,
    required this.eventId,
    required this.label,
    required this.capacity,
    required this.shape,
    required this.posX,
    required this.posY,
    required this.rotation,
    required this.createdAt,
  });

  final int id;
  final int eventId;
  final String label;
  final int capacity;
  final String shape;
  final double posX;
  final double posY;
  final double rotation;
  final DateTime createdAt;

  factory EventTable.fromJson(Map<String, dynamic> json) => EventTable(
        id: json['id'] as int,
        eventId: json['eventId'] as int,
        label: json['label'] as String,
        capacity: json['capacity'] as int,
        shape: json['shape'] as String,
        posX: (json['posX'] as num).toDouble(),
        posY: (json['posY'] as num).toDouble(),
        rotation: (json['rotation'] as num).toDouble(),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
