import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:linknest/domain/entities/item.dart';
import 'package:linknest/presentation/providers/providers.dart';
import 'package:linknest/presentation/common/app_actions.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentAsync = ref.watch(recentItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('LinkNest'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
          IconButton(
            icon: const Icon(Icons.star_border),
            onPressed: () => context.push('/favorites'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(recentItemsProvider),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primaryContainer,
                            Theme.of(context).colorScheme.secondaryContainer,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.lock_outline,
                            size: 48,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _getGreeting(),
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Your Knowledge Vault',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Locally stored • Secure • Offline',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 400.ms).scale(),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: InkWell(
                          onTap: () => context.push('/tags'),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Icon(Icons.label, color: Theme.of(context).colorScheme.primary),
                                const SizedBox(height: 8),
                                const Text('Browse Tags', style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ).animate().fadeIn(duration: 300.ms).scale(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Card(
                        child: InkWell(
                          onTap: () => context.push('/statistics'),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Icon(Icons.bar_chart, color: Theme.of(context).colorScheme.primary),
                                const SizedBox(height: 8),
                                const Text('Statistics', style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ).animate().fadeIn(duration: 300.ms, delay: 100.ms).scale(),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Text(
                  'Recent Items',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            recentAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(
                        child: Text('No items yet. Add something from the tabs below!'),
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = items[index];
                      IconData icon;
                      Color color;
                      
                      // Color-code links based on domain
                      if (item is LinkItem) {
                        final style = _getLinkStyle(item.url);
                        icon = style.icon;
                        color = style.color;
                      } else if (item is DocumentItem) {
                        // Use file-type-specific icons for documents
                        icon = _getDocumentIcon(item.fileType);
                        color = Colors.orange;
                      } else {
                        icon = Icons.edit_note;
                        color = Colors.purple;
                      }

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(icon, color: color, size: 20),
                          ),
                          title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text(
                            item.type.name.toUpperCase(),
                            style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => _openItem(context, item),
                        ),
                      ).animate().fadeIn(duration: 300.ms, delay: (index * 50).ms).slideX(begin: 0.1);
                    },
                    childCount: items.length,
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(
                  child: Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))),
              error: (e, s) => SliverToBoxAdapter(child: Center(child: Text('Error: $e'))),
            ),
          ],
        ),
      ),
    );
  }

  // Helper to get link style
  LinkStyle _getLinkStyle(String url) {
    try {
      final domain = Uri.parse(url).host.replaceAll('www.', '').toLowerCase();
      
      if (domain.contains('github')) return LinkStyle(Colors.black, Icons.code);
      if (domain.contains('youtube') || domain.contains('youtu.be')) return LinkStyle(Colors.red, Icons.play_circle);
      if (domain.contains('twitter') || domain.contains('x.com')) return LinkStyle(Colors.blue, Icons.tag);
      if (domain.contains('linkedin')) return LinkStyle(Colors.blue.shade700, Icons.work);
      if (domain.contains('medium') || domain.contains('dev.to')) return LinkStyle(Colors.green.shade700, Icons.article);
      if (domain.contains('stackoverflow')) return LinkStyle(Colors.orange, Icons.question_answer);
      if (domain.contains('reddit')) return LinkStyle(Colors.deepOrange, Icons.forum);
      if (domain.contains('docs.') || domain.contains('documentation')) return LinkStyle(Colors.indigo, Icons.menu_book);
    } catch (e) {}
    return LinkStyle(Colors.blue, Icons.language);
  }

  // Helper to get document icon based on file type
  IconData _getDocumentIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pdf': return Icons.picture_as_pdf;
      case 'doc':
      case 'docx': return Icons.description;
      case 'xls': 
      case 'xlsx': return Icons.table_chart;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp': return Icons.image;
      case 'txt': return Icons.text_snippet;
      case 'json':
      case 'xml': return Icons.code;
      default: return Icons.insert_drive_file;
    }
  }

  void _openItem(BuildContext context, Item item) {
    if (item is LinkItem || item is DocumentItem) {
      AppActions.openItem(context, item);
    } else if (item is NoteItem) {
      context.push('/notes/edit?id=${item.id}');
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    if (hour < 21) return 'Good Evening';
    return 'Good Night';
  }
}

// Helper class for link styling
class LinkStyle {
  final Color color;
  final IconData icon;
  LinkStyle(this.color, this.icon);
}
