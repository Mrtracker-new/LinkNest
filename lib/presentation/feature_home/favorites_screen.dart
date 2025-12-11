import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linknest/domain/entities/item.dart';
import 'package:linknest/presentation/common/app_actions.dart';
import 'package:linknest/presentation/providers/providers.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: favoritesAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No favorites yet'));
          }
          return ListView.builder(
            itemCount: items.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final item = items[index];
              IconData icon;
              Color color;
              
              if (item is LinkItem) {
                icon = Icons.link;
                color = Colors.red;
              } else if (item is DocumentItem) {
                icon = Icons.description;
                color = Colors.orange;
              } else {
                icon = Icons.edit_note;
                color = Colors.purple;
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(
                    item.type.name.toUpperCase(),
                    style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.star, color: Colors.orange),
                    onPressed: () async {
                      final repo = ref.read(itemRepositoryProvider);
                      Item? updatedItem;
                      if (item is LinkItem) {
                        updatedItem = item.copyWith(isFavorite: false);
                      } else if (item is NoteItem) {
                        updatedItem = item.copyWith(isFavorite: false);
                      } else if (item is DocumentItem) {
                        updatedItem = item.copyWith(isFavorite: false);
                      }
                      
                      if (updatedItem != null) {
                        await repo.updateItem(updatedItem);
                        // Refresh necessary providers
                        ref.invalidate(favoritesProvider);
                        ref.invalidate(linksProvider);
                        ref.invalidate(notesProvider);
                        ref.invalidate(docsProvider); 
                        ref.invalidate(recentItemsProvider);
                      }
                    },
                  ),
                  onTap: () => AppActions.openItem(context, item),
                ),
              ).animate().fadeIn(duration: 300.ms, delay: (index * 50).ms).slideX(begin: 0.1);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
