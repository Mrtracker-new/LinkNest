import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linknest/domain/entities/item.dart';
import 'package:linknest/presentation/common/tag_selector.dart';
import 'package:linknest/presentation/providers/providers.dart';
import 'package:uuid/uuid.dart';

class AddLinkDialog extends ConsumerStatefulWidget {
  const AddLinkDialog({super.key});

  @override
  ConsumerState<AddLinkDialog> createState() => _AddLinkDialogState();
}

class _AddLinkDialogState extends ConsumerState<AddLinkDialog> {
    final _urlCtrl = TextEditingController();
    final _titleCtrl = TextEditingController();
    List<Tag> _selectedTags = [];
    bool _isLoading = false;

    @override
    Widget build(BuildContext context) {
       return AlertDialog(
         title: const Text('Add Link'),
         content: SingleChildScrollView(
           child: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
               TextField(
                 controller: _urlCtrl,
                 decoration: const InputDecoration(labelText: 'URL', hintText: 'https://...'),
                 autofocus: true,
               ),
               const SizedBox(height: 16),
               TextField(
                 controller: _titleCtrl,
                 decoration: const InputDecoration(labelText: 'Title (Optional)'),
               ),
               const SizedBox(height: 16),
               TagSelector(
                 selectedTags: _selectedTags,
                 onSelectionChanged: (tags) => setState(() => _selectedTags = tags),
               ),
             ],
           ),
         ),
         actions: [
           TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
           FilledButton(
             onPressed: _isLoading ? null : _save,
             child: _isLoading ? const CircularProgressIndicator.adaptive() : const Text('Save'),
           ),
         ],
       );
    }

    Future<void> _save() async {
        // Cleaning the input: remove newlines, trim spaces
        var url = _urlCtrl.text.trim().replaceAll('\n', '').replaceAll(' ', '');
        if (url.isEmpty) return;
        
        // Basic validation / fix
        if (!url.startsWith('http://') && !url.startsWith('https://')) {
          url = 'https://$url';
        }
        
        // Stricter validation
        final uri = Uri.tryParse(url);
        if (uri == null || !uri.hasScheme || !uri.host.contains('.')) {
           if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid URL (e.g., example.com)')));
           }
           return;
        }

        setState(() => _isLoading = true);
        
        try {
            final repo = ref.read(itemRepositoryProvider);
            // Auto-title if empty (could fetch metadata in real app)
            final title = _titleCtrl.text.isEmpty ? Uri.parse(url).host : _titleCtrl.text;
            
            final newItem = LinkItem(
              id: const Uuid().v4(),
              title: title,
              url: url,
              isFavorite: false,
              tags: _selectedTags,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
            
            await repo.createItem(newItem);
            ref.invalidate(linksProvider); 
            ref.invalidate(recentItemsProvider);
            if (mounted) Navigator.pop(context);
        } catch (e) {
             debugPrint('Error saving link: $e');
        } finally {
             if (mounted) setState(() => _isLoading = false);
        }
    }
}
