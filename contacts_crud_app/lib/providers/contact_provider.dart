import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../services/contact_service.dart';

class ContactProvider extends ChangeNotifier {
  final ContactService _contactService = ContactService();

  List<Contact> _contacts = [];
  List<Contact> _filteredContacts = [];
  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Contact> get contacts => _filteredContacts;
  List<Contact> get allContacts => _contacts;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasContacts => _contacts.isNotEmpty;

  // Initialize and listen to contacts stream
  void init() {
    _listenToContacts();
  }

  void _listenToContacts() {
    _contactService.getContactsStream().listen(
      (contacts) {
        _contacts = contacts;
        _filterContacts();
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = 'Failed to load contacts: $error';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Search functionality
  void search(String query) {
    _searchQuery = query.trim();
    _filterContacts();
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _filterContacts();
    notifyListeners();
  }

  void _filterContacts() {
    if (_searchQuery.isEmpty) {
      _filteredContacts = List.from(_contacts);
    } else {
      final lowerQuery = _searchQuery.toLowerCase();
      _filteredContacts = _contacts.where((contact) {
        final name = contact.name.toLowerCase();
        final number = contact.contactNumber;
        return name.contains(lowerQuery) || number.contains(_searchQuery);
      }).toList();
    }
  }

  // CRUD operations
  Future<bool> createContact(String name, String contactNumber) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Validate data
      final nameError = ContactValidator.getNameErrorMessage(name);
      if (nameError != null) {
        _error = nameError;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final numberError =
          ContactValidator.getContactNumberErrorMessage(contactNumber);
      if (numberError != null) {
        _error = numberError;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Check for duplicates
      final isDuplicate =
          await _contactService.isContactDuplicate(name, contactNumber);
      if (isDuplicate) {
        _error = 'A contact with this name or number already exists';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await _contactService.createContact(name, contactNumber);
      _isLoading = false;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to create contact: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateContact(
      String id, String name, String contactNumber) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Validate data
      final nameError = ContactValidator.getNameErrorMessage(name);
      if (nameError != null) {
        _error = nameError;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final numberError =
          ContactValidator.getContactNumberErrorMessage(contactNumber);
      if (numberError != null) {
        _error = numberError;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Check for duplicates (excluding current contact)
      final isDuplicate = await _contactService
          .isContactDuplicate(name, contactNumber, excludeId: id);
      if (isDuplicate) {
        _error = 'A contact with this name or number already exists';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await _contactService.updateContact(id, name, contactNumber);
      _isLoading = false;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update contact: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteContact(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _contactService.deleteContact(id);
      _isLoading = false;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete contact: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get contact by ID
  Contact? getContactById(String id) {
    try {
      return _contacts.firstWhere((contact) => contact.id == id);
    } catch (e) {
      return null;
    }
  }

  // Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
