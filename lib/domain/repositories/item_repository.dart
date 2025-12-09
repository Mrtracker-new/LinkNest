import 'package:linknest/domain/entities/item.dart';
import 'package:linknest/domain/entities/statistics.dart';

abstract class ItemRepository {
  Future<List<Item>> getAllItems();
  Future<List<Item>> getItemsByType(ItemType type);
  Future<List<Item>> getFavorites();
  Future<List<Item>> getItemsByTag(String tagId);
  Future<List<Item>> searchItems(String query);
  Future<Item?> getItemById(String id);
  
  Future<void> createItem(Item item);
  Future<void> updateItem(Item item);
  Future<void> deleteItem(String id);
  
  Future<List<Tag>> getAllTags();
  Future<void> createTag(Tag tag);
  Future<void> deleteTag(String tagId);
  
  // Statistics
  Future<VaultStatistics> getStatistics();
}
