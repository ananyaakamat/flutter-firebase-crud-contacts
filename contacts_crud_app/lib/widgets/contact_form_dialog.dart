import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/contact.dart';
import '../providers/contact_provider.dart';

class ContactFormDialog extends StatefulWidget {
  final Contact? contact; // If editing an existing contact

  const ContactFormDialog({
    super.key,
    this.contact,
  });

  @override
  State<ContactFormDialog> createState() => _ContactFormDialogState();
}

class _ContactFormDialogState extends State<ContactFormDialog> {
  late TextEditingController _nameController;
  late TextEditingController _numberController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact?.name ?? '');
    _numberController =
        TextEditingController(text: widget.contact?.contactNumber ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.contact != null;

  bool get _hasInput {
    return _nameController.text.trim().isNotEmpty ||
        _numberController.text.trim().isNotEmpty;
  }

  Future<void> _saveContact() async {
    final name = _nameController.text.trim();
    final number = _numberController.text.trim();

    // Validate fields
    final nameError = ContactValidator.getNameErrorMessage(name);
    final numberError = ContactValidator.getContactNumberErrorMessage(number);

    if (nameError != null || numberError != null) {
      // Show validation errors
      String errorMessage = 'Please fix the following errors:\n';
      if (nameError != null) errorMessage += '• $nameError\n';
      if (numberError != null) errorMessage += '• $numberError';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final provider = context.read<ContactProvider>();

    bool success;
    if (_isEditing) {
      success = await provider.updateContact(widget.contact!.id, name, number);
    } else {
      success = await provider.createContact(name, number);
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing
                ? 'Contact updated successfully!'
                : 'Contact created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Operation failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive dialog sizing
        final screenWidth = MediaQuery.of(context).size.width;
        final isLargeScreen = screenWidth > 800;
        final isTablet = screenWidth > 600 && screenWidth <= 800;

        double dialogWidth;
        if (isLargeScreen) {
          dialogWidth = 500; // Larger dialog for desktop
        } else if (isTablet) {
          dialogWidth = 450; // Medium size for tablets
        } else {
          dialogWidth = screenWidth * 0.9; // 90% of screen width on mobile
        }

        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: dialogWidth,
            constraints: BoxConstraints(
              maxWidth: dialogWidth,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            padding: EdgeInsets.all(isLargeScreen ? 32 : 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                Text(
                  _isEditing ? 'Edit Contact' : 'Create New Contact',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isLargeScreen ? 32 : 24),

                // Form
                Flexible(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Name field
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Name *',
                              hintText: 'Enter full name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.person),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: isLargeScreen ? 16 : 14,
                              ),
                            ),
                            keyboardType: TextInputType.name,
                            textCapitalization: TextCapitalization.words,
                            onChanged: (value) {
                              setState(() {}); // Update Save button state
                            },
                          ),
                          SizedBox(height: isLargeScreen ? 20 : 16),

                          // Contact number field
                          TextFormField(
                            controller: _numberController,
                            decoration: InputDecoration(
                              labelText: 'Contact Number *',
                              hintText: 'Enter 10-digit number',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.phone),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: isLargeScreen ? 16 : 14,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            maxLength: 10,
                            onChanged: (value) {
                              setState(() {}); // Update Save button state
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: isLargeScreen ? 32 : 24),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Cancel button
                    TextButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    SizedBox(width: isLargeScreen ? 16 : 12),

                    // Save button
                    ElevatedButton(
                      onPressed:
                          (_isLoading || !_hasInput) ? null : _saveContact,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: isLargeScreen ? 24 : 20,
                          vertical: isLargeScreen ? 14 : 12,
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_isEditing ? 'Update' : 'Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Helper function to show the contact form dialog
Future<void> showContactFormDialog(BuildContext context, {Contact? contact}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return ContactFormDialog(contact: contact);
    },
  );
}
