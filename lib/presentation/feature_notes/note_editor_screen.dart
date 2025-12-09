import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:linknest/domain/entities/item.dart';
import 'package:linknest/presentation/providers/providers.dart';
import 'package:linknest/presentation/common/tag_selector.dart';
import 'package:uuid/uuid.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  final String? noteId;
  const NoteEditorScreen({this.noteId, super.key});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _titleFocusNode = FocusNode();
  final _contentFocusNode = FocusNode();
  List<Tag> _selectedTags = [];
  bool _isDirty = false;
  bool _isFavorite = false;
  bool _showPreview = false; // NEW: Preview toggle
  NoteItem? _existingNote;

  @override
  void initState() {
    super.initState();
    if (widget.noteId != null) {
      _loadNote();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _titleFocusNode.requestFocus();
      });
    }
    _contentController.addListener(_updateWordCount);
  }

  void _updateWordCount() {
    setState(() {});
  }

  int get _wordCount {
    final text = _contentController.text.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).length;
  }

  int get _charCount => _contentController.text.length;

  Future<void> _loadNote() async {
    final repo = ref.read(itemRepositoryProvider);
    final item = await repo.getItemById(widget.noteId!);
    if (item is NoteItem && mounted) {
      setState(() {
        _existingNote = item;
        _titleController.text = item.title;
        _contentController.text = item.content;
        _selectedTags = item.tags;
        _isFavorite = item.isFavorite;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (!_isDirty) setState(() => _isDirty = true);
  }

  void _insertMarkdown(String syntax, {String placeholder = 'text'}) {
    final text = _contentController.text;
    final selection = _contentController.selection;
    
    // Handle invalid selection
    if (!selection.isValid || selection.start < 0) {
      // Insert at end of text
      final newText = text + syntax + placeholder + syntax;
      final newCursorPos = text.length + syntax.length;
      
      _contentController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newCursorPos),
      );
      _onChanged();
      return;
    }
    
    final start = selection.start;
    final end = selection.end;

    String newText;
    int newCursorPos;

    if (start != end) {
      // Text is selected
      final selectedText = text.substring(start, end);
      newText = text.replaceRange(start, end, '$syntax$selectedText$syntax');
      newCursorPos = end + syntax.length * 2;
    } else {
      // No selection
      newText = text.replaceRange(start, end, '$syntax$placeholder$syntax');
      newCursorPos = start + syntax.length;
    }

    _contentController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursorPos),
    );
    _onChanged();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add some content to save')),
      );
      return;
    }

    await HapticFeedback.mediumImpact();

    final repo = ref.read(itemRepositoryProvider);
    final now = DateTime.now();

    if (_existingNote != null) {
      final updated = NoteItem(
        id: _existingNote!.id,
        title: title.isEmpty ? 'Untitled Note' : title,
        content: content,
        createdAt: _existingNote!.createdAt,
        updatedAt: now,
        isFavorite: _isFavorite,
        tags: _selectedTags,
      );
      await repo.updateItem(updated);
    } else {
      final newItem = NoteItem(
        id: const Uuid().v4(),
        title: title.isEmpty ? 'Untitled Note' : title,
        content: content,
        createdAt: now,
        updatedAt: now,
        isFavorite: _isFavorite,
        tags: _selectedTags,
      );
      await repo.createItem(newItem);
    }

    ref.invalidate(notesProvider);
    ref.invalidate(recentItemsProvider);
    ref.invalidate(favoritesProvider);
    ref.invalidate(allItemsProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note saved successfully')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.noteId != null ? 'Edit Note' : 'New Note'),
        actions: [
          // Preview Toggle
          IconButton(
            icon: Icon(_showPreview ? Icons.edit : Icons.visibility),
            onPressed: () => setState(() => _showPreview = !_showPreview),
            tooltip: _showPreview ? 'Edit' : 'Preview',
          ),
          IconButton(
            icon: Icon(_isFavorite ? Icons.star : Icons.star_border),
            color: _isFavorite ? Colors.orange : null,
            onPressed: () {
              setState(() => _isFavorite = !_isFavorite);
              _onChanged();
            },
            tooltip: 'Mark as favorite',
          ),
        ],
      ),
      body: Column(
        children: [
          // Markdown Toolbar
          if (!_showPreview)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildToolbarButton(Icons.format_bold, 'Bold', () => _insertMarkdown('**')),
                    _buildToolbarButton(Icons.format_italic, 'Italic', () => _insertMarkdown('*')),
                    _buildToolbarButton(Icons.format_list_bulleted, 'List', () =>_insertMarkdown('\n- ', placeholder: 'item')),
                    _buildToolbarButton(Icons.format_list_numbered, 'Numbered', () => _insertMarkdown('\n1. ', placeholder: 'item')),
                    _buildToolbarButton(Icons.check_box, 'Checklist', () => _insertMarkdown('\n- [ ] ', placeholder: 'task')),
                    _buildToolbarButton(Icons.title, 'Heading', () => _insertMarkdown('\n## ', placeholder: 'heading')),
                    _buildToolbarButton(Icons.code, 'Code', () => _insertMarkdown('`')),
                    _buildToolbarButton(Icons.format_quote, 'Quote', () => _insertMarkdown('\n> ', placeholder: 'quote')),
                  ],
                ),
              ),
            ),

          Expanded(
            child: _showPreview ? _buildPreview() : _buildEditor(),
          ),

          // Bottom Stats Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: Border(
                top: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.text_fields, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  '$_charCount characters • $_wordCount words',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const Spacer(),
                if (_isDirty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Unsaved',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _save,
        icon: const Icon(Icons.save),
        label: const Text('Save Note'),
      ),
    );
  }

  Widget _buildToolbarButton(IconData icon, String tooltip, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, size: 20),
      tooltip: tooltip,
      onPressed: onPressed,
      padding: const EdgeInsets.all(8),
    );
  }

  Widget _buildEditor() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _titleController,
            focusNode: _titleFocusNode,
            decoration: InputDecoration(
              hintText: 'Note Title',
              border: InputBorder.none,
              hintStyle: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade400,
              ),
            ),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            textCapitalization: TextCapitalization.words,
            onChanged: (_) => _onChanged(),
          ),
          const SizedBox(height: 12),
          TagSelector(
            selectedTags: _selectedTags,
            onSelectionChanged: (tags) {
              setState(() {
                _selectedTags = tags;
                _isDirty = true;
              });
            },
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.grey.shade300, height: 1),
          const SizedBox(height: 20),
          TextField(
            controller: _contentController,
            focusNode: _contentFocusNode,
            decoration: InputDecoration(
              hintText: 'Write in Markdown...\n**Bold** *Italic* `code`',
              border: InputBorder.none,
              hintStyle: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade400,
              ),
            ),
            style: const TextStyle(fontSize: 16, height: 1.5, fontFamily: 'monospace'),
            maxLines: null,
            keyboardType: TextInputType.multiline,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) => _onChanged(),
          ),
          const SizedBox(height: 200),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_titleController.text.isNotEmpty) ...[
            Text(
              _titleController.text,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (_selectedTags.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedTags
                  .map((tag) {
                    final tagColor = tag.color != null 
                        ? Color(tag.color!) 
                        : Theme.of(context).colorScheme.primary;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: tagColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: tagColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        tag.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: tagColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  })
                  .toList(),
            ),
            const SizedBox(height: 20),
          ],
          Divider(color: Colors.grey.shade300, height: 1),
          const SizedBox(height: 20),
          if (_contentController.text.isEmpty)
            Text(
              'Nothing to preview yet...',
              style: TextStyle(color: Colors.grey.shade400, fontStyle: FontStyle.italic),
            )
          else
            MarkdownBody(
              data: _contentController.text,
              selectable: true,
              styleSheet: MarkdownStyleSheet(
                h1: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                h2: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                h3: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                p: const TextStyle(fontSize: 16, height: 1.5),
                code: TextStyle(
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                  fontFamily: 'monospace',
                ),
                codeblockDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
