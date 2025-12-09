import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:linknest/domain/entities/item.dart';
import 'package:linknest/presentation/providers/providers.dart';
import 'package:linknest/presentation/feature_links/add_link_dialog.dart';
import 'package:linknest/presentation/feature_links/edit_link_dialog.dart';
import 'package:linknest/presentation/common/app_actions.dart';

class LinksScreen extends ConsumerStatefulWidget {
  const LinksScreen({super.key});

  @override
  ConsumerState<LinksScreen> createState() => _LinksScreenState();
}

enum SortOption { date, name, favorites }

class _LinksScreenState extends ConsumerState<LinksScreen> {
  SortOption _sortBy = SortOption.date;
  bool _ascending = false;

  // Helper to extract domain from URL
  String _getDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.replaceAll('www.', '');
    } catch (e) {
      return url;
    }
  }

  // Helper to get color and icon based on domain
  LinkStyle _getLinkStyle(String url) {
    final domain = _getDomain(url).toLowerCase();
    
    if (domain.contains('github')) {
      return LinkStyle(Colors.black, Icons.code, 'GitHub');
    } else if (domain.contains('youtube') || domain.contains('youtu.be')) {
      return LinkStyle(Colors.red, Icons.play_circle, 'YouTube');
    } else if (domain.contains('twitter') || domain.contains('x.com')) {
      return LinkStyle(Colors.blue, Icons.tag, 'Twitter');
    } else if (domain.contains('linkedin')) {
      return LinkStyle(Colors.blue.shade700, Icons.work, 'LinkedIn');
    } else if (domain.contains('medium') || domain.contains('dev.to')) {
      return LinkStyle(Colors.green.shade700, Icons.article, 'Blog');
    } else if (domain.contains('stackoverflow')) {
      return LinkStyle(Colors.orange, Icons.question_answer, 'Stack Overflow');
    } else if (domain.contains('reddit')) {
      return LinkStyle(Colors.deepOrange, Icons.forum, 'Reddit');
    } else if (domain.contains('docs.') || domain.contains('documentation')) {
      return LinkStyle(Colors.indigo, Icons.menu_book, 'Docs');
    } else {
      return LinkStyle(Colors.blue, Icons.language, 'Web');
    }
  }

  @override
  Widget build(BuildContext context) {
    final linksAsync = ref.watch(linksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Links'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortOptions,
            tooltip: 'Sort',
          ),
        ],
      ),
      body: linksAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.link,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No links yet',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Save your favorite websites\nand articles here',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () async {
                        await showDialog(
                          context: context,
                          builder: (_) => const AddLinkDialog(),
                        );
                        ref.invalidate(linksProvider);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Link'),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).scale(delay: 100.ms),
            );
          }

          final links = items.cast<LinkItem>();
          
          // Apply sorting
          final sortedLinks = _sortItems(links);

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(linksProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sortedLinks.length,
              itemBuilder: (context, index) {
                final link = sortedLinks[index];
                final style = _getLinkStyle(link.url);
                final domain = _getDomain(link.url);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => AppActions.openItem(context, link),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Row
                          Row(
                            children: [
                              // Icon with colored background
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: style.color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  style.icon,
                                  color: style.color,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Title and domain
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      link.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: style.color.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            style.label,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: style.color,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            domain,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Favorite & Menu
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (link.isFavorite)
                                    const Icon(
                                      Icons.star,
                                      color: Colors.orange,
                                      size: 20,
                                    ),
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert, size: 20),
                                    onSelected: (value) {
                                      if (value == 'copy') {
                                        _copyUrl(context, link);
                                      } else if (value == 'browser') {
                                        _openInBrowser(context, link);
                                      } else if (value == 'share') {
                                        AppActions.shareItem(link);
                                      } else if (value == 'delete') {
                                        _deleteLink(context, ref, link);
                                      } else if (value == 'favorite') {
                                        _toggleFavorite(ref, link);
                                      } else if (value == 'edit') {
                                        _editLink(context, ref, link);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit, size: 18),
                                            SizedBox(width: 8),
                                            Text('Edit'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'copy',
                                        child: Row(
                                          children: [
                                            Icon(Icons.copy, size: 18),
                                            SizedBox(width: 8),
                                            Text('Copy URL'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'browser',
                                        child: Row(
                                          children: [
                                            Icon(Icons.open_in_browser, size: 18),
                                            SizedBox(width: 8),
                                            Text('Open in Browser'),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'favorite',
                                        child: Row(
                                          children: [
                                            Icon(
                                              link.isFavorite
                                                  ? Icons.star_border
                                                  : Icons.star,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(link.isFavorite
                                                ? 'Unfavorite'
                                                : 'Favorite'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'share',
                                        child: Row(
                                          children: [
                                            Icon(Icons.share, size: 18),
                                            SizedBox(width: 8),
                                            Text('Share'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete, size: 18, color: Colors.red),
                                            SizedBox(width: 8),
                                            Text('Delete',
                                                style: TextStyle(color: Colors.red)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // Description if available
                          if (link.description != null && link.description!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              link.description!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          // Tags if available
                          if (link.tags.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: link.tags
                                  .map((tag) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          tag.name,
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 200.ms).slideX(begin: 0.1, end: 0);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Future<void> _deleteLink(BuildContext context, WidgetRef ref, LinkItem link) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete Link?'),
        content: Text('Delete "${link.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(itemRepositoryProvider).deleteItem(link.id);
      ref.invalidate(linksProvider);
      ref.invalidate(recentItemsProvider);
      ref.invalidate(favoritesProvider);
    }
  }

  Future<void> _toggleFavorite(WidgetRef ref, LinkItem link) async {
    HapticFeedback.lightImpact();
    final updated = link.copyWith(isFavorite: !link.isFavorite);
    await ref.read(itemRepositoryProvider).updateItem(updated);
    ref.invalidate(linksProvider);
    ref.invalidate(favoritesProvider);
  }

  Future<void> _editLink(BuildContext context, WidgetRef ref, LinkItem link) async {
    await showDialog(
      context: context,
      builder: (context) => EditLinkDialog(link: link),
    );
    ref.invalidate(linksProvider);
    ref.invalidate(recentItemsProvider);
  }

  void _copyUrl(BuildContext context, LinkItem link) {
    HapticFeedback.mediumImpact();
    Clipboard.setData(ClipboardData(text: link.url));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('URL copied to clipboard'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openInBrowser(BuildContext context, LinkItem link) {
    HapticFeedback.lightImpact();
    AppActions.openItem(context, link);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening in browser...'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  List<LinkItem> _sortItems(List<LinkItem> items) {
    final sorted = List<LinkItem>.from(items);
    
    switch (_sortBy) {
      case SortOption.date:
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case SortOption.name:
        sorted.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case SortOption.favorites:
        sorted.sort((a, b) {
          if (a.isFavorite == b.isFavorite) {
            return a.createdAt.compareTo(b.createdAt);
          }
          return a.isFavorite ? -1 : 1;
        });
        break;
    }
    
    return _ascending ? sorted : sorted.reversed.toList();
  }

  void _showSortOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort Links'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RadioListTile<SortOption>(
              title: const Text('Date Created'),
              value: SortOption.date,
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() => _sortBy = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<SortOption>(
              title: const Text('Name'),
              value: SortOption.name,
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() => _sortBy = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<SortOption>(
              title: const Text('Favorites First'),
              value: SortOption.favorites,
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() => _sortBy = value!);
                Navigator.pop(context);
              },
            ),
            const Divider(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Text('Order:'),
                  const Spacer(),
                  ChoiceChip(
                    label: Text(_ascending ? 'Oldest First ↑' : 'Newest First ↓'),
                    selected: true,
                    onSelected: (_) {
                      setState(() => _ascending = !_ascending);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// Helper class for link styling
class LinkStyle {
  final Color color;
  final IconData icon;
  final String label;

  LinkStyle(this.color, this.icon, this.label);
}
