import 'package:flutter_test/flutter_test.dart';
import 'package:unitrace/features/auth/auth.dart';
import 'package:unitrace/features/items/items.dart';

void main() {
  group('Item Model Tests', () {
    test('Correctly deserializes LOST item JSON', () {
      final json = {
        'id': 'item-101',
        'type': 'LOST',
        'title': 'Blue Backpack',
        'description': 'Left near Library 2nd floor',
        'status': 'OPEN',
        'location': 'Library',
        'category': 'BAGS',
      };

      final item = Item.fromJson(json);
      expect(item.id, 'item-101');
      expect(item.type, 'LOST');
      expect(item.isLost, isTrue);
      expect(item.isFound, isFalse);
      expect(item.isOpen, isTrue);
      expect(item.isClosed, isFalse);
    });

    test('Correctly deserializes FOUND item JSON with status CLAIMED', () {
      final json = {
        'id': 'item-202',
        'type': 'FOUND',
        'title': 'Student ID Card',
        'description': 'Found in Cafeteria',
        'status': 'CLAIMED',
        'location': 'Cafeteria',
      };

      final item = Item.fromJson(json);
      expect(item.id, 'item-202');
      expect(item.type, 'FOUND');
      expect(item.isFound, isTrue);
      expect(item.isClaimed, isTrue);
    });
  });

  group('User Model Tests', () {
    test('Correctly identifies Student and Moderator roles', () {
      final student = User.fromJson({
        'id': 'usr-1',
        'uniEmail': 'student@campus.edu',
        'role': 'STUDENT',
        'firstName': 'Alex',
        'lastName': 'Rivers',
      });

      expect(student.isStudent, isTrue);
      expect(student.isModerator, isFalse);

      final moderator = User.fromJson({
        'id': 'usr-2',
        'uniEmail': 'staff@campus.edu',
        'role': 'MODERATOR',
        'firstName': 'Jordan',
      });

      expect(moderator.isStudent, isFalse);
      expect(moderator.isModerator, isTrue);
    });
  });

  group('Matching and Claims Tests', () {
    test('MatchCandidate serializes and deserializes correctly', () {
      final lost = Item(
        id: 'lost-1',
        title: 'MacBook Pro 14',
        type: 'LOST',
        status: 'OPEN',
        category: 'ELECTRONICS',
        location: 'Library',
        description: 'Silver 14-inch laptop left in study cubicle',
      );
      final found = Item(
        id: 'found-1',
        title: 'Apple MacBook',
        type: 'FOUND',
        status: 'OPEN',
        category: 'ELECTRONICS',
        location: 'Library 3rd Floor',
        description: 'Found on 3rd floor desk with charger',
      );

      final candidate = MatchCandidate(
        id: 'match-1',
        lostItem: lost,
        foundItem: found,
        score: 0.85,
        reason: 'Title and location match closely',
        matchedAt: DateTime.parse('2026-09-18T10:00:00Z'),
      );

      expect(candidate.score, 0.85);
      expect(candidate.scorePercentage, 85);
      expect(candidate.reason, contains('match'));

      final json = candidate.toJson();
      final revived = MatchCandidate.fromJson(json);
      expect(revived.lostItem.id, 'lost-1');
      expect(revived.foundItem.id, 'found-1');
      expect(revived.score, 0.85);
    });

    test('OwnershipClaimRequest serializes and deserializes correctly', () {
      final claim = OwnershipClaimRequest(
        id: 'claim-1',
        itemId: 'item-99',
        claimantEmail: 'student@campus.edu',
        claimantName: 'Sam Student',
        proofDescription: 'Dent on bottom and sticker with my initials SS',
        createdAt: DateTime.parse('2026-09-18T10:00:00Z'),
        status: 'PENDING',
      );

      expect(claim.status, 'PENDING');
      final json = claim.toJson();
      final revived = OwnershipClaimRequest.fromJson(json);
      expect(revived.id, 'claim-1');
      expect(revived.proofDescription, contains('Dent on bottom'));
      expect(revived.claimantEmail, 'student@campus.edu');
    });

    test('AppNotification serializes and deserializes correctly', () {
      final notif = AppNotification(
        id: 'notif-1',
        title: 'Potential Match Found',
        message: 'A match was discovered for your lost item',
        timestamp: DateTime.parse('2026-09-18T10:00:00Z'),
        type: 'MATCH_FOUND',
        relatedItemId: 'lost-1',
        isRead: false,
      );

      expect(notif.isRead, isFalse);
      expect(notif.type, 'MATCH_FOUND');

      final json = notif.toJson();
      final revived = AppNotification.fromJson(json);
      expect(revived.id, 'notif-1');
      expect(revived.title, 'Potential Match Found');
      expect(revived.isRead, isFalse);
    });
  });
}
