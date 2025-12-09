import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:linknest/domain/entities/item.dart';
import 'package:linknest/presentation/common/app_actions.dart';
import 'package:linknest/presentation/providers/providers.dart';

enum SearchFilterType { all, links, documents, notes }

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  SearchFilterType _selectedType = SearchFilterType.all;
  bool _favoritesOnly = false;
  String? _selectedTag;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Item> _filterResults(List<Item> items) {
    var filtered = items.where((item) {
      // Text search
      final matchesQuery = _query.isEmpty ||
          item.title.toLowerCase().contains(_query.toLowerCase()) ||
          (item.description?.toLowerCase().contains(_query.toLowerCase()) ?? false);

      // Type filter
      final matchesType = _selectedType == SearchFilterType.all ||
          (_selectedType == SearchFilterType.links && item.type == ItemType.link) ||
          (_selectedType == SearchFilterType.documents && item.type == ItemType.document) ||
          (_selectedType == SearchFilterType.notes && item.type == ItemType.note);

      // Favorites filter
      final matchesFavorite = !_favoritesOnly || item.isFavorite;

      // Tag filter
      final matchesTag = _selectedTag == null ||
          item.tags.any((tag) => tag.id == _selectedTag);

      return matchesQuery && matchesType && matchesFavorite && matchesTag;
    }).toList();

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final searchAsync = ref.watch(uniqueSearchProvider(_query));
    final tagsAsync = ref.watch(tagsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search your vault...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _query = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              onChanged: (value) {
                setState(() => _query = value);
              },
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _selectedType == SearchFilterType.all,
                  onSelected: (_) => setState(() => _selectedType = SearchFilterType.all),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [Icon(Icons.link, size: 16), SizedBox(width: 4), Text('Links')],
                  ),
                  selected: _selectedType == SearchFilterType.links,
                  onSelected: (_) => setState(() => _selectedType = SearchFilterType.links),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [Icon(Icons.description, size: 16), SizedBox(width: 4), Text('Docs')],
                  ),
                  selected: _selectedType == SearchFilterType.documents,
                  onSelected: (_) => setState(() => _selectedType = SearchFilterType.documents),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [Icon(Icons.edit_note, size: 16), SizedBox(width: 4), Text('Notes')],
                  ),
                  selected: _selectedType == SearchFilterType.notes,
                  onSelected: (_) => setState(() => _selectedType = SearchFilterType.notes),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [Icon(Icons.star, size: 16), SizedBox(width: 4), Text('Favorites')],
                  ),
                  selected: _favoritesOnly,
                  onSelected: (selected) => setState(() => _favoritesOnly = selected),
                ),
              ],
            ),
          ),

          // Tag Filter
          tagsAsync.when(
            data: (tags) {
              if (tags.isEmpty) return const SizedBox.shrink();
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.label, size: 16),
                        const SizedBox(width: 4),
                        const Text('Filter by tag:', style: TextStyle(fontSize: 12)),
                        if (_selectedTag != null) ...[
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () => setState(() => _selectedTag = null),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              minimumSize: const Size(0, 24),
                            ),
                            child: const Text('Clear', style: TextStyle(fontSize: 11)),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: tags.map((tag) {
                        final isSelected = _selectedTag == tag.id;
                        final tagColor = tag.color != null 
                            ? Color(tag.color!) 
                            : Theme.of(context).colorScheme.primary;
                        
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            avatar: CircleAvatar(
                              backgroundColor: tagColor,
                              radius: 8,
                            ),
                            label: Text(tag.name),
                            selected: isSelected,
                            onSelected: (_) {
                              setState(() {
                                _selectedTag = isSelected ? null : tag.id;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          const SizedBox(height: 8),

          // Results
          Expanded(
            child: (_query.isEmpty && _selectedTag == null && !_favoritesOnly && _selectedType == SearchFilterType.all)
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'Start searching or filtering',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.grey,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Use search or filters above',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                : ref.watch(_query.isNotEmpty ? uniqueSearchProvider(_query) : allItemsProvider).when(
                    data: (searchResults) {
                      final results = _filterResults(searchResults);

                      if (results.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              Text(
                                'No results found',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: Colors.grey,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try different keywords or filters',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final item = results[index];
                          return _buildResultCard(item).animate().fadeIn(duration: 200.ms);
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, s) => Center(child: Text('Error: $e')),
                  ),
          ),
        ],
      ),
    );
  }

  // Helper to extract domain from URL
  String _getDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.replaceAll('www.', '');
    } catch (e) {
      return url;
    }
  }

  // Helper to get color and icon based on domain (same as links_screen.dart)
  (IconData, Color) _getLinkStyle(String url) {
    final domain = _getDomain(url).toLowerCase();
    
    if (domain.contains('github')) {
      return (Icons.code, Colors.black);
    } else if (domain.contains('youtube') || domain.contains('youtu.be')) {
      return (Icons.play_circle, Colors.red);
    } else if (domain.contains('twitter') || domain.contains('x.com')) {
      return (Icons.tag, Colors.blue);
    } else if (domain.contains('linkedin')) {
      return (Icons.work, Colors.blue.shade700);
    } else if (domain.contains('medium') || domain.contains('dev.to')) {
      return (Icons.article, Colors.green.shade700);
    } else if (domain.contains('stackoverflow')) {
      return (Icons.question_answer, Colors.orange);
    } else if (domain.contains('reddit')) {
      return (Icons.forum, Colors.deepOrange);
    } else if (domain.contains('docs.') || domain.contains('documentation')) {
      return (Icons.menu_book, Colors.indigo);
    } else {
      return (Icons.language, Colors.blue);
    }
  }

  Widget _buildResultCard(Item item) {
    IconData icon;
    Color color;

    switch (item.type) {
      case ItemType.link:
        // Use domain-based styling for links
        if (item is LinkItem) {
          final style = _getLinkStyle(item.url);
          icon = style.$1;
          color = style.$2;
        } else {
          icon = Icons.link;
          color = Colors.blue;
        }
        break;
      case ItemType.document:
        icon = Icons.description;
        color = Colors.orange;
        break;
      case ItemType.note:
        icon = Icons.edit_note;
        color = Colors.purple;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          item.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: item.description != null
            ? Text(
                item.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: item.isFavorite
            ? const Icon(Icons.star, color: Colors.orange, size: 20)
            : null,
        onTap: () => _openItem(item),
      ),
    );
  }

  void _openItem(Item item) {
    switch (item.type) {
      case ItemType.link:
        if (item is LinkItem) AppActions.openItem(context, item);
        break;
      case ItemType.document:
        if (item is DocumentItem) AppActions.openItem(context, item);
        break;
      case ItemType.note:
        context.push('/notes/edit?id=${item.id}');
        break;
    }
  }
}
