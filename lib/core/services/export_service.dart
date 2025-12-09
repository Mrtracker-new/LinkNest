import 'dart:convert';
import 'dart:io';
import 'package:linknest/core/constants/app_constants.dart';
import 'package:linknest/domain/entities/item.dart';
import 'package:linknest/domain/repositories/item_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

class ExportService {
  final ItemRepository _repository;

  ExportService(this._repository);

  /// Export all data to JSON
  Future<Map<String, dynamic>> exportToJson() async {
    final allItems = await _repository.getAllItems();
    final allTags = await _repository.getAllTags();

    return {
      'version': AppConstants.appVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'tags': allTags.map((tag) => _tagToJson(tag)).toList(),
      'items': allItems.map((item) => _itemToJson(item)).toList(),
    };
  }

  /// Export to file and return file path
  Future<String> exportToFile() async {
    final data = await exportToJson();
    final jsonString = const JsonEncoder.withIndent('  ').convert(data);

    // Save to Downloads folder for easy access
    Directory? downloadsDir;
    if (Platform.isAndroid) {
      downloadsDir = Directory('/storage/emulated/0/Download');
    } else {
      downloadsDir = await getDownloadsDirectory();
    }
    
    if (downloadsDir == null || !await downloadsDir.exists()) {
      // Fallback to app documents if Downloads not accessible
      final appDir = await getApplicationDocumentsDirectory();
      downloadsDir = Directory(p.join(appDir.path, AppConstants.backupSubfolder));
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }
    }

    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
    final fileName = '${AppConstants.exportFileName}_$timestamp${AppConstants.exportFileExtension}';
    final filePath = p.join(downloadsDir.path, fileName);

    final file = File(filePath);
    await file.writeAsString(jsonString);

    return filePath;
  }

  /// Share export file
  Future<void> shareExport() async {
    final filePath = await exportToFile();
    await Share.shareXFiles(
      [XFile(filePath)],
      subject: 'LinkNest Backup - ${DateTime.now().toLocal()}',
      text: 'Your LinkNest vault backup',
    );
  }

  /// Import data from JSON
  Future<ImportResult> importFromJson(Map<String, dynamic> data) async {
    try {
      final List<dynamic> tagsJson = data['tags'] ?? [];
      final List<dynamic> itemsJson = data['items'] ?? [];

      int tagsImported = 0;
      int itemsImported = 0;
      int tagsSkipped = 0;
      int itemsSkipped = 0;

      // Import tags first
      final existingTags = await _repository.getAllTags();
      final existingTagIds = existingTags.map((t) => t.id).toSet();

      for (final tagJson in tagsJson) {
        try {
          final tag = _tagFromJson(tagJson);
          if (!existingTagIds.contains(tag.id)) {
            await _repository.createTag(tag);
            tagsImported++;
          } else {
            tagsSkipped++;
          }
        } catch (e) {
          // Skip invalid tag
          tagsSkipped++;
        }
      }

      // Import items
      final existingItems = await _repository.getAllItems();
      final existingItemIds = existingItems.map((i) => i.id).toSet();

      for (final itemJson in itemsJson) {
        try {
          final item = _itemFromJson(itemJson);
          if (!existingItemIds.contains(item.id)) {
            await _repository.createItem(item);
            itemsImported++;
          } else {
            itemsSkipped++;
          }
        } catch (e) {
          // Skip invalid item
          itemsSkipped++;
        }
      }

      return ImportResult(
        success: true,
        tagsImported: tagsImported,
        itemsImported: itemsImported,
        tagsSkipped: tagsSkipped,
        itemsSkipped: itemsSkipped,
      );
    } catch (e) {
      return ImportResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Import from file
  Future<ImportResult> importFromFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return ImportResult(
          success: false,
          error: 'File not found: $filePath',
        );
      }

      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      
      return await importFromJson(data);
    } catch (e) {
      return ImportResult(
        success: false,
        error: 'Failed to parse file: $e',
      );
    }
  }

  // Serialization helpers
  Map<String, dynamic> _tagToJson(Tag tag) {
    return {
      'id': tag.id,
      'name': tag.name,
      'color': tag.color,
    };
  }

  Tag _tagFromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as int?,
    );
  }

  Map<String, dynamic> _itemToJson(Item item) {
    final baseData = {
      'id': item.id,
      'type': item.type.name,
      'title': item.title,
      'description': item.description,
      'createdAt': item.createdAt.toIso8601String(),
      'updatedAt': item.updatedAt.toIso8601String(),
      'isFavorite': item.isFavorite,
      'tags': item.tags.map((t) => t.id).toList(),
    };

    if (item is LinkItem) {
      baseData['url'] = item.url;
      baseData['faviconUrl'] = item.faviconUrl;
    } else if (item is DocumentItem) {
      baseData['filePath'] = item.filePath;
      baseData['fileType'] = item.fileType;
      baseData['fileSize'] = item.fileSize;
    } else if (item is NoteItem) {
      baseData['content'] = item.content;
    }

    return baseData;
  }

  Item _itemFromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String;
    final type = ItemType.values.firstWhere((t) => t.name == typeStr);

    // Tags will be empty initially during import
    final tags = <Tag>[];

    final baseData = {
      'id': json['id'] as String,
      'title': json['title'] as String,
      'description': json['description'] as String?,
      'createdAt': DateTime.parse(json['createdAt']),
      'updatedAt': DateTime.parse(json['updatedAt']),
      'isFavorite': json['isFavorite'] as bool? ?? false,
      'tags': tags,
    };

    switch (type) {
      case ItemType.link:
        return LinkItem(
          id: baseData['id']! as String,
          title: baseData['title']! as String,
          description: baseData['description'] as String?,
          createdAt: baseData['createdAt']! as DateTime,
          updatedAt: baseData['updatedAt']! as DateTime,
          isFavorite: baseData['isFavorite']! as bool,
          tags: baseData['tags']! as List<Tag>,
          url: json['url'] as String,
          faviconUrl: json['faviconUrl'] as String?,
        );

      case ItemType.document:
        return DocumentItem(
          id: baseData['id']! as String,
          title: baseData['title']! as String,
          description: baseData['description'] as String?,
          createdAt: baseData['createdAt']! as DateTime,
          updatedAt: baseData['updatedAt']! as DateTime,
          isFavorite: baseData['isFavorite']! as bool,
          tags: baseData['tags']! as List<Tag>,
          filePath: json['filePath'] as String,
          fileType: json['fileType'] as String,
          fileSize: json['fileSize'] as int,
        );

      case ItemType.note:
        return NoteItem(
          id: baseData['id']! as String,
          title: baseData['title']! as String,
          description: baseData['description'] as String?,
          createdAt: baseData['createdAt']! as DateTime,
          updatedAt: baseData['updatedAt']! as DateTime,
          isFavorite: baseData['isFavorite']! as bool,
          tags: baseData['tags']! as List<Tag>,
          content: json['content'] as String,
        );
    }
  }
}

class ImportResult {
  final bool success;
  final int tagsImported;
  final int itemsImported;
  final int tagsSkipped;
  final int itemsSkipped;
  final String? error;

  ImportResult({
    required this.success,
    this.tagsImported = 0,
    this.itemsImported = 0,
    this.tagsSkipped = 0,
    this.itemsSkipped = 0,
    this.error,
  });

  String get message {
    if (!success) {
      return 'Import failed: $error';
    }
    final baseMessage = 'Imported $itemsImported items and $tagsImported tags';
    final skippedInfo = (itemsSkipped > 0 || tagsSkipped > 0)
        ? ' (Skipped: $itemsSkipped items, $tagsSkipped tags)'
        : '';
    return baseMessage + skippedInfo;
  }
}
