import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:linknest/domain/entities/item.dart';
import 'package:linknest/presentation/common/app_actions.dart';
import 'package:linknest/presentation/providers/providers.dart';
import 'package:linknest/presentation/feature_docs/edit_document_dialog.dart';

class DocsScreen extends ConsumerStatefulWidget {
  const DocsScreen({super.key});

  @override
  ConsumerState<DocsScreen> createState() => _DocsScreenState();
}

enum DocSortOption { date, name, favorites }

class _DocsScreenState extends ConsumerState<DocsScreen> {
  DocSortOption _sortBy = DocSortOption.date;
  bool _ascending = false;

  @override
  Widget build(BuildContext context) {
    final docsAsync = ref.watch(docsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortOptions,
            tooltip: 'Sort',
          ),
        ],
      ),
      body: docsAsync.when(
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
                        color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.description, size: 64, color: Colors.orange),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No documents yet',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Store PDFs, images, and files\nsafely in your vault',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => AppActions.pickAndCreateDocument(context, ref),
                      icon: const Icon(Icons.add),
                      label: const Text('Add a Document'),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).scale(delay: 100.ms),
            );
          }

          final docs = items.cast<DocumentItem>();
          final sortedDocs = _sortItems(docs);

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(docsProvider),
            child: ListView.separated(
              itemCount: sortedDocs.length,
              separatorBuilder: (c, i) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final doc = sortedDocs[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: InkWell(
                    onTap: () => _openFile(context, doc),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getIconForType(doc.fileType),
                                color: Colors.orange,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    doc.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${doc.fileType.toUpperCase()} • ${_formatBytes(doc.fileSize)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (doc.isFavorite)
                              const Icon(
                                Icons.star,
                                color: Colors.orange,
                                size: 20,
                              ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 20),
                              onPressed: () => showDialog(
                                context: context,
                                builder: (context) => EditDocumentDialog(document: doc),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _deleteDoc(context, ref, doc),
                            ),
                          ],
                        ),
                        // Tags
                        if (doc.tags.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: doc.tags.map((tag) {
                              final tagColor = tag.color != null 
                                  ? Color(tag.color!) 
                                  : Theme.of(context).colorScheme.primary;
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
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
                                    fontSize: 11,
                                    color: tagColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  List<DocumentItem> _sortItems(List<DocumentItem> items) {
    final sorted = List<DocumentItem>.from(items);
    
    switch (_sortBy) {
      case DocSortOption.date:
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case DocSortOption.name:
        sorted.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case DocSortOption.favorites:
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
        title: const Text('Sort Documents'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RadioListTile<DocSortOption>(
              title: const Text('Date Created'),
              value: DocSortOption.date,
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() => _sortBy = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<DocSortOption>(
              title: const Text('Name'),
              value: DocSortOption.name,
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() => _sortBy = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<DocSortOption>(
              title: const Text('Favorites First'),
              value: DocSortOption.favorites,
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
  
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  
  Future<void> _openFile(BuildContext context, DocumentItem doc) async {
    await AppActions.openDocument(context, doc);
  }
  
  Future<void> _deleteDoc(BuildContext context, WidgetRef ref, DocumentItem doc) async {
    final delete = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete Document?'),
        content: Text('Delete "${doc.title}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete')),
        ],
      ),
    );
     
    if (delete == true) {
      await ref.read(itemRepositoryProvider).deleteItem(doc.id);
      try {
        final file = File(doc.filePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {}
      ref.invalidate(docsProvider);
    }
  }

  IconData _getIconForType(String type) {
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
}
