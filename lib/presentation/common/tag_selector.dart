import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linknest/domain/entities/item.dart';
import 'package:linknest/presentation/providers/providers.dart';
import 'package:uuid/uuid.dart';

class TagSelector extends ConsumerStatefulWidget {
  final List<Tag> selectedTags;
  final Function(List<Tag>) onSelectionChanged;

  const TagSelector({
    super.key,
    required this.selectedTags,
    required this.onSelectionChanged,
  });

  @override
  ConsumerState<TagSelector> createState() => _TagSelectorState();
}

class _TagSelectorState extends ConsumerState<TagSelector> {
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final allTagsAsync = ref.watch(tagsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tags', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...widget.selectedTags.map((tag) => Chip(
                  label: Text(tag.name),
                  onDeleted: () {
                    final newList = List<Tag>.from(widget.selectedTags);
                    newList.remove(tag);
                    widget.onSelectionChanged(newList);
                  },
                )),
             ActionChip(
              avatar: const Icon(Icons.add, size: 16),
              label: const Text('Add Tag'),
              onPressed: () => _showAddTagDialog(context, allTagsAsync.value ?? []),
            ),
          ],
        ),
      ],
    );
  }

  void _showAddTagDialog(BuildContext context, List<Tag> allTags) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select or Create Tag'),
        content: SizedBox(
           width: double.maxFinite,
           child: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
               TextField(
                 controller: _textController,
                 decoration: const InputDecoration(
                   labelText: 'New Tag Name',
                   suffixIcon: Icon(Icons.tag),
                 ),
               ),
               const SizedBox(height: 16),
               if (allTags.isNotEmpty) ...[
                 const Align(alignment: Alignment.centerLeft, child: Text('Existing Tags:')),
                 const SizedBox(height: 8),
                 SizedBox(
                   height: 150,
                   child: SingleChildScrollView(
                     child: Wrap(
                       spacing: 8,
                       children: allTags.where((t) => !widget.selectedTags.any((st) => st.id == t.id)).map((tag) {
                         return ActionChip(
                           label: Text(tag.name),
                           onPressed: () {
                              final newList = List<Tag>.from(widget.selectedTags)..add(tag);
                              widget.onSelectionChanged(newList);
                              Navigator.pop(context);
                           },
                         );
                       }).toList(),
                     ),
                   ),
                 )
               ]
             ],
           ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
               final name = _textController.text.trim();
               if (name.isNotEmpty) {
                 // Check if exists
                 final existing = allTags.firstWhere((t) => t.name.toLowerCase() == name.toLowerCase(), orElse: () => Tag(id: '', name: '', color: 0));
                 if (existing.id.isNotEmpty) {
                    final newList = List<Tag>.from(widget.selectedTags)..add(existing);
                    widget.onSelectionChanged(newList);
                 } else {
                    // Create new
                    final newTag = Tag(id: const Uuid().v4(), name: name, color: Colors.blue.value);
                    await ref.read(itemRepositoryProvider).createTag(newTag);
                    ref.invalidate(tagsProvider);
                    
                    final newList = List<Tag>.from(widget.selectedTags)..add(newTag);
                    widget.onSelectionChanged(newList);
                 }
                 _textController.clear();
                 if (context.mounted) Navigator.pop(context);
               }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
