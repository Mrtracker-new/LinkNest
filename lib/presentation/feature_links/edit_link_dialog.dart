import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linknest/domain/entities/item.dart';
import 'package:linknest/presentation/common/tag_selector.dart';
import 'package:linknest/presentation/providers/providers.dart';
import 'package:uuid/uuid.dart';

class EditLinkDialog extends ConsumerStatefulWidget {
  final LinkItem link;

  const EditLinkDialog({super.key, required this.link});

  @override
  ConsumerState<EditLinkDialog> createState() => _EditLinkDialogState();
}

class _EditLinkDialogState extends ConsumerState<EditLinkDialog> {
  late TextEditingController _titleController;
  late TextEditingController _urlController;
  late TextEditingController _descriptionController;
  late List<Tag> _selectedTags;
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.link.title);
    _urlController = TextEditingController(text: widget.link.url);
    _descriptionController = TextEditingController(text: widget.link.description ?? '');
    _selectedTags = List.from(widget.link.tags);
    _isFavorite = widget.link.isFavorite;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Link'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'URL *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                ),
                keyboardType: TextInputType.url,
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
          onPressed: _saveLink,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _saveLink() async {
    final title = _titleController.text.trim();
    final url = _urlController.text.trim();

    if (title.isEmpty || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in title and URL')),
      );
      return;
    }

    try {
      final updatedLink = widget.link.copyWith(
        title: title,
        url: url,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        tags: _selectedTags,
        isFavorite: _isFavorite,
      );

      await ref.read(itemRepositoryProvider).updateItem(updatedLink);
      
      // Invalidate relevant providers
      ref.invalidate(linksProvider);
      ref.invalidate(recentItemsProvider);
      ref.invalidate(favoritesProvider);
      ref.invalidate(allItemsProvider);
      ref.invalidate(statisticsProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Link updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating link: $e')),
        );
      }
    }
  }
}
