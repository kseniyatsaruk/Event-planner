class Vendor {
  Vendor({
    required this.id,
    required this.eventId,
    required this.name,
    this.category,
    this.contactName,
    this.phone,
    this.email,
    this.price,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  final int id;
  final int eventId;
  final String name;
  final String? category;
  final String? contactName;
  final String? phone;
  final String? email;
  final double? price;
  final String status;
  final String? notes;
  final DateTime createdAt;

  factory Vendor.fromJson(Map<String, dynamic> json) => Vendor(
        id: json['id'] as int,
        eventId: json['eventId'] as int,
        name: json['name'] as String,
        category: json['category'] as String?,
        contactName: json['contactName'] as String?,
        phone: json['phone'] as String?,
        email: json['email'] as String?,
        price: (json['price'] as num?)?.toDouble(),
        status: json['status'] as String,
        notes: json['notes'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
