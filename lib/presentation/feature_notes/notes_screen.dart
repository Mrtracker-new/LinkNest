import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:linknest/domain/entities/item.dart';
import 'package:linknest/presentation/providers/providers.dart';
import 'package:linknest/presentation/common/app_actions.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

enum NoteSortOption { date, name, favorites }

class _NotesScreenState extends ConsumerState<NotesScreen> {
  NoteSortOption _sortBy = NoteSortOption.date;
  bool _ascending = false;

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(notesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortOptions,
            tooltip: 'Sort',
          ),
        ],
      ),
      body: notesAsync.when(
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
                        color: Theme.of(context).colorScheme.tertiaryContainer.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit_note,
                        size: 64,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No notes yet',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Capture thoughts, ideas, and\nimportant information',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => context.push('/notes/edit'),
                      icon: const Icon(Icons.add),
                      label: const Text('Create a Note'),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).scale(delay: 100.ms),
            );
          }

          final notes = items.cast<NoteItem>();
          final sortedNotes = _sortItems(notes);

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(notesProvider),
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.9,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: sortedNotes.length,
              itemBuilder: (context, index) {
                final note = sortedNotes[index];
                return Card(
                  child: InkWell(
                    onTap: () => context.push('/notes/edit?id=${note.id}'),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.edit_note, size: 20, color: Colors.purple),
                              const Spacer(),
                              if (note.isFavorite)
                                const Icon(Icons.star, size: 16, color: Colors.orange),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert, size: 18),
                                onSelected: (value) {
                                  if (value == 'copy') {
                                    _copyContent(context, note);
                                  } else if (value == 'share') {
                                    AppActions.shareItem(note);
                                  } else if (value == 'delete') {
                                    _deleteNote(ref, note);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'copy',
                                    child: Row(
                                      children: [
                                        Icon(Icons.copy, size: 18),
                                        SizedBox(width: 8),
                                        Text('Copy Content'),
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
                                        Text('Delete', style: TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            note.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          // Tags
                          if (note.tags.isNotEmpty) ...[
                            Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: note.tags.map((tag) {
                                final tagColor = tag.color != null 
                                    ? Color(tag.color!) 
                                    : Theme.of(context).colorScheme.primary;
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: tagColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: tagColor.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    tag.name,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: tagColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 8),
                          ],
                          Expanded(
                            child: Text(
                              note.content,
                              style: TextStyle(color: Colors.grey[600]),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 200.ms).scale();
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  List<NoteItem> _sortItems(List<NoteItem> items) {
    final sorted = List<NoteItem>.from(items);
    
    switch (_sortBy) {
      case NoteSortOption.date:
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case NoteSortOption.name:
        sorted.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case NoteSortOption.favorites:
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
        title: const Text('Sort Notes'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RadioListTile<NoteSortOption>(
              title: const Text('Date Created'),
              value: NoteSortOption.date,
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() => _sortBy = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<NoteSortOption>(
              title: const Text('Name'),
              value: NoteSortOption.name,
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() => _sortBy = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<NoteSortOption>(
              title: const Text('Favorites First'),
              value: NoteSortOption.favorites,
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

  void _copyContent(BuildContext context, NoteItem note) {
    HapticFeedback.mediumImpact();
    Clipboard.setData(ClipboardData(text: note.content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Note content copied to clipboard'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _deleteNote(WidgetRef ref, NoteItem note) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete Note?'),
        content: Text('Delete "${note.title}"?'),
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
      await ref.read(itemRepositoryProvider).deleteItem(note.id);
      ref.invalidate(notesProvider);
      ref.invalidate(recentItemsProvider);
      ref.invalidate(favoritesProvider);
    }
  }
}
