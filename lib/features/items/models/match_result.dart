import 'item.dart';

class MatchCandidate {
  final String id;
  final Item lostItem;
  final Item foundItem;
  final double score; // 0.0 to 1.0 (or percentage)
  final String status; // 'SUGGESTED', 'CONFIRMED', 'REJECTED'
  final String reason;
  final DateTime? matchedAt;
  final bool notifiedLostUser;
  final bool notifiedFoundUser;

  MatchCandidate({
    required this.id,
    required this.lostItem,
    required this.foundItem,
    required this.score,
    this.status = 'SUGGESTED',
    required this.reason,
    this.matchedAt,
    this.notifiedLostUser = true,
    this.notifiedFoundUser = true,
  });

  factory MatchCandidate.fromJson(Map<String, dynamic> json) {
    Item? parseItem(dynamic data, String fallbackType) {
      if (data is Map<String, dynamic>) {
        return Item.fromJson(data);
      }
      return Item(
        id: (json['itemId'] ?? json['targetId'] ?? '').toString(),
        type: fallbackType,
        title: (json['itemTitle'] ?? 'Campus Item').toString(),
        description: '',
        status: 'OPEN',
        location: '',
      );
    }

    final lost = json['lostItem'] != null
        ? Item.fromJson(json['lostItem'] as Map<String, dynamic>)
        : parseItem(json['lost'], 'LOST');

    final found = json['foundItem'] != null
        ? Item.fromJson(json['foundItem'] as Map<String, dynamic>)
        : parseItem(json['found'], 'FOUND');

    double scoreVal = 0.85;
    if (json['score'] is num) {
      scoreVal = (json['score'] as num).toDouble();
      if (scoreVal > 1.0) scoreVal = scoreVal / 100.0; // normalize percentage
    } else if (json['similarity'] is num) {
      scoreVal = (json['similarity'] as num).toDouble();
      if (scoreVal > 1.0) scoreVal = scoreVal / 100.0;
    }

    DateTime? dt;
    if (json['matchedAt'] != null) {
      dt = DateTime.tryParse(json['matchedAt'].toString());
    }

    return MatchCandidate(
      id: (json['id'] ?? '${lost?.id}_${found?.id}').toString(),
      lostItem: lost ?? Item(id: 'lost_1', type: 'LOST', title: 'Lost Item', description: '', status: 'OPEN', location: ''),
      foundItem: found ?? Item(id: 'found_1', type: 'FOUND', title: 'Found Item', description: '', status: 'OPEN', location: ''),
      score: scoreVal,
      status: (json['status'] ?? 'SUGGESTED').toString().toUpperCase(),
      reason: json['reason']?.toString() ?? json['notes']?.toString() ?? 'High title and category correspondence',
      matchedAt: dt ?? DateTime.now(),
      notifiedLostUser: json['notifiedLostUser'] ?? true,
      notifiedFoundUser: json['notifiedFoundUser'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'lostItem': lostItem.toJson(),
    'foundItem': foundItem.toJson(),
    'score': score,
    'status': status,
    'reason': reason,
    'matchedAt': matchedAt?.toIso8601String(),
    'notifiedLostUser': notifiedLostUser,
    'notifiedFoundUser': notifiedFoundUser,
  };

  int get scorePercentage => (score * 100).round().clamp(0, 100);
}

class OwnershipClaimRequest {
  final String id;
  final String itemId;
  final String itemTitle;
  final String claimantEmail;
  final String claimantName;
  final String? studentId;
  final String lostLocation;
  final String lostDate;
  final String identifyingMarks;
  final String internalContents;
  final String proofDescription;
  final String status; // 'PENDING', 'UNDER_REVIEW', 'VERIFIED', 'REJECTED', 'CANCELLED', 'COMPLETED'
  final DateTime createdAt;
  final String? reviewerNotes;
  final String? handoverNotes;

  OwnershipClaimRequest({
    required this.id,
    required this.itemId,
    this.itemTitle = '',
    required this.claimantEmail,
    required this.claimantName,
    this.studentId,
    this.lostLocation = '',
    this.lostDate = '',
    this.identifyingMarks = '',
    this.internalContents = '',
    required this.proofDescription,
    this.status = 'PENDING',
    required this.createdAt,
    this.reviewerNotes,
    this.handoverNotes,
  });

  factory OwnershipClaimRequest.fromJson(Map<String, dynamic> json) {
    return OwnershipClaimRequest(
      id: (json['id'] ?? '').toString(),
      itemId: (json['itemId'] ?? json['targetItemId'] ?? '').toString(),
      itemTitle: json['itemTitle']?.toString() ?? json['title']?.toString() ?? '',
      claimantEmail: json['claimantEmail']?.toString() ?? '',
      claimantName: json['claimantName']?.toString() ?? '',
      studentId: json['studentId']?.toString(),
      lostLocation: json['lostLocation']?.toString() ?? '',
      lostDate: json['lostDate']?.toString() ?? '',
      identifyingMarks: json['identifyingMarks']?.toString() ?? '',
      internalContents: json['internalContents']?.toString() ?? '',
      proofDescription: json['proofDescription']?.toString() ?? json['proof']?.toString() ?? '',
      status: (json['status'] ?? 'PENDING').toString().toUpperCase(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      reviewerNotes: json['reviewerNotes']?.toString(),
      handoverNotes: json['handoverNotes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'itemId': itemId,
    'itemTitle': itemTitle,
    'claimantEmail': claimantEmail,
    'claimantName': claimantName,
    'studentId': studentId,
    'lostLocation': lostLocation,
    'lostDate': lostDate,
    'identifyingMarks': identifyingMarks,
    'internalContents': internalContents,
    'proofDescription': proofDescription,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'reviewerNotes': reviewerNotes,
    'handoverNotes': handoverNotes,
  };

  bool get isPending => status == 'PENDING';
  bool get isUnderReview => status == 'UNDER_REVIEW';
  bool get isVerified => status == 'VERIFIED';
  bool get isRejected => status == 'REJECTED';
  bool get isCancelled => status == 'CANCELLED';
  bool get isCompleted => status == 'COMPLETED';

  OwnershipClaimRequest copyWith({
    String? status,
    String? reviewerNotes,
    String? handoverNotes,
  }) {
    return OwnershipClaimRequest(
      id: id,
      itemId: itemId,
      itemTitle: itemTitle,
      claimantEmail: claimantEmail,
      claimantName: claimantName,
      studentId: studentId,
      lostLocation: lostLocation,
      lostDate: lostDate,
      identifyingMarks: identifyingMarks,
      internalContents: internalContents,
      proofDescription: proofDescription,
      status: status ?? this.status,
      createdAt: createdAt,
      reviewerNotes: reviewerNotes ?? this.reviewerNotes,
      handoverNotes: handoverNotes ?? this.handoverNotes,
    );
  }
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final String type; // 'MATCH_FOUND', 'CLAIM_SUBMITTED', 'STATUS_UPDATED', 'ITEM_CLOSED'
  final String? relatedItemId;
  final DateTime timestamp;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.relatedItemId,
    required this.timestamp,
    this.isRead = false,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: (json['id'] ?? '').toString(),
      title: json['title']?.toString() ?? 'Campus Notice',
      message: json['message']?.toString() ?? '',
      type: (json['type'] ?? 'MATCH_FOUND').toString().toUpperCase(),
      relatedItemId: json['relatedItemId']?.toString() ?? json['itemId']?.toString(),
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isRead: json['isRead'] == true || json['read'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'message': message,
    'type': type,
    'relatedItemId': relatedItemId,
    'timestamp': timestamp.toIso8601String(),
    'isRead': isRead,
  };

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    String? relatedItemId,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      relatedItemId: relatedItemId ?? this.relatedItemId,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}
