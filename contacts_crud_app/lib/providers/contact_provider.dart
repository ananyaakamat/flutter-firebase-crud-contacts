import 'dart:async';

import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../services/contact_service.dart';
import '../services/network_service.dart';

class ContactProvider extends ChangeNotifier {
  final ContactService _contactService = ContactService();

  List<Contact> _contacts = [];
  List<Contact> _filteredContacts = [];
  String _searchQuery = '';
  bool _isLoading = true; // Start with true to prevent flicker
  String? _error;
  bool _hasInitialized = false;
  bool _isOnline = true;
  StreamSubscription<bool>? _networkSubscription;

  // Getters
  List<Contact> get contacts => _filteredContacts;
  List<Contact> get allContacts => _contacts;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasContacts => _contacts.isNotEmpty;
  bool get hasInitialized => _hasInitialized;
  bool get isOnline => _isOnline;

  // Initialize and listen to contacts stream
  void init() {
    _listenToContacts();
    _subscribeToNetworkStatus();
  }

  // Subscribe to network status changes
  void _subscribeToNetworkStatus() {
    _networkSubscription = NetworkService.onStatusChanged.listen((isOnline) {
      _isOnline = isOnline;
      notifyListeners();
    });
  }

  void _listenToContacts() {
    _contactService.getContactsStream().listen(
      (contacts) {
        _contacts = contacts;
        _filterContacts();
        _isLoading = false;
        _error = null;
        _hasInitialized = true;
        notifyListeners();
      },
      onError: (error) {
        _error = 'Failed to load contacts: $error';
        _isLoading = false;
        _hasInitialized = true;
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

      // Check for duplicates only when online to avoid blocking offline operations
      if (_isOnline) {
        try {
          final isDuplicate =
              await _contactService.isContactDuplicate(name, contactNumber);
          if (isDuplicate) {
            _error = 'A contact with this name or number already exists';
            _isLoading = false;
            notifyListeners();
            return false;
          }
        } catch (e) {
          // If duplicate check fails (e.g., offline), proceed anyway
          // The server will handle duplicates when syncing
        }
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

      // Check for duplicates only when online to avoid blocking offline operations
      if (_isOnline) {
        try {
          final isDuplicate = await _contactService
              .isContactDuplicate(name, contactNumber, excludeId: id);
          if (isDuplicate) {
            _error = 'A contact with this name or number already exists';
            _isLoading = false;
            notifyListeners();
            return false;
          }
        } catch (e) {
          // If duplicate check fails (e.g., offline), proceed anyway
          // The server will handle duplicates when syncing
        }
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
      // For offline operations, still consider it successful
      // as the delete will be queued locally
      if (!_isOnline) {
        return true;
      }
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

  @override
  void dispose() {
    _networkSubscription?.cancel();
    super.dispose();
  }
}
