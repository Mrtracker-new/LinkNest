import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linknest/core/services/export_service.dart';
import 'package:linknest/data/datasources/local_database.dart';
import 'package:linknest/data/repositories/item_repository_impl.dart';
import 'package:linknest/domain/entities/item.dart';
import 'package:linknest/domain/entities/statistics.dart';
import 'package:linknest/domain/repositories/item_repository.dart';

// Theme Mode Provider
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

// Pending Widget Action Provider (for triggering dialogs from widget)
final pendingWidgetActionProvider = StateProvider<String?>((ref) => null);

// Database Provider
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

// Repository Provider
final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ItemRepositoryImpl(db);
});

// Feature Variables / Providers

final linksProvider = FutureProvider<List<Item>>((ref) async {
  final repo = ref.watch(itemRepositoryProvider);
  return repo.getItemsByType(ItemType.link);
});

final docsProvider = FutureProvider<List<Item>>((ref) async {
  final repo = ref.watch(itemRepositoryProvider);
  return repo.getItemsByType(ItemType.document);
});

final notesProvider = FutureProvider<List<Item>>((ref) async {
  final repo = ref.watch(itemRepositoryProvider);
  return repo.getItemsByType(ItemType.note);
});

final uniqueSearchProvider = FutureProvider.autoDispose.family<List<Item>, String>((ref, query) async {
  if (query.isEmpty) return [];
  final repo = ref.watch(itemRepositoryProvider);
  return repo.searchItems(query);
});

final recentItemsProvider = FutureProvider<List<Item>>((ref) async {
  final repo = ref.watch(itemRepositoryProvider);
  final items = await repo.getAllItems();
  items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  return items.take(5).toList();
});

final tagsProvider = FutureProvider<List<Tag>>((ref) async {
  final repo = ref.watch(itemRepositoryProvider);
  return repo.getAllTags();
});

final favoritesProvider = FutureProvider<List<Item>>((ref) async {
  final repo = ref.watch(itemRepositoryProvider);
  return repo.getFavorites();
});

final statisticsProvider = FutureProvider<VaultStatistics>((ref) async {
  final repo = ref.watch(itemRepositoryProvider);
  return repo.getStatistics();
});

// All items provider (for tag counting, etc.)
final allItemsProvider = FutureProvider<List<Item>>((ref) async {
  final repo = ref.watch(itemRepositoryProvider);
  return repo.getAllItems();
});

// Tag items provider - get items by tag ID
final tagItemsProvider = FutureProvider.autoDispose.family<List<Item>, String>((ref, tagId) async {
  final repo = ref.watch(itemRepositoryProvider);
  return repo.getItemsByTag(tagId);
});

// Export Service Provider
final exportServiceProvider = Provider((ref) {
  final repo = ref.watch(itemRepositoryProvider);
  return ExportService(repo);
});
