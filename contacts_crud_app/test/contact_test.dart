import 'package:flutter_test/flutter_test.dart';
import 'package:contacts_crud_app/models/contact.dart';

void main() {
  group('ContactValidator', () {
    group('Name Validation', () {
      test('should accept valid names', () {
        expect(ContactValidator.isValidName('John Doe'), isTrue);
        expect(ContactValidator.isValidName('Alice Smith'), isTrue);
        expect(ContactValidator.isValidName('Bob'), isTrue);
        expect(ContactValidator.isValidName('Mary Jane Watson'), isTrue);
      });

      test('should reject invalid names', () {
        expect(ContactValidator.isValidName(''), isFalse);
        expect(ContactValidator.isValidName('John123'), isFalse);
        expect(ContactValidator.isValidName('John@Doe'), isFalse);
        expect(ContactValidator.isValidName('John.Doe'), isFalse);
        expect(
            ContactValidator.isValidName(
                'A very very very very very long name that exceeds forty characters'),
            isFalse);
      });

      test('should provide correct error messages', () {
        expect(ContactValidator.getNameErrorMessage(''),
            equals('Name is required'));
        expect(ContactValidator.getNameErrorMessage('John123'),
            equals('Use only letters and spaces'));
        expect(
            ContactValidator.getNameErrorMessage(
                'A very very very very very long name that exceeds forty characters'),
            equals('Max 40 characters'));
        expect(ContactValidator.getNameErrorMessage('John Doe'), isNull);
      });
    });

    group('Contact Number Validation', () {
      test('should accept valid contact numbers', () {
        expect(ContactValidator.isValidContactNumber('1234567890'), isTrue);
        expect(ContactValidator.isValidContactNumber('9876543210'), isTrue);
        expect(ContactValidator.isValidContactNumber('0000000000'), isTrue);
      });

      test('should reject invalid contact numbers', () {
        expect(ContactValidator.isValidContactNumber(''), isFalse);
        expect(ContactValidator.isValidContactNumber('123456789'),
            isFalse); // 9 digits
        expect(ContactValidator.isValidContactNumber('12345678901'),
            isFalse); // 11 digits
        expect(ContactValidator.isValidContactNumber('123456789a'),
            isFalse); // contains letter
        expect(ContactValidator.isValidContactNumber('123-456-7890'),
            isFalse); // contains hyphens
        expect(ContactValidator.isValidContactNumber('+1234567890'),
            isFalse); // contains +
      });

      test('should provide correct error messages', () {
        expect(ContactValidator.getContactNumberErrorMessage(''),
            equals('Contact number is required'));
        expect(ContactValidator.getContactNumberErrorMessage('123456789'),
            equals('Enter exactly 10 digits'));
        expect(ContactValidator.getContactNumberErrorMessage('12345678901'),
            equals('Enter exactly 10 digits'));
        expect(ContactValidator.getContactNumberErrorMessage('123456789a'),
            equals('Enter exactly 10 digits'));
        expect(ContactValidator.getContactNumberErrorMessage('1234567890'),
            isNull);
      });
    });
  });

  group('Contact Model', () {
    test('should create contact from valid data', () {
      final now = DateTime.now();
      final contact = Contact(
        id: 'test-id',
        name: 'John Doe',
        contactNumber: '1234567890',
        createdAt: now,
        updatedAt: now,
        createdBy: 'test-user',
      );

      expect(contact.id, equals('test-id'));
      expect(contact.name, equals('John Doe'));
      expect(contact.contactNumber, equals('1234567890'));
      expect(contact.createdAt, equals(now));
      expect(contact.updatedAt, equals(now));
      expect(contact.createdBy, equals('test-user'));
    });

    test('should create copy with updated fields', () {
      final now = DateTime.now();
      final original = Contact(
        id: 'test-id',
        name: 'John Doe',
        contactNumber: '1234567890',
        createdAt: now,
        updatedAt: now,
        createdBy: 'test-user',
      );

      final later = now.add(const Duration(minutes: 5));
      final updated = original.copyWith(
        name: 'Jane Doe',
        contactNumber: '0987654321',
        updatedAt: later,
      );

      expect(updated.id, equals('test-id')); // unchanged
      expect(updated.name, equals('Jane Doe')); // updated
      expect(updated.contactNumber, equals('0987654321')); // updated
      expect(updated.createdAt, equals(now)); // unchanged
      expect(updated.updatedAt, equals(later)); // updated
      expect(updated.createdBy, equals('test-user')); // unchanged
    });

    test('should convert to firestore format', () {
      final now = DateTime.now();
      final contact = Contact(
        id: 'test-id',
        name: 'John Doe',
        contactNumber: '1234567890',
        createdAt: now,
        updatedAt: now,
        createdBy: 'test-user',
      );

      final firestore = contact.toFirestore();

      expect(firestore['name'], equals('John Doe'));
      expect(firestore['contactNumber'], equals('1234567890'));
      expect(firestore['createdBy'], equals('test-user'));
      expect(firestore.containsKey('createdAt'), isTrue);
      expect(firestore.containsKey('updatedAt'), isTrue);
      expect(firestore.containsKey('id'),
          isFalse); // ID not included in document data
    });

    test('should handle equality correctly', () {
      final now = DateTime.now();
      final contact1 = Contact(
        id: 'test-id',
        name: 'John Doe',
        contactNumber: '1234567890',
        createdAt: now,
        updatedAt: now,
        createdBy: 'test-user',
      );

      final contact2 = Contact(
        id: 'test-id',
        name: 'John Doe',
        contactNumber: '1234567890',
        createdAt: now,
        updatedAt: now,
        createdBy: 'test-user',
      );

      final contact3 = Contact(
        id: 'different-id',
        name: 'John Doe',
        contactNumber: '1234567890',
        createdAt: now,
        updatedAt: now,
        createdBy: 'test-user',
      );

      expect(contact1 == contact2, isTrue);
      expect(contact1 == contact3, isFalse);
      expect(contact1.hashCode == contact2.hashCode, isTrue);
    });
  });
}
