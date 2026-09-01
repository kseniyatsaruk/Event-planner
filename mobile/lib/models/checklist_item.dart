class ChecklistItem {
  ChecklistItem({
    required this.id,
    required this.eventId,
    required this.title,
    this.description,
    this.category,
    this.dueDate,
    required this.status,
    this.vendorId,
    required this.sortOrder,
    required this.createdAt,
  });

  final int id;
  final int eventId;
  final String title;
  final String? description;
  final String? category;
  final DateTime? dueDate;
  final String status;
  final int? vendorId;
  final int sortOrder;
  final DateTime createdAt;

  factory ChecklistItem.fromJson(Map<String, dynamic> json) => ChecklistItem(
        id: json['id'] as int,
        eventId: json['eventId'] as int,
        title: json['title'] as String,
        description: json['description'] as String?,
        category: json['category'] as String?,
        dueDate: json['dueDate'] != null
            ? DateTime.tryParse(json['dueDate'] as String)
            : null,
        status: json['status'] as String,
        vendorId: json['vendorId'] as int?,
        sortOrder: json['sortOrder'] as int,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
