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
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (c, i) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = items[index];
              IconData icon;
              if (item is LinkItem) icon = Icons.link;
              else if (item is DocumentItem) icon = Icons.description;
              else icon = Icons.edit_note;

              return ListTile(
                leading: Icon(icon),
                title: Text(item.title),
                subtitle: Text(item.type.name.toUpperCase()),
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
              ).animate().fadeIn(duration: 300.ms, delay: (index * 50).ms);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
