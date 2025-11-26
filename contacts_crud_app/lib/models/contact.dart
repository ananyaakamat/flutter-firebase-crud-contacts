import 'package:cloud_firestore/cloud_firestore.dart';

class Contact {
  final String id;
  final String name;
  final String contactNumber;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final bool pending; // indicates if this document has local pending writes

  Contact({
    required this.id,
    required this.name,
    required this.contactNumber,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.pending = false,
  });

  // Factory constructor to create Contact from Firestore document
  factory Contact.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    // Safely handle missing timestamps when using local writes
    DateTime created = DateTime.now();
    DateTime updated = DateTime.now();
    try {
      if (data['createdAt'] is Timestamp) {
        created = (data['createdAt'] as Timestamp).toDate();
      }
      if (data['updatedAt'] is Timestamp) {
        updated = (data['updatedAt'] as Timestamp).toDate();
      }
    } catch (_) {}

    return Contact(
      id: doc.id,
      name: data['name'] ?? '',
      contactNumber: data['contactNumber'] ?? '',
      createdAt: created,
      updatedAt: updated,
      createdBy: data['createdBy'] ?? 'anonymous',
      pending: doc.metadata.hasPendingWrites,
    );
  }

  // Convert Contact to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'contactNumber': contactNumber,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
    };
  }

  // Create a copy of Contact with updated fields
  Contact copyWith({
    String? id,
    String? name,
    String? contactNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      contactNumber: contactNumber ?? this.contactNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  @override
  String toString() {
    return 'Contact{id: $id, name: $name, contactNumber: $contactNumber, createdAt: $createdAt, updatedAt: $updatedAt, createdBy: $createdBy}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Contact &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          contactNumber == other.contactNumber &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          createdBy == other.createdBy;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      contactNumber.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      createdBy.hashCode;
}

// Validation utilities for Contact data
class ContactValidator {
  // Validate name: letters and spaces only, max 40 characters
  static bool isValidName(String name) {
    if (name.isEmpty || name.length > 40) return false;
    return RegExp(r'^[A-Za-z ]+$').hasMatch(name);
  }

  // Validate contact number: exactly 10 digits
  static bool isValidContactNumber(String contactNumber) {
    if (contactNumber.length != 10) return false;
    return RegExp(r'^[0-9]{10}$').hasMatch(contactNumber);
  }

  // Get name validation error message
  static String? getNameErrorMessage(String name) {
    if (name.isEmpty) return 'Name is required';
    if (name.length > 40) return 'Max 40 characters';
    if (!RegExp(r'^[A-Za-z ]+$').hasMatch(name)) {
      return 'Use only letters and spaces';
    }
    return null;
  }

  // Get contact number validation error message
  static String? getContactNumberErrorMessage(String contactNumber) {
    if (contactNumber.isEmpty) return 'Contact number is required';
    if (contactNumber.length != 10) return 'Enter exactly 10 digits';
    if (!RegExp(r'^[0-9]{10}$').hasMatch(contactNumber)) {
      return 'Enter exactly 10 digits';
    }
    return null;
  }
}
