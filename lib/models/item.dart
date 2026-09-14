class Item {
  final String id;
  final String type; // 'LOST' or 'FOUND'
  final String title;
  final String description;
  final String status; // 'OPEN', 'CLOSED', etc.
  final String location;
  final String? imageUrl;
  final String? reportedByName;
  final String? createdAt;

  Item({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.status,
    required this.location,
    this.imageUrl,
    this.reportedByName,
    this.createdAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: (json['id'] ?? '').toString(),
      type: (json['type'] ?? 'LOST').toString().toUpperCase(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? 'OPEN',
      location: json['location']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
      reportedByName: json['reportedByName']?.toString(),
      createdAt: json['createdAt']?.toString(),
    );
  }

  bool get isLost => type == 'LOST';
  bool get isFound => type == 'FOUND';
  bool get isClosed => status.toUpperCase() == 'CLOSED';
}
