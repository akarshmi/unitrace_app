import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/match_result.dart';

class ClaimsStorage {
  ClaimsStorage._();
  static const _storage = FlutterSecureStorage();
  static const _claimsKey = 'unitrace_claims_store_v1';

  static Future<List<OwnershipClaimRequest>> getClaims() async {
    final raw = await _storage.read(key: _claimsKey);
    if (raw == null || raw.trim().isEmpty) {
      return [];
    }
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => OwnershipClaimRequest.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveClaim(OwnershipClaimRequest claim) async {
    final current = await getClaims();
    final index = current.indexWhere((c) => c.id == claim.id);
    if (index >= 0) {
      current[index] = claim;
    } else {
      current.insert(0, claim);
    }
    final raw = jsonEncode(current.map((c) => c.toJson()).toList());
    await _storage.write(key: _claimsKey, value: raw);
  }

  static Future<OwnershipClaimRequest?> getClaimById(String id) async {
    final list = await getClaims();
    try {
      return list.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  static Future<List<OwnershipClaimRequest>> getClaimsByItemId(String itemId) async {
    final list = await getClaims();
    return list.where((c) => c.itemId == itemId).toList();
  }

  static Future<List<OwnershipClaimRequest>> getMyClaims(String claimantEmail) async {
    final list = await getClaims();
    if (claimantEmail.trim().isEmpty) return list;
    return list.where((c) => c.claimantEmail.toLowerCase() == claimantEmail.toLowerCase()).toList();
  }

  static Future<void> updateClaimStatus(String claimId, String status, {String? reviewerNotes, String? handoverNotes}) async {
    final current = await getClaims();
    final index = current.indexWhere((c) => c.id == claimId);
    if (index >= 0) {
      current[index] = current[index].copyWith(
        status: status,
        reviewerNotes: reviewerNotes,
        handoverNotes: handoverNotes,
      );
      final raw = jsonEncode(current.map((c) => c.toJson()).toList());
      await _storage.write(key: _claimsKey, value: raw);
    }
  }
}
