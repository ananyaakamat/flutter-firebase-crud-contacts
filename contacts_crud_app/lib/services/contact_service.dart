import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/contact.dart';

class ContactService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'contacts';

  // Get contacts collection reference
  CollectionReference get _contactsCollection =>
      _firestore.collection(_collection);

  // Create a new contact
  Future<void> createContact(String name, String contactNumber) async {
    try {
      final contactData = {
        'name': name.trim(),
        'contactNumber': contactNumber.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'createdBy': 'anonymous', // Can be updated when auth is added
      };

      // Fire and forget - queues locally when offline
      _contactsCollection.add(contactData);
    } catch (e) {
      // Silently ignore errors - offline persistence handles this
    }
  }

  // Update an existing contact
  Future<void> updateContact(
      String id, String name, String contactNumber) async {
    try {
      // Fire and forget - queues locally when offline
      _contactsCollection.doc(id).update({
        'name': name.trim(),
        'contactNumber': contactNumber.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Silently ignore errors - offline persistence handles this
    }
  }

  // Delete a contact
  Future<void> deleteContact(String id) async {
    try {
      // Fire and forget - queues locally when offline
      _contactsCollection.doc(id).delete();
    } catch (e) {
      // Silently ignore errors - offline persistence handles this
    }
  }

  // Get a single contact by ID
  Future<Contact?> getContact(String id) async {
    try {
      final doc = await _contactsCollection.doc(id).get();
      if (doc.exists) {
        return Contact.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get contact: $e');
    }
  }

  // Stream of all contacts (real-time updates)
  Stream<List<Contact>> getContactsStream() {
    return _contactsCollection
        .orderBy('createdAt', descending: true)
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) =>
            snapshot.docs.map((doc) => Contact.fromFirestore(doc)).toList());
  }

  // Search contacts by name or contact number
  Stream<List<Contact>> searchContactsStream(String query) {
    if (query.isEmpty) {
      return getContactsStream();
    }

    // For simple prefix search on name field
    final lowerCaseQuery = query.toLowerCase();

    return _contactsCollection
        .orderBy('name')
        .startAt([lowerCaseQuery])
        .endAt(['$lowerCaseQuery\uf8ff'])
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) {
          // Also filter by contact number on client side for more comprehensive search
          final contacts =
              snapshot.docs.map((doc) => Contact.fromFirestore(doc)).toList();

          return contacts.where((contact) {
            final name = contact.name.toLowerCase();
            final number = contact.contactNumber;
            return name.contains(lowerCaseQuery) || number.contains(query);
          }).toList();
        });
  }

  // Get all contacts as a future (for one-time fetch)
  Future<List<Contact>> getAllContacts() async {
    try {
      final snapshot = await _contactsCollection
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => Contact.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get contacts: $e');
    }
  }

  // Enable offline persistence (should be called once in app initialization)
  static Future<void> enableOfflinePersistence() async {
    try {
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
      );
    } catch (e) {
      // Persistence might already be enabled or not supported in web
      // Using debugPrint instead of print for production safety
      debugPrint('Offline persistence error: $e');
    }
  }

  // Check if contact with same name or number already exists
  Future<bool> isContactDuplicate(String name, String contactNumber,
      {String? excludeId}) async {
    try {
      final nameQuery =
          await _contactsCollection.where('name', isEqualTo: name.trim()).get();

      final numberQuery = await _contactsCollection
          .where('contactNumber', isEqualTo: contactNumber.trim())
          .get();

      // Check if any documents match (excluding the current contact if editing)
      final nameMatches = nameQuery.docs.where((doc) => doc.id != excludeId);
      final numberMatches =
          numberQuery.docs.where((doc) => doc.id != excludeId);

      return nameMatches.isNotEmpty || numberMatches.isNotEmpty;
    } catch (e) {
      // If check fails (e.g., offline mode), assume no duplicate to allow operation
      // Server-side validation will handle duplicates during sync
      debugPrint('Duplicate check failed (likely offline): $e');
      return false;
    }
  }
}
