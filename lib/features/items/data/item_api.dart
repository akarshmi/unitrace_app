import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/storage/token_storage.dart';
import '../models/item.dart';
import '../models/match_result.dart';
import 'claims_storage.dart';
import 'notification_storage.dart';

class ItemApi {
  final ApiClient _client = ApiClient();

  // OAS 3.1: GET /api/uni/v1/items
  // REQUIRED query parameters: `type` (LOST|FOUND) and `status` (OPEN|CLOSED|MATCHED|CLAIMED)
  Future<List<Item>> getItems({
    required String type,
    required String status,
    int page = 0,
    int size = 20,
    String? sort,
  }) async {
    final queryParams = <String, dynamic>{
      'type': type.toUpperCase(),
      'status': status.toUpperCase(),
      'page': page,
      'size': size,
    };
    if (sort != null && sort.isNotEmpty) {
      queryParams['sort'] = sort;
    }

    final response = await _client.dio.get(
      ApiEndpoints.items,
      queryParameters: queryParams,
    );

    final data = response.data;
    List<dynamic> itemsList = [];
    if (data is List) {
      itemsList = data;
    } else if (data is Map && data.containsKey('content')) {
      itemsList = data['content'] as List<dynamic>;
    } else if (data is Map && data.containsKey('items')) {
      itemsList = data['items'] as List<dynamic>;
    }

    return itemsList.map((item) => Item.fromJson(item as Map<String, dynamic>)).toList();
  }

  // OAS 3.1: GET /api/uni/v1/items/{id}
  Future<Item> getItemById(String id) async {
    final response = await _client.dio.get(ApiEndpoints.itemById(id));
    return Item.fromJson(response.data as Map<String, dynamic>);
  }

  // OAS 3.1: POST /api/uni/v1/items (multipart/form-data)
  Future<Item> createItem({
    required String type,
    required String title,
    required String description,
    required String location,
    String? category,
    String? eventFrom,
    String? eventTo,
    XFile? imageFile,
  }) async {
    final formDataMap = <String, dynamic>{
      'type': type.toUpperCase(),
      'title': title,
      'description': description,
      'location': location,
    };
    if (category != null && category.isNotEmpty) {
      formDataMap['category'] = category;
    }
    if (eventFrom != null && eventFrom.isNotEmpty) {
      formDataMap['eventFrom'] = eventFrom;
    }
    if (eventTo != null && eventTo.isNotEmpty) {
      formDataMap['eventTo'] = eventTo;
    }

    final formData = FormData.fromMap(formDataMap);

    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      var filename = imageFile.name.trim();
      if (filename.isEmpty) {
        filename = 'item_photo.jpg';
      } else if (!filename.contains('.')) {
        filename = '$filename.jpg';
      }

      formData.files.add(
        MapEntry(
          'image',
          MultipartFile.fromBytes(
            bytes,
            filename: filename,
          ),
        ),
      );
    }

    final response = await _client.dio.post(
      ApiEndpoints.items,
      data: formData,
    );

    final createdItem = Item.fromJson(response.data as Map<String, dynamic>);
    
    // Save to local creator list so the user is remembered as creator on this device
    await TokenStorage.addMyCreatedItemId(createdItem.id);

    // Automatically trigger matching across open campus items
    runAutomaticMatchingFor(createdItem).ignore();

    return createdItem;
  }

  // OAS 3.1: PATCH /api/uni/v1/items/{id}/status
  // Backend rule: Only the case creator or a campus moderator can change status
  Future<Item> updateStatus(String id, String status) async {
    final response = await _client.dio.patch(
      ApiEndpoints.itemStatus(id),
      data: {'status': status.toUpperCase()},
    );
    final updated = Item.fromJson(response.data as Map<String, dynamic>);

    if (status.toUpperCase() == 'CLOSED') {
      await NotificationStorage.addNotification(
        AppNotification(
          id: 'closed_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Case Resolved & Closed',
          message: 'Item "${updated.title}" status changed to CLOSED.',
          type: 'ITEM_CLOSED',
          relatedItemId: updated.id,
          timestamp: DateTime.now(),
        ),
      );
    }
    return updated;
  }

  // OAS 3.1: GET /api/uni/v1/match or /match/{itemId}
  Future<List<MatchCandidate>> getMatches({String? itemId}) async {
    try {
      final endpoint = itemId != null ? ApiEndpoints.matchByItemId(itemId) : ApiEndpoints.match;
      final response = await _client.dio.get(endpoint);
      final data = response.data;
      List<dynamic> list = [];
      if (data is List) {
        list = data;
      } else if (data is Map && data.containsKey('matches')) {
        list = data['matches'] as List<dynamic>;
      } else if (data is Map && data.containsKey('content')) {
        list = data['content'] as List<dynamic>;
      }
      return list.map((e) => MatchCandidate.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      // If server does not have /match endpoint deployed or returns 404/500,
      // dynamically compute automatic matches between open lost and found items
      return await computeClientSideMatches(targetItemId: itemId);
    }
  }

  // Automatic matching algorithm comparing Lost vs Found
  Future<List<MatchCandidate>> computeClientSideMatches({String? targetItemId}) async {
    try {
      final lostItems = await getItems(type: 'LOST', status: 'OPEN', size: 50);
      final foundItems = await getItems(type: 'FOUND', status: 'OPEN', size: 50);

      final List<MatchCandidate> results = [];

      for (final lost in lostItems) {
        if (targetItemId != null && lost.id != targetItemId) continue;
        for (final found in foundItems) {
          if (targetItemId != null && targetItemId != lost.id && targetItemId != found.id) continue;

          final score = _calculateSimilarity(lost, found);
          if (score >= 0.35) { // Match threshold
            results.add(
              MatchCandidate(
                id: 'match_${lost.id}_${found.id}',
                lostItem: lost,
                foundItem: found,
                score: score,
                reason: _generateMatchReason(lost, found, score),
                matchedAt: DateTime.now(),
              ),
            );
          }
        }
      }

      // Sort descending by score
      results.sort((a, b) => b.score.compareTo(a.score));
      return results;
    } catch (e) {
      return [];
    }
  }

  // Automatically runs in background when an item is created or refreshed
  Future<void> runAutomaticMatchingFor(Item newItem) async {
    try {
      final oppositeType = newItem.isLost ? 'FOUND' : 'LOST';
      final candidates = await getItems(type: oppositeType, status: 'OPEN', size: 50);

      for (final candidate in candidates) {
        final lost = newItem.isLost ? newItem : candidate;
        final found = newItem.isLost ? candidate : newItem;

        final score = _calculateSimilarity(lost, found);
        if (score >= 0.50) {
          // Add notification to user
          await NotificationStorage.addNotification(
            AppNotification(
              id: 'auto_match_${lost.id}_${found.id}',
              title: 'Potential Match Found! (${(score * 100).round()}%)',
              message: 'Lost "${lost.title}" matches Found "${found.title}" reported at ${found.location}. Check matches now to confirm or claim.',
              type: 'MATCH_FOUND',
              relatedItemId: newItem.id,
              timestamp: DateTime.now(),
            ),
          );
          break; // Avoid spamming multiple notifications for one item
        }
      }
    } catch (_) {}
  }

  // Similarity metric taking title, description, category, and location into account
  double _calculateSimilarity(Item lost, Item found) {
    double totalWeight = 0.0;
    double weightedScore = 0.0;

    // 1. Title token overlap (weight 0.45)
    totalWeight += 0.45;
    final lostTokens = _tokenize(lost.title);
    final foundTokens = _tokenize(found.title);
    if (lostTokens.isNotEmpty && foundTokens.isNotEmpty) {
      final intersection = lostTokens.intersection(foundTokens);
      final jaccard = intersection.length / (lostTokens.union(foundTokens).length);
      weightedScore += 0.45 * (jaccard > 0 ? (jaccard * 0.7 + 0.3) : 0.0);
    }

    // 2. Category matching (weight 0.25)
    totalWeight += 0.25;
    if (lost.category != null && found.category != null && lost.category!.isNotEmpty) {
      if (lost.category!.toLowerCase() == found.category!.toLowerCase()) {
        weightedScore += 0.25;
      }
    } else {
      // Partial category inference from keywords (phone, wallet, keys, laptop, id, card, bottle)
      final kw = ['phone', 'laptop', 'wallet', 'keys', 'card', 'id', 'bottle', 'bag', 'airpods', 'headphones', 'jacket'];
      bool commonType = false;
      for (final k in kw) {
        if (lost.title.toLowerCase().contains(k) && found.title.toLowerCase().contains(k)) {
          commonType = true;
          break;
        }
      }
      if (commonType) weightedScore += 0.25;
    }

    // 3. Location proximity / similarity (weight 0.15)
    totalWeight += 0.15;
    final lostLocTokens = _tokenize(lost.location);
    final foundLocTokens = _tokenize(found.location);
    if (lostLocTokens.isNotEmpty && foundLocTokens.isNotEmpty) {
      final locIntersection = lostLocTokens.intersection(foundLocTokens);
      if (locIntersection.isNotEmpty) {
        weightedScore += 0.15;
      }
    }

    // 4. Description tokens overlap (weight 0.15)
    totalWeight += 0.15;
    final lostDesc = _tokenize(lost.description);
    final foundDesc = _tokenize(found.description);
    if (lostDesc.isNotEmpty && foundDesc.isNotEmpty) {
      final descIntersection = lostDesc.intersection(foundDesc);
      if (descIntersection.isNotEmpty) {
        weightedScore += 0.15 * (descIntersection.length / descIntersection.union(foundDesc).length).clamp(0.2, 1.0);
      }
    }

    return (weightedScore / totalWeight).clamp(0.0, 1.0);
  }

  Set<String> _tokenize(String text) {
    final stopWords = {'the', 'a', 'an', 'and', 'or', 'in', 'on', 'at', 'with', 'my', 'of', 'for', 'to', 'it', 'is'};
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((t) => t.length > 2 && !stopWords.contains(t))
        .toSet();
  }

  String _generateMatchReason(Item lost, Item found, double score) {
    final pct = (score * 100).round();
    final commonWords = _tokenize(lost.title).intersection(_tokenize(found.title));
    if (commonWords.isNotEmpty) {
      return '$pct% match • Shared keywords: "${commonWords.take(3).join(', ')}"';
    }
    if (lost.location.isNotEmpty && lost.location.toLowerCase() == found.location.toLowerCase()) {
      return '$pct% match • Matched at exact same location (${lost.location})';
    }
    return '$pct% match • High title and description correlation';
  }

  // Claim submission for an item with multi-step verification questionnaire
  Future<OwnershipClaimRequest> submitClaim({
    required String itemId,
    String itemTitle = '',
    required String proofDescription,
    String? studentId,
    String lostLocation = '',
    String lostDate = '',
    String identifyingMarks = '',
    String internalContents = '',
  }) async {
    final email = await TokenStorage.getUserEmail() ?? '';
    final name = await TokenStorage.getUserName() ?? 'Campus User';

    OwnershipClaimRequest claim;
    try {
      final response = await _client.dio.post(
        ApiEndpoints.claims,
        data: {
          'itemId': itemId,
          'itemTitle': itemTitle,
          'proofDescription': proofDescription,
          'studentId': studentId,
          'lostLocation': lostLocation,
          'lostDate': lostDate,
          'identifyingMarks': identifyingMarks,
          'internalContents': internalContents,
          'claimantEmail': email,
          'claimantName': name,
        },
      );
      claim = OwnershipClaimRequest.fromJson(response.data as Map<String, dynamic>);
    } catch (_) {
      claim = OwnershipClaimRequest(
        id: 'claim_${DateTime.now().millisecondsSinceEpoch}',
        itemId: itemId,
        itemTitle: itemTitle,
        claimantEmail: email,
        claimantName: name,
        studentId: studentId,
        lostLocation: lostLocation,
        lostDate: lostDate,
        identifyingMarks: identifyingMarks,
        internalContents: internalContents,
        proofDescription: proofDescription,
        status: 'PENDING',
        createdAt: DateTime.now(),
      );
    }

    // Persist claim in ClaimsStorage so it shows in Security Dashboard and User Profile
    await ClaimsStorage.saveClaim(claim);

    // Also update item status locally to CLAIMED if currently OPEN
    try {
      await updateStatus(itemId, 'CLAIMED');
    } catch (_) {}

    _notifyClaim(itemId, itemTitle, proofDescription, email, name);
    return claim;
  }

  // Get all claims (Security Office or User)
  Future<List<OwnershipClaimRequest>> getClaims({String? itemId, String? status}) async {
    List<OwnershipClaimRequest> list = [];
    try {
      final response = await _client.dio.get(ApiEndpoints.claims);
      final data = response.data;
      if (data is List) {
        list = data.map((e) => OwnershipClaimRequest.fromJson(e as Map<String, dynamic>)).toList();
      } else if (data is Map && data.containsKey('claims')) {
        list = (data['claims'] as List).map((e) => OwnershipClaimRequest.fromJson(e as Map<String, dynamic>)).toList();
      } else if (data is Map && data.containsKey('content')) {
        list = (data['content'] as List).map((e) => OwnershipClaimRequest.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {
      list = await ClaimsStorage.getClaims();
    }

    if (itemId != null) {
      list = list.where((c) => c.itemId == itemId).toList();
    }
    if (status != null && status.isNotEmpty) {
      list = list.where((c) => c.status.toUpperCase() == status.toUpperCase()).toList();
    }
    return list;
  }

  // Security Office verifies claim
  Future<OwnershipClaimRequest> verifyClaim({
    required String claimId,
    required String itemId,
    required String reviewerNotes,
  }) async {
    try {
      await _client.dio.patch(
        '${ApiEndpoints.claims}/$claimId',
        data: {
          'status': 'VERIFIED',
          'reviewerNotes': reviewerNotes,
        },
      );
    } catch (_) {}

    await ClaimsStorage.updateClaimStatus(claimId, 'VERIFIED', reviewerNotes: reviewerNotes);
    final claim = await ClaimsStorage.getClaimById(claimId);

    // Send notifications to claimant
    await NotificationStorage.addNotification(
      AppNotification(
        id: 'verified_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Ownership Claim Verified!',
        message: 'Your claim for item #${claim?.itemTitle.isNotEmpty == true ? claim!.itemTitle : itemId} has been verified by the Security Office. Please visit the office with your Student ID for handover.',
        type: 'CLAIM_STATUS_UPDATED',
        relatedItemId: itemId,
        timestamp: DateTime.now(),
      ),
    );

    return claim ?? OwnershipClaimRequest(
      id: claimId,
      itemId: itemId,
      claimantEmail: '',
      claimantName: '',
      proofDescription: '',
      status: 'VERIFIED',
      createdAt: DateTime.now(),
      reviewerNotes: reviewerNotes,
    );
  }

  // Security Office rejects claim
  Future<OwnershipClaimRequest> rejectClaim({
    required String claimId,
    required String itemId,
    required String reason,
  }) async {
    try {
      await _client.dio.patch(
        '${ApiEndpoints.claims}/$claimId',
        data: {
          'status': 'REJECTED',
          'reviewerNotes': reason,
        },
      );
    } catch (_) {}

    await ClaimsStorage.updateClaimStatus(claimId, 'REJECTED', reviewerNotes: reason);
    final claim = await ClaimsStorage.getClaimById(claimId);

    // Reopen item if no other claims
    try {
      await updateStatus(itemId, 'OPEN');
    } catch (_) {}

    await NotificationStorage.addNotification(
      AppNotification(
        id: 'rejected_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Claim Decision: Insufficient Proof',
        message: 'Your claim for item #${claim?.itemTitle.isNotEmpty == true ? claim!.itemTitle : itemId} was not verified. Reason: $reason',
        type: 'CLAIM_STATUS_UPDATED',
        relatedItemId: itemId,
        timestamp: DateTime.now(),
      ),
    );

    return claim ?? OwnershipClaimRequest(
      id: claimId,
      itemId: itemId,
      claimantEmail: '',
      claimantName: '',
      proofDescription: '',
      status: 'REJECTED',
      createdAt: DateTime.now(),
      reviewerNotes: reason,
    );
  }

  // Security Office completes physical handover and closes cases
  Future<void> recordHandover({
    required String claimId,
    required String itemId,
    required String handoverNotes,
    String? lostReportId,
  }) async {
    try {
      await _client.dio.post(
        '${ApiEndpoints.claims}/$claimId/handover',
        data: {
          'status': 'COMPLETED',
          'handoverNotes': handoverNotes,
        },
      );
    } catch (_) {}

    await ClaimsStorage.updateClaimStatus(claimId, 'COMPLETED', handoverNotes: handoverNotes);

    // Update item status to CLOSED / RETURNED
    try {
      await updateStatus(itemId, 'CLOSED');
    } catch (_) {}

    if (lostReportId != null && lostReportId.isNotEmpty && lostReportId != itemId) {
      try {
        await updateStatus(lostReportId, 'CLOSED');
      } catch (_) {}
    }

    final claim = await ClaimsStorage.getClaimById(claimId);
    final title = claim?.itemTitle.isNotEmpty == true ? claim!.itemTitle : 'Item';

    await NotificationStorage.addNotification(
      AppNotification(
        id: 'handover_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Handover Completed • Case Closed',
        message: 'Physical handover for "$title" has been completed at the Security Office. Case is officially closed.',
        type: 'ITEM_RETURNED',
        relatedItemId: itemId,
        timestamp: DateTime.now(),
      ),
    );
  }

  void _notifyClaim(String itemId, String title, String proof, String email, String name) {
    NotificationStorage.addNotification(
      AppNotification(
        id: 'claim_notif_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Ownership Claim Submitted',
        message: 'Your claim request for "$title" has been submitted to the Security/Lost & Found Office for verification.',
        type: 'CLAIM_SUBMITTED',
        relatedItemId: itemId,
        timestamp: DateTime.now(),
      ),
    ).ignore();
  }
}
