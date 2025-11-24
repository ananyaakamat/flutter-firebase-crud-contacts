import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/contact.dart';
import '../providers/contact_provider.dart';
import 'contact_form_dialog.dart';

class ContactListWidget extends StatelessWidget {
  const ContactListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ContactProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && !provider.hasContacts) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!provider.hasContacts) {
          return const Center(
            child: EmptyStateWidget(),
          );
        }

        final contacts = provider.contacts;

        // Responsive layout: table for wide screens, list for narrow screens
        return LayoutBuilder(
          builder: (context, constraints) {
            final isWideScreen = constraints.maxWidth > 600;

            if (isWideScreen) {
              return ContactTable(contacts: contacts);
            } else {
              return ContactList(contacts: contacts);
            }
          },
        );
      },
    );
  }
}

// Empty state widget shown when no contacts exist
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.contact_page_outlined,
          size: 64,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        ),
        const SizedBox(height: 16),
        Text(
          'No Contacts Yet',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Start by creating your first contact',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
        ),
      ],
    );
  }
}

// Table layout for wide screens (web/desktop)
class ContactTable extends StatelessWidget {
  final List<Contact> contacts;

  const ContactTable({super.key, required this.contacts});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.contacts,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Contacts (${contacts.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
          ),
          // Scrollable table content
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowHeight: 60,
                  dataRowMinHeight: 60,
                  dataRowMaxHeight: 60,
                  columnSpacing: 24,
                  headingTextStyle:
                      Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                  columns: const [
                    DataColumn(
                      label: Text('Name'),
                      tooltip: 'Contact name',
                    ),
                    DataColumn(
                      label: Text('Contact Number'),
                      tooltip: 'Phone number',
                    ),
                    DataColumn(
                      label: Text('Created At'),
                      tooltip: 'Date created',
                    ),
                    DataColumn(
                      label: Text('Actions'),
                      tooltip: 'Edit or delete contact',
                    ),
                  ],
                  rows: contacts
                      .map((contact) => DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  contact.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              DataCell(
                                Text(contact.contactNumber),
                              ),
                              DataCell(
                                Text(
                                  DateFormat('MMM dd, yyyy')
                                      .format(contact.createdAt),
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.7),
                                  ),
                                ),
                              ),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () =>
                                          _editContact(context, contact),
                                      tooltip: 'Edit contact',
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red[700],
                                      ),
                                      onPressed: () =>
                                          _deleteContact(context, contact),
                                      tooltip: 'Delete contact',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ))
                      .toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editContact(BuildContext context, Contact contact) {
    showContactFormDialog(context, contact: contact);
  }

  void _deleteContact(BuildContext context, Contact contact) {
    showDialog<bool>(
      context: context,
      builder: (context) => DeleteConfirmationDialog(contact: contact),
    );
  }
}

// List layout for mobile screens
class ContactList extends StatelessWidget {
  final List<Contact> contacts;

  const ContactList({super.key, required this.contacts});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: contacts.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return ContactCard(contact: contact);
      },
    );
  }
}

// Contact card for mobile view
class ContactCard extends StatelessWidget {
  final Contact contact;

  const ContactCard({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          contact.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.phone, size: 16),
                const SizedBox(width: 4),
                Text(contact.contactNumber),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'Created ${DateFormat('MMM dd, yyyy').format(contact.createdAt)}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editContact(context),
              tooltip: 'Edit',
            ),
            IconButton(
              icon: Icon(
                Icons.delete,
                color: Colors.red[700],
              ),
              onPressed: () => _deleteContact(context),
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }

  void _editContact(BuildContext context) {
    showContactFormDialog(context, contact: contact);
  }

  void _deleteContact(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (context) => DeleteConfirmationDialog(contact: contact),
    );
  }
}

// Delete confirmation dialog
class DeleteConfirmationDialog extends StatefulWidget {
  final Contact contact;

  const DeleteConfirmationDialog({super.key, required this.contact});

  @override
  State<DeleteConfirmationDialog> createState() =>
      _DeleteConfirmationDialogState();
}

class _DeleteConfirmationDialogState extends State<DeleteConfirmationDialog> {
  bool _isDeleting = false;

  Future<void> _confirmDelete() async {
    setState(() {
      _isDeleting = true;
    });

    final provider = context.read<ContactProvider>();
    final success = await provider.deleteContact(widget.contact.id);

    if (mounted) {
      Navigator.of(context).pop(success);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Contact "${widget.contact.name}" deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to delete contact'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Contact'),
      content: Text(
        'Are you sure you want to delete "${widget.contact.name}"? This action cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed:
              _isDeleting ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isDeleting ? null : _confirmDelete,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: _isDeleting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Delete'),
        ),
      ],
    );
  }
}
