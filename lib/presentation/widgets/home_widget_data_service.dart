import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:linknest/presentation/providers/providers.dart';
import 'dart:convert';

/// Service to sync recent items data to SharedPreferences for widget consumption
class HomeWidgetDataService {
  final Ref ref;

  HomeWidgetDataService(this.ref) {
    _initialize();
  }

  void _initialize() {
    // Listen to all items and update widget data
    ref.listen(allItemsProvider, (previous, next) {
      next.whenData((items) {
        _updateWidgetData(items);
      });
    });
  }

  Future<void> _updateWidgetData(List items) async {
    try {
      // Sort by most recent and take top 3
      final sortedItems = List.from(items);
      sortedItems.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      final recentItems = sortedItems.take(3).toList();

      // Convert to JSON
      final itemsJson = recentItems.map((item) {
        return {
          'id': item.id,
          'title': item.title,
          'type': item.type.name,
          'timestamp': item.updatedAt.millisecondsSinceEpoch,
        };
      }).toList();

      // Save to SharedPreferences using home_widget plugin
      await HomeWidget.saveWidgetData<String>(
        'recent_items',
        jsonEncode(itemsJson),
      );

      // Update widget
      await HomeWidget.updateWidget(
        androidName: 'QuickAddWidgetProvider',
      );
    } catch (e) {
      // Silently fail - widget data update is not critical
      print('Error updating widget data: $e');
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
