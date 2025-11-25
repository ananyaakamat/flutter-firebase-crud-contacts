import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/contact_provider.dart';
import '../widgets/contact_form_dialog.dart';
import '../widgets/contact_list_widget.dart';
import '../widgets/search_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize the contact provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContactProvider>().init();
    });
  }

  void _createNewContact() {
    showContactFormDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/icons/crud_icon.png',
              width: 32,
              height: 32,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.contacts, size: 32);
              },
            ),
            const SizedBox(width: 12),
            const Text('CRUD Firebase'),
          ],
        ),
        elevation: 2,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withOpacity(0.1),
        actions: [
          Consumer<ContactProvider>(
            builder: (context, provider, child) {
              if (provider.hasContacts) {
                return IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _createNewContact,
                  tooltip: 'Add new contact',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search widget (only shown when there are contacts)
          const SearchWidget(),

          // Search results header
          const SearchResultsHeader(),

          // Main content area
          Expanded(
            child: Consumer<ContactProvider>(
              builder: (context, provider, child) {
                // Show loading spinner during initial load
                if (!provider.hasInitialized) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (provider.error != null && !provider.hasContacts) {
                  return ErrorWidget(
                    error: provider.error!,
                    onRetry: () {
                      provider.clearError();
                      provider.init();
                    },
                  );
                }

                return const ContactListWidget();
              },
            ),
          ),
        ],
      ),

      // Floating Action Button (only shown when no contacts exist or as primary action)
      floatingActionButton: Consumer<ContactProvider>(
        builder: (context, provider, child) {
          // Don't show FAB during initial load
          if (!provider.hasInitialized) {
            return const SizedBox.shrink();
          }

          // Show FAB prominently when no contacts exist
          if (!provider.hasContacts) {
            return FloatingActionButton.extended(
              onPressed: _createNewContact,
              icon: const Icon(Icons.add),
              label: const Text('Create Contact'),
              heroTag: 'create_contact_fab',
            );
          }

          // Show regular FAB when contacts exist
          return FloatingActionButton(
            onPressed: _createNewContact,
            tooltip: 'Create new contact',
            heroTag: 'create_contact_fab',
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }
}

// Error widget for handling network errors or other issues
class ErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const ErrorWidget({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// Search results header widget to show count and clear option
class SearchResultsHeader extends StatelessWidget {
  const SearchResultsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ContactProvider>(
      builder: (context, provider, child) {
        if (provider.searchQuery.isEmpty) {
          return const SizedBox.shrink();
        }

        final resultCount = provider.contacts.length;
        final totalCount = provider.allContacts.length;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Found $resultCount of $totalCount contacts for "${provider.searchQuery}"',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
              TextButton(
                onPressed: () => provider.clearSearch(),
                child: const Text('Clear'),
              ),
            ],
          ),
        );
      },
    );
  }
}
