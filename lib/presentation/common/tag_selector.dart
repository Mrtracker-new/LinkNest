import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linknest/core/constants/app_constants.dart';
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
  Color? _selectedColor;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Color _getTagColor(Tag tag) {
    if (tag.color != null) {
      return Color(tag.color!);
    }
    return AppConstants.tagColors[0]; // Default blue
  }

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
            ...widget.selectedTags.map((tag) {
              final tagColor = _getTagColor(tag);
              return Chip(
                avatar: CircleAvatar(
                  backgroundColor: tagColor,
                  radius: 8,
                ),
                label: Text(tag.name),
                onDeleted: () {
                  final newList = List<Tag>.from(widget.selectedTags);
                  newList.remove(tag);
                  widget.onSelectionChanged(newList);
                },
              );
            }),
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
    _selectedColor = null;
    
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Select or Create Tag'),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // New tag input
                    TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        labelText: 'New Tag Name',
                        suffixIcon: Icon(Icons.tag),
                        hintText: 'e.g., important, work, personal',
                      ),
                      onChanged: (value) {
                        // Auto-suggest color based on tag name
                        setDialogState(() {
                          final suggested = AppConstants.getSuggestedColorForTag(value);
                          if (suggested != null && _selectedColor == null) {
                            _selectedColor = suggested;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Color picker
                    const Text('Choose Color:', style: TextStyle(fontSize: 13)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: AppConstants.namedTagColors.entries.map((entry) {
                        final isSelected = _selectedColor?.value == entry.value.value;
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              _selectedColor = entry.value;
                            });
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: entry.value,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.black : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: entry.value.withOpacity(0.5),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      )
                                    ]
                                  : null,
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, color: Colors.white, size: 20)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 8),
                    
                    // Existing tags
                    if (allTags.isNotEmpty) ...[
                      const Text('Or select existing:', style: TextStyle(fontSize: 13)),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 120,
                        child: SingleChildScrollView(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: allTags
                                .where((t) => !widget.selectedTags.any((st) => st.id == t.id))
                                .map((tag) {
                              final tagColor = _getTagColor(tag);
                              return ActionChip(
                                avatar: CircleAvatar(
                                  backgroundColor: tagColor,
                                  radius: 8,
                                ),
                                label: Text(tag.name),
                                onPressed: () {
                                  final newList = List<Tag>.from(widget.selectedTags)..add(tag);
                                  widget.onSelectionChanged(newList);
                                  Navigator.pop(dialogContext);
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _textController.clear();
                  _selectedColor = null;
                  Navigator.pop(dialogContext);
                },
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  final name = _textController.text.trim();
                  if (name.isNotEmpty) {
                    // Check if exists
                    final existing = allTags.firstWhere(
                      (t) => t.name.toLowerCase() == name.toLowerCase(),
                      orElse: () => Tag(id: '', name: '', color: 0),
                    );
                    
                    if (existing.id.isNotEmpty) {
                      final newList = List<Tag>.from(widget.selectedTags)..add(existing);
                      widget.onSelectionChanged(newList);
                    } else {
                      // Create new tag with selected or suggested color
                      final color = _selectedColor ?? AppConstants.getSuggestedColorForTag(name) ?? AppConstants.tagColors[0];
                      final newTag = Tag(
                        id: const Uuid().v4(),
                        name: name,
                        color: color.value,
                      );
                      await ref.read(itemRepositoryProvider).createTag(newTag);
                      ref.invalidate(tagsProvider);
                      
                      final newList = List<Tag>.from(widget.selectedTags)..add(newTag);
                      widget.onSelectionChanged(newList);
                    }
                    
                    _textController.clear();
                    _selectedColor = null;
                    if (dialogContext.mounted) Navigator.pop(dialogContext);
                  }
                },
                child: const Text('Create'),
              ),
            ],
          );
        },
      ),
    );
  }
}
