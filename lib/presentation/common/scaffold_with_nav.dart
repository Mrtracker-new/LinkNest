import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linknest/presentation/common/app_actions.dart';
import 'package:linknest/presentation/feature_links/add_link_dialog.dart';

class ScaffoldWithNavBar extends ConsumerWidget {
  final Widget child;
  const ScaffoldWithNavBar({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (int idx) => _onItemTapped(idx, context),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.link),
            label: 'Links',
          ),
          NavigationDestination(
            icon: Icon(Icons.description_outlined),
            selectedIcon: Icon(Icons.description),
            label: 'Docs',
          ),
          NavigationDestination(
            icon: Icon(Icons.edit_note_outlined),
            selectedIcon: Icon(Icons.edit_note),
            label: 'Notes',
          ),
        ],
      ),
      // Context-aware FAB
      floatingActionButton: _buildContextAwareFAB(context, ref),
    );
  }

  Widget _buildContextAwareFAB(BuildContext context, WidgetRef ref) {
    final String location = GoRouterState.of(context).uri.path;
    
    // On Links page - only show Add Link
    if (location.startsWith('/links')) {
      return FloatingActionButton(
        onPressed: () async {
          await HapticFeedback.mediumImpact();
          _showAddLinkDialog(context, ref);
        },
        child: const Icon(Icons.add),
      );
    }
    
    // On Docs page - only show Add Document
    if (location.startsWith('/docs')) {
      return FloatingActionButton(
        onPressed: () async {
          await HapticFeedback.mediumImpact();
          _showAddDocDialog(context, ref);
        },
        child: const Icon(Icons.add),
      );
    }
    
    // On Notes page - only show Add Note
    if (location.startsWith('/notes')) {
      return FloatingActionButton(
        onPressed: () async {
          await HapticFeedback.mediumImpact();
          context.push('/notes/edit');
        },
        child: const Icon(Icons.add),
      );
    }
    
    // On Home or other pages - show menu with all options
    return FloatingActionButton(
      onPressed: () async {
        await HapticFeedback.mediumImpact();
        _showAddMenu(context, ref);
      },
      child: const Icon(Icons.add),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/links')) return 1;
    if (location.startsWith('/docs')) return 2;
    if (location.startsWith('/notes')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/links');
        break;
      case 2:
        context.go('/docs');
        break;
      case 3:
        context.go('/notes');
        break;
    }
  }

  void _showAddLinkDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const AddLinkDialog(),
    );
  }

  void _showAddDocDialog(BuildContext context, WidgetRef ref) {
    AppActions.pickAndCreateDocument(context, ref);
  }

  void _showAddMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true, 
      showDragHandle: true,
      builder: (context) => Container(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Add Link'),
              onTap: () {
                 Navigator.pop(context);
                 showDialog(context: context, builder: (context) => const AddLinkDialog());
              },
            ),
             ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Add Document'),
              onTap: () {
                 Navigator.pop(context);
                 AppActions.pickAndCreateDocument(context, ref);
              },
            ),
             ListTile(
              leading: const Icon(Icons.edit_note),
              title: const Text('Add Note'),
              onTap: () {
                 Navigator.pop(context);
                 context.push('/notes/edit');
              },
            ),
          ],
        ),
      ),
    );
  }
}
