import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linknest/presentation/providers/providers.dart';
import 'package:linknest/presentation/widgets/home_widget_manager.dart';
import 'package:linknest/domain/entities/item.dart';

/// Service to sync statistics data to SharedPreferences for widget consumption
class HomeWidgetDataService {
  final Ref ref;

  HomeWidgetDataService(this.ref) {
    _initialize();
  }

  void _initialize() {
    // Load initial data immediately
    _loadInitialData();
    
    // Listen to all items and update widget data with statistics
    ref.listen(allItemsProvider, (previous, next) {
      next.whenData((items) {
        _updateWidgetData(items);
      });
    });
  }
  
  Future<void> _loadInitialData() async {
    try {
      final items = await ref.read(allItemsProvider.future);
      await _updateWidgetData(items);
    } catch (e) {
      print('Error loading initial widget data: $e');
    }
  }

  Future<void> _updateWidgetData(List<Item> items) async {
    try {
      // Calculate statistics
      final totalItems = items.length;
      final linksCount = items.where((item) => item.type == ItemType.link).length;
      final documentsCount = items.where((item) => item.type == ItemType.document).length;
      final notesCount = items.where((item) => item.type == ItemType.note).length;

      print('🔄 Updating widget data: Total=$totalItems, Links=$linksCount, Docs=$documentsCount, Notes=$notesCount');

      // Update widget using HomeWidgetManager
      await HomeWidgetManager.updateWidget(
        totalItems: totalItems,
        linksCount: linksCount,
        documentsCount: documentsCount,
        notesCount: notesCount,
      );
      
      print('✅ Widget data updated successfully');
    } catch (e) {
      print('❌ Error updating widget data: $e');
    }
  }

  /// Manually trigger an update
  Future<void> forceUpdate() async {
    final items = await ref.read(allItemsProvider.future);
    await _updateWidgetData(items);
  }
}

/// Provider for the widget data service
final homeWidgetDataServiceProvider = Provider<HomeWidgetDataService>((ref) {
  return HomeWidgetDataService(ref);
});
