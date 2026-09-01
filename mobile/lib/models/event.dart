class EventItem {
  EventItem({
    required this.id,
    required this.userId,
    required this.name,
    this.eventDate,
    this.description,
    this.locationAddress,
    this.locationLat,
    this.locationLng,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int userId;
  final String name;
  final DateTime? eventDate;
  final String? description;
  final String? locationAddress;
  final double? locationLat;
  final double? locationLng;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory EventItem.fromJson(Map<String, dynamic> json) => EventItem(
        id: json['id'] as int,
        userId: json['userId'] as int,
        name: json['name'] as String,
        eventDate: json['eventDate'] != null
            ? DateTime.tryParse(json['eventDate'] as String)
            : null,
        description: json['description'] as String?,
        locationAddress: json['locationAddress'] as String?,
        locationLat: (json['locationLat'] as num?)?.toDouble(),
        locationLng: (json['locationLng'] as num?)?.toDouble(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}
