class Item {
  final String id;
  final String type; // 'LOST' or 'FOUND'
  final String title;
  final String description;
  final String status; // 'OPEN', 'CLOSED', 'MATCHED', 'CLAIMED'
  final String location;
  final String? imageUrl;
  final String? reportedByName;
  final String? reportedByEmail;
  final String? reportedById;
  final String? category;
  final String? createdAt;
  final String? eventFrom;
  final String? eventTo;

  Item({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.status,
    required this.location,
    this.imageUrl,
    this.reportedByName,
    this.reportedByEmail,
    this.reportedById,
    this.category,
    this.createdAt,
    this.eventFrom,
    this.eventTo,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: (json['id'] ?? '').toString(),
      type: (json['type'] ?? 'LOST').toString().toUpperCase(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: (json['status'] ?? 'OPEN').toString().toUpperCase(),
      location: json['location']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
      reportedByName: json['reportedByName']?.toString(),
      reportedByEmail: json['reportedByEmail']?.toString() ?? json['reporterEmail']?.toString(),
      reportedById: json['reportedById']?.toString() ?? json['reporterId']?.toString(),
      category: json['category']?.toString(),
      createdAt: json['createdAt']?.toString(),
      eventFrom: json['eventFrom']?.toString(),
      eventTo: json['eventTo']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'title': title,
    'description': description,
    'status': status,
    'location': location,
    'imageUrl': imageUrl,
    'reportedByName': reportedByName,
    'reportedByEmail': reportedByEmail,
    'reportedById': reportedById,
    'category': category,
    'createdAt': createdAt,
    'eventFrom': eventFrom,
    'eventTo': eventTo,
  };

  bool get isLost => type == 'LOST';
  bool get isFound => type == 'FOUND';
  bool get isOpen => status == 'OPEN';
  bool get isClosed => status == 'CLOSED';
  bool get isMatched => status == 'MATCHED';
  bool get isClaimed => status == 'CLAIMED';
}
