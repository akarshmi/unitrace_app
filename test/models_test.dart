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
}
