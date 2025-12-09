import 'package:drift/drift.dart';
// Alias the generated database file to avoid conflicts
import 'package:linknest/data/datasources/local_database.dart';
import 'package:linknest/domain/entities/item.dart';
import 'package:linknest/domain/entities/statistics.dart';
import 'package:linknest/domain/repositories/item_repository.dart';

class ItemRepositoryImpl implements ItemRepository {
  final AppDatabase _db;

  ItemRepositoryImpl(this._db);

  @override
  Future<List<Item>> getAllItems() async {
    final items = await _db.select(_db.items).get();
    final results = <Item>[];
    
    for (final itemRow in items) {
      final details = await _fetchItemDetails(itemRow);
      if (details != null) {
        results.add(details);
      }
    }
    // Sort by recent
    results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return results;
  }
  
  // itemRow is now ItemRow (from local_database.dart, which we renamed)
  Future<Item?> _fetchItemDetails(ItemRow itemRow) async {
      final tags = await (_db.select(_db.itemTags)
        ..where((t) => t.itemId.equals(itemRow.id)))
        .join([innerJoin(_db.tags, _db.tags.id.equalsExp(_db.itemTags.tagId))])
        .map((row) {
          final tagRow = row.readTable(_db.tags);
          // Explicitly use Tag from domain entity
          return Tag(id: tagRow.id, name: tagRow.name, color: tagRow.color);
        }).get();

      if (itemRow.type == 'link') {
         final link = await (_db.select(_db.links)..where((l) => l.id.equals(itemRow.id))).getSingleOrNull();
         if (link == null) return null;
         return LinkItem(
           id: itemRow.id,
           title: itemRow.title,
           description: itemRow.description,
           createdAt: itemRow.createdAt,
           updatedAt: itemRow.updatedAt,
           isFavorite: itemRow.isFavorite,
           tags: tags,
           url: link.url,
           faviconUrl: link.faviconUrl,
         );
      } else if (itemRow.type == 'document') {
         final doc = await (_db.select(_db.documents)..where((d) => d.id.equals(itemRow.id))).getSingleOrNull();
         if (doc == null) return null;
         return DocumentItem(
           id: itemRow.id,
           title: itemRow.title,
           description: itemRow.description,
           createdAt: itemRow.createdAt,
           updatedAt: itemRow.updatedAt,
           isFavorite: itemRow.isFavorite,
           tags: tags,
           filePath: doc.filePath,
           fileType: doc.fileType,
           fileSize: doc.fileSize,
         );
      } else if (itemRow.type == 'note') {
         final note = await (_db.select(_db.notes)..where((n) => n.id.equals(itemRow.id))).getSingleOrNull();
         if (note == null) return null;
         return NoteItem(
           id: itemRow.id,
           title: itemRow.title,
           description: itemRow.description,
           createdAt: itemRow.createdAt,
           updatedAt: itemRow.updatedAt,
           isFavorite: itemRow.isFavorite,
           tags: tags,
           content: note.content,
         );
      }
      return null;
  }

  @override
  Future<void> createItem(Item item) async {
    await _db.transaction(() async {
      await _db.into(_db.items).insert(ItemsCompanion.insert(
        id: item.id,
        type: item.type.name, // 'link', 'document', 'note'
        title: item.title,
        description: Value(item.description),
        createdAt: item.createdAt,
        updatedAt: item.updatedAt,
        isFavorite: Value(item.isFavorite),
      ));

      if (item is LinkItem) {
        await _db.into(_db.links).insert(LinksCompanion.insert(
          id: item.id,
          url: item.url,
          faviconUrl: Value(item.faviconUrl),
        ));
      } else if (item is DocumentItem) {
        await _db.into(_db.documents).insert(DocumentsCompanion.insert(
          id: item.id,
          filePath: item.filePath,
          fileType: item.fileType,
          fileSize: item.fileSize,
        ));
      } else if (item is NoteItem) {
        await _db.into(_db.notes).insert(NotesCompanion.insert(
          id: item.id,
          content: item.content,
        ));
      }

      // Tags
      for (final tag in item.tags) {
        await _db.into(_db.itemTags).insert(ItemTagsCompanion.insert(
          itemId: item.id,
          tagId: tag.id,
        ));
      }
    });
  }

  @override
  Future<List<Item>> getFavorites() async {
      final items = await (_db.select(_db.items)..where((t) => t.isFavorite.equals(true))).get();
      final results = <Item>[];
      for (final i in items) {
          final details = await _fetchItemDetails(i);
          if (details != null) results.add(details);
      }
      return results;
  }
  
  @override
  Future<Item?> getItemById(String id) async {
      final itemRow = await (_db.select(_db.items)..where((t) => t.id.equals(id))).getSingleOrNull();
      if (itemRow == null) return null;
      return _fetchItemDetails(itemRow);
  }

  @override
  Future<List<Item>> getItemsByTag(String tagId) async {
      final rows = await (_db.select(_db.items)
          .join([innerJoin(_db.itemTags, _db.itemTags.itemId.equalsExp(_db.items.id))])
          ..where(_db.itemTags.tagId.equals(tagId)))
          .get();
      
      final results = <Item>[];
      for (final row in rows) {
          final itemRow = row.readTable(_db.items);
          final details = await _fetchItemDetails(itemRow);
          if (details != null) results.add(details);
      }
      return results;
  }

  @override
  Future<List<Item>> getItemsByType(ItemType type) async {
       final items = await (_db.select(_db.items)..where((t) => t.type.equals(type.name))).get();
      final results = <Item>[];
      for (final i in items) {
          final details = await _fetchItemDetails(i);
          if (details != null) results.add(details);
      }
      return results;
  }

  @override
  Future<List<Item>> searchItems(String query) async {
      final q = '%$query%';
      
      // 1. Search in Items (Title, Description)
      final itemsMatches = await (_db.select(_db.items)..where((t) => t.title.like(q) | t.description.like(q))).get();
      
      // 2. Search in Notes (Content)
      final notesMatches = await (_db.select(_db.notes)..where((n) => n.content.like(q))).get();
      
      // 3. Search in Links (URL)
      final linksMatches = await (_db.select(_db.links)..where((l) => l.url.like(q))).get();
      
      // Combine IDs
      final ids = <String>{};
      for (final i in itemsMatches) ids.add(i.id);
      for (final n in notesMatches) ids.add(n.id);
      for (final l in linksMatches) ids.add(l.id);
      
      // Fetch details
      final results = <Item>[];
      for (final id in ids) {
          final itemRow = await (_db.select(_db.items)..where((t) => t.id.equals(id))).getSingleOrNull();
          if (itemRow != null) {
              final details = await _fetchItemDetails(itemRow);
              if (details != null) results.add(details);
          }
      }
      
      // Sort by relevance (simple approach: title match first, then by date)
      // For now just date
       results.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      
      return results;
  }

  @override
  Future<void> updateItem(Item item) async {
      await _db.transaction(() async {
          await (_db.update(_db.items)..where((t) => t.id.equals(item.id))).write(ItemsCompanion(
             title: Value(item.title),
             description: Value(item.description),
             updatedAt: Value(DateTime.now()),
             isFavorite: Value(item.isFavorite),
          ));
          
           if (item is LinkItem) {
              await (_db.update(_db.links)..where((t) => t.id.equals(item.id))).write(LinksCompanion(
                  url: Value(item.url),
                  faviconUrl: Value(item.faviconUrl),
              ));
           } else if (item is NoteItem) {
               await (_db.update(_db.notes)..where((t) => t.id.equals(item.id))).write(NotesCompanion(
                  content: Value(item.content),
              ));
           }
           // Tags: Clear and re-insert
           await (_db.delete(_db.itemTags)..where((t) => t.itemId.equals(item.id))).go();
           for (final tag in item.tags) {
              await _db.into(_db.itemTags).insert(ItemTagsCompanion.insert(
                itemId: item.id,
                tagId: tag.id,
              ));
           }
      });
  }

  @override
  Future<void> deleteItem(String id) async {
      await _db.transaction(() async {
          await (_db.delete(_db.itemTags)..where((t) => t.itemId.equals(id))).go();
          await (_db.delete(_db.links)..where((t) => t.id.equals(id))).go();
          await (_db.delete(_db.documents)..where((t) => t.id.equals(id))).go();
          await (_db.delete(_db.notes)..where((t) => t.id.equals(id))).go();
          await (_db.delete(_db.items)..where((t) => t.id.equals(id))).go();
      });
  }

  @override
  Future<List<Tag>> getAllTags() async {
      final rows = await _db.select(_db.tags).get();
      return rows.map((r) => Tag(id: r.id, name: r.name, color: r.color)).toList();
  }

  @override
  Future<void> createTag(Tag tag) async {
      await _db.into(_db.tags).insert(TagsCompanion.insert(
          id: tag.id,
          name: tag.name,
          color: Value(tag.color),
      ));
  }

  @override
  Future<void> deleteTag(String tagId) async {
      await (_db.delete(_db.itemTags)..where((t) => t.tagId.equals(tagId))).go();
      await (_db.delete(_db.tags)..where((t) => t.id.equals(tagId))).go();
  }

  @override
  Future<VaultStatistics> getStatistics() async {
    // Get all items
    final allItems = await getAllItems();
    
    // Count by type
    final links = allItems.where((i) => i.type == ItemType.link).length;
    final docs = allItems.where((i) => i.type == ItemType.document).length;
    final notes = allItems.where((i) => i.type == ItemType.note).length;
    
    // Count favorites
    final favorites = allItems.where((i) => i.isFavorite).length;
    
    // Get all tags
    final allTags = await getAllTags();
    
    // Calculate storage (sum of document sizes)
    int totalStorage = 0;
    for (final item in allItems) {
      if (item is DocumentItem) {
        totalStorage += item.fileSize;
      }
    }
    
    // Get top tags with counts
    final tagCounts = <String, int>{};
    for (final item in allItems) {
      for (final tag in item.tags) {
        tagCounts[tag.id] = (tagCounts[tag.id] ?? 0) + 1;
      }
    }
    
    // Sort and get top 5 tags
    final topTagsList = <TagWithCount>[];
    for (final tag in allTags) {
      final count = tagCounts[tag.id] ?? 0;
      if (count > 0) {
        topTagsList.add(TagWithCount(tag: tag, itemCount: count));
      }
    }
    topTagsList.sort((a, b) => b.itemCount.compareTo(a.itemCount));
    final topTags = topTagsList.take(5).toList();
    
    // Get recent items (last 10)
    final recentItems = List<Item>.from(allItems);
    recentItems.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final recent = recentItems.take(10).toList();
    
    return VaultStatistics(
      totalItems: allItems.length,
      linksCount: links,
      documentsCount: docs,
      notesCount: notes,
      favoritesCount: favorites,
      tagsCount: allTags.length,
      totalStorageBytes: totalStorage,
      topTags: topTags,
      recentItems: recent,
    );
  }
}
