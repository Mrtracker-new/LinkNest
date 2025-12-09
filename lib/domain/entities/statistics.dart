import 'package:linknest/domain/entities/item.dart';

class VaultStatistics {
  final int totalItems;
  final int linksCount;
  final int documentsCount;
  final int notesCount;
  final int favoritesCount;
  final int tagsCount;
  final int totalStorageBytes;
  final List<TagWithCount> topTags;
  final List<Item> recentItems;

  const VaultStatistics({
    required this.totalItems,
    required this.linksCount,
    required this.documentsCount,
    required this.notesCount,
    required this.favoritesCount,
    required this.tagsCount,
    required this.totalStorageBytes,
    required this.topTags,
    required this.recentItems,
  });

  String get formattedStorage {
    if (totalStorageBytes < 1024) return '$totalStorageBytes B';
    if (totalStorageBytes < 1024 * 1024) {
      return '${(totalStorageBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(totalStorageBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class TagWithCount {
  final Tag tag;
  final int itemCount;

  const TagWithCount({
    required this.tag,
    required this.itemCount,
  });
}
