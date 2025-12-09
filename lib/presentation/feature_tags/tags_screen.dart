import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:linknest/core/constants/app_constants.dart';
import 'package:linknest/domain/entities/item.dart';
import 'package:linknest/presentation/providers/providers.dart';

class TagsScreen extends ConsumerWidget {
  const TagsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(tagsProvider);
    final allItemsAsync = ref.watch(allItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tags'),
      ),
      body: tagsAsync.when(
        data: (tags) {
          if (tags.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.label_off, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No tags yet'),
                  const SizedBox(height: 8),
                  Text(
                    'Tags will appear as you add them to items',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            );
          }

          return allItemsAsync.when(
            data: (allItems) {
              // Calculate item count for each tag
              final tagCounts = <String, int>{};
              for (final item in allItems) {
                for (final tag in item.tags) {
                  tagCounts[tag.id] = (tagCounts[tag.id] ?? 0) + 1;
                }
              }

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(tagsProvider);
                  ref.invalidate(allItemsProvider);
                },
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: tags.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final tag = tags[index];
                    final count = tagCounts[tag.id] ?? 0;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: tag.color != null
                            ? Color(tag.color!)
                            : AppConstants.tagColors[
                                index % AppConstants.tagColors.length],
                        child: Text(
                          tag.name[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(tag.name),
                      subtitle: Text('$count item${count != 1 ? 's' : ''}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20),
                            onPressed: count == 0
                                ? () => _deleteTag(context, ref, tag)
                                : null,
                            tooltip: count > 0
                                ? 'Remove from all items first'
                                : 'Delete tag',
                          ),
                        ],
                      ),
                      onTap: count > 0
                          ? () => context.push('/tags/${tag.id}',
                              extra: {'tag': tag})
                          : null,
                    )
                        .animate()
                        .fadeIn(duration: 300.ms, delay: (index * 50).ms)
                        .slideX(begin: 0.2);
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error loading tags: $e')),
      ),
    );
  }

  Future<void> _deleteTag(
      BuildContext context, WidgetRef ref, Tag tag) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete Tag?'),
        content: Text('Delete tag "${tag.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(itemRepositoryProvider).deleteTag(tag.id);
        ref.invalidate(tagsProvider);
        ref.invalidate(allItemsProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tag "${tag.name}" deleted')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting tag: $e')),
          );
        }
      }
    }
  }
}
