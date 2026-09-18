class Item {
  final String id;
  final String type; // 'LOST' or 'FOUND'
  final String title;
  final String description;
  final String status; // 'OPEN', 'CLOSED', 'MATCHED', 'CLAIMED', 'RETURNED'
  final String location;
  final String? imageUrl;
  final String? reportedByName;
  final String? reportedByEmail;
  final String? reportedById;
  final String? category;
  final String? createdAt;
  final String? eventFrom;
  final String? eventTo;
  // Use Case 2 & 5: Custody status distinguishing FOUND_REPORTED vs RECEIVED_BY_SECURITY vs AVAILABLE_FOR_CLAIM vs HANDED_OVER
  final String custodyStatus;

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
    this.custodyStatus = 'AWAITING_SECURITY',
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    final t = (json['type'] ?? 'LOST').toString().toUpperCase();
    final s = (json['status'] ?? 'OPEN').toString().toUpperCase();

    // Inferred custody status if not explicitly sent by backend
    String custody = (json['custodyStatus'] ?? json['custody'] ?? '').toString().toUpperCase();
    if (custody.isEmpty) {
      if (t == 'FOUND') {
        if (s == 'RETURNED' || s == 'CLOSED') {
          custody = 'HANDED_OVER';
        } else if (s == 'CLAIMED') {
          custody = 'RECEIVED_BY_SECURITY';
        } else {
          custody = 'AWAITING_SECURITY';
        }
      } else {
        custody = 'NOT_APPLICABLE';
      }
    }

    return Item(
      id: (json['id'] ?? '').toString(),
      type: t,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: s,
      location: json['location']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
      reportedByName: json['reportedByName']?.toString(),
      reportedByEmail: json['reportedByEmail']?.toString() ?? json['reporterEmail']?.toString(),
      reportedById: json['reportedById']?.toString() ?? json['reporterId']?.toString(),
      category: json['category']?.toString(),
      createdAt: json['createdAt']?.toString(),
      eventFrom: json['eventFrom']?.toString(),
      eventTo: json['eventTo']?.toString(),
      custodyStatus: custody,
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
    'custodyStatus': custodyStatus,
  };

  bool get isLost => type == 'LOST';
  bool get isFound => type == 'FOUND';
  bool get isOpen => status == 'OPEN';
  bool get isClosed => status == 'CLOSED';
  bool get isMatched => status == 'MATCHED';
  bool get isClaimed => status == 'CLAIMED';
  bool get isReturned => status == 'RETURNED';

  bool get isReceivedBySecurity =>
      custodyStatus == 'RECEIVED_BY_SECURITY' ||
      custodyStatus == 'AVAILABLE_FOR_CLAIM' ||
      custodyStatus == 'HANDED_OVER';
}
