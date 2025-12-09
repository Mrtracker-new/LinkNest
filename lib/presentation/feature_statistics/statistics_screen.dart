import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:linknest/core/constants/app_constants.dart';
import 'package:linknest/domain/entities/item.dart';
import 'package:linknest/presentation/common/app_actions.dart';
import 'package:linknest/presentation/providers/providers.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statisticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: statsAsync.when(
        data: (stats) => RefreshIndicator(
          onRefresh: () async => ref.refresh(statisticsProvider),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overview Cards
                _buildOverviewSection(context, stats),
                const SizedBox(height: 24),

                // Storage Info
                if (stats.documentsCount > 0) ...[
                  _buildStorageSection(context, stats),
                  const SizedBox(height: 24),
                ],

                // Top Tags
                if (stats.topTags.isNotEmpty) ...[
                  _buildTopTagsSection(context, stats),
                  const SizedBox(height: 24),
                ],

                // Recent Activity
                if (stats.recentItems.isNotEmpty) ...[
                  _buildRecentActivitySection(context, stats),
                ],
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading statistics: $e'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(statisticsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewSection(BuildContext context, stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            _buildStatCard(
              context,
              icon: Icons.inventory_2,
              label: 'Total Items',
              value: stats.totalItems.toString(),
              color: Colors.blue,
              onTap: null, // No specific screen for all items
            ).animate().fadeIn(duration: 300.ms).scale(delay: 0.ms),
            _buildStatCard(
              context,
              icon: Icons.link,
              label: 'Links',
              value: stats.linksCount.toString(),
              color: Colors.green,
              onTap: () => context.go('/links'),
            ).animate().fadeIn(duration: 300.ms).scale(delay: 50.ms),
            _buildStatCard(
              context,
              icon: Icons.description,
              label: 'Documents',
              value: stats.documentsCount.toString(),
              color: Colors.orange,
              onTap: () => context.go('/docs'),
            ).animate().fadeIn(duration: 300.ms).scale(delay: 100.ms),
            _buildStatCard(
              context,
              icon: Icons.edit_note,
              label: 'Notes',
              value: stats.notesCount.toString(),
              color: Colors.purple,
              onTap: () => context.go('/notes'),
            ).animate().fadeIn(duration: 300.ms).scale(delay: 150.ms),
            _buildStatCard(
              context,
              icon: Icons.star,
              label: 'Favorites',
              value: stats.favoritesCount.toString(),
              color: Colors.amber,
              onTap: () => context.push('/favorites'),
            ).animate().fadeIn(duration: 300.ms).scale(delay: 200.ms),
            _buildStatCard(
              context,
              icon: Icons.label,
              label: 'Tags',
              value: stats.tagsCount.toString(),
              color: Colors.cyan,
              onTap: () => context.push('/tags'),
            ).animate().fadeIn(duration: 300.ms).scale(delay: 250.ms),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    VoidCallback? onTap,
  }) {
    final card = Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            await HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(12),
          child: card,
        ),
      );
    }

    return card;
  }

  Widget _buildStorageSection(BuildContext context, stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Storage',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.storage,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            title: const Text('Total Storage Used'),
            subtitle: Text('${stats.documentsCount} documents'),
            trailing: Text(
              stats.formattedStorage,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.2),
      ],
    );
  }

  Widget _buildTopTagsSection(BuildContext context, stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Most Used Tags',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stats.topTags.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final tagWithCount = stats.topTags[index];
              final tag = tagWithCount.tag;
              final count = tagWithCount.itemCount;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: tag.color != null
                      ? Color(tag.color!)
                      : AppConstants.tagColors[index % AppConstants.tagColors.length],
                  radius: 16,
                  child: Text(
                    tag.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(tag.name),
                trailing: Chip(
                  label: Text('$count'),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ).animate().fadeIn(duration: 300.ms, delay: (index * 50).ms);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivitySection(BuildContext context, stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stats.recentItems.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = stats.recentItems[index];
              IconData icon;
              Color iconColor;
              
              if (item is LinkItem) {
                // Use domain-based styling for links
                final style = _getLinkStyle(item.url);
                icon = style.$1;
                iconColor = style.$2;
              } else if (item is DocumentItem) {
                icon = _getDocumentIcon(item.fileType);
                iconColor = Colors.orange;
              } else {
                icon = Icons.edit_note;
                iconColor = Colors.purple;
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(
                    _getTypeLabel(item.type),
                    style: TextStyle(fontSize: 11, color: iconColor, fontWeight: FontWeight.w500),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (item.isFavorite)
                        const Icon(Icons.star, color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                  onTap: () => AppActions.openItem(context, item),
                ),
              ).animate().fadeIn(duration: 300.ms, delay: (index * 50).ms);
            },
          ),
        ),
      ],
    );
  }

  // Helper to extract domain from URL
  String _getDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.replaceAll('www.', '');
    } catch (e) {
      return url;
    }
  }

  // Helper to get color and icon based on domain (same as search screen)
  (IconData, Color) _getLinkStyle(String url) {
    final domain = _getDomain(url).toLowerCase();
    
    if (domain.contains('github')) {
      return (Icons.code, Colors.black);
    } else if (domain.contains('youtube') || domain.contains('youtu.be')) {
      return (Icons.play_circle, Colors.red);
    } else if (domain.contains('twitter') || domain.contains('x.com')) {
      return (Icons.tag, Colors.blue);
    } else if (domain.contains('linkedin')) {
      return (Icons.work, Colors.blue.shade700);
    } else if (domain.contains('medium') || domain.contains('dev.to')) {
      return (Icons.article, Colors.green.shade700);
    } else if (domain.contains('stackoverflow')) {
      return (Icons.question_answer, Colors.orange);
    } else if (domain.contains('reddit')) {
      return (Icons.forum, Colors.deepOrange);
    } else if (domain.contains('docs.') || domain.contains('documentation')) {
      return (Icons.menu_book, Colors.indigo);
    } else {
      return (Icons.language, Colors.blue);
    }
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

  // Helper to convert ItemType enum to string label
  String _getTypeLabel(ItemType type) {
    switch (type) {
      case ItemType.link:
        return 'LINK';
      case ItemType.document:
        return 'DOCUMENT';
      case ItemType.note:
        return 'NOTE';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
