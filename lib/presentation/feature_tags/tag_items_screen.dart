import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:linknest/domain/entities/item.dart';
import 'package:linknest/presentation/common/app_actions.dart';
import 'package:linknest/presentation/providers/providers.dart';

class TagItemsScreen extends ConsumerWidget {
  final String tagId;

  const TagItemsScreen({super.key, required this.tagId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(tagItemsProvider(tagId));
    final tagsAsync = ref.watch(tagsProvider);

    return Scaffold(
      appBar: AppBar(
        title: tagsAsync.when(
          data: (tags) {
            final tag = tags.where((t) => t.id == tagId).firstOrNull;
            return Text(tag?.name ?? 'Tagged Items');
          },
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Tagged Items'),
        ),
      ),
      body: itemsAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.label_off, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No items with this tag'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(tagItemsProvider(tagId)),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = items[index];
                IconData icon;
                Color iconColor;

                if (item is LinkItem) {
                  icon = Icons.link;
                  iconColor = Colors.green;
                } else if (item is DocumentItem) {
                  icon = Icons.description;
                  iconColor = Colors.orange;
                } else {
                  icon = Icons.edit_note;
                  iconColor = Colors.purple;
                }

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: iconColor.withOpacity(0.1),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  title: Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.type.name.toUpperCase(),
                        style: const TextStyle(fontSize: 10),
                      ),
                      if (item.tags.length > 1) ...[
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 4,
                          children: item.tags
                              .where((t) => t.id != tagId)
                              .take(3)
                              .map((tag) => Chip(
                                    label: Text(
                                      tag.name,
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                    padding: EdgeInsets.zero,
                                    backgroundColor: tag.color != null
                                        ? Color(tag.color!).withOpacity(0.2)
                                        : null,
                                  ))
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (item.isFavorite)
                        const Icon(
                          Icons.star,
                          color: Colors.orange,
                          size: 20,
                        ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.share, size: 20),
                        onPressed: () => AppActions.shareItem(item),
                      ),
                    ],
                  ),
                  onTap: () => AppActions.openItem(context, item),
                )
                    .animate()
                    .fadeIn(duration: 300.ms, delay: (index * 50).ms)
                    .slideX(begin: 0.1);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading items: $e'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(tagItemsProvider(tagId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
