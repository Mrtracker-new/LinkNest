import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:linknest/domain/entities/item.dart';
import 'package:linknest/presentation/common/tag_selector.dart';
import 'package:linknest/presentation/providers/providers.dart';
import 'package:path/path.dart' as p;

class EditDocumentDialog extends ConsumerStatefulWidget {
  final DocumentItem document;

  const EditDocumentDialog({super.key, required this.document});

  @override
  ConsumerState<EditDocumentDialog> createState() => _EditDocumentDialogState();
}

class _EditDocumentDialogState extends ConsumerState<EditDocumentDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late List<Tag> _selectedTags;
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.document.title);
    _descriptionController = TextEditingController(text: widget.document.description ?? '');
    _selectedTags = List.from(widget.document.tags);
    _isFavorite = widget.document.isFavorite;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Document'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Card(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('File Info', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Type: ${widget.document.fileType.toUpperCase()}'),
                      Text('Size: ${_formatBytes(widget.document.fileSize)}'),
                      const SizedBox(height: 4),
                      Text(
                        'Path: ${widget.document.filePath}',
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TagSelector(
                selectedTags: _selectedTags,
                onSelectionChanged: (tags) {
                  setState(() {
                    _selectedTags = tags;
                  });
                },
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Favorite'),
                value: _isFavorite,
                onChanged: (val) => setState(() => _isFavorite = val ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saveDocument,
          child: const Text('Save'),
        ),
      ],
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _saveDocument() async {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a title')),
      );
      return;
    }

    try {
      final updatedDocument = widget.document.copyWith(
        title: title,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        tags: _selectedTags,
        isFavorite: _isFavorite,
      );

      await ref.read(itemRepositoryProvider).updateItem(updatedDocument);
      
      // Invalidate relevant providers
      ref.invalidate(docsProvider);
      ref.invalidate(recentItemsProvider);
      ref.invalidate(favoritesProvider);
      ref.invalidate(allItemsProvider);
      ref.invalidate(statisticsProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating document: $e')),
        );
      }
    }
  }
}
