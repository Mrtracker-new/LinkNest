import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';

/// Manages the Statistics home screen widget
class HomeWidgetManager {
  static const String _widgetName = 'StatsWidget';
  
  /// Initialize the home widget
  static Future<void> initialize() async {
    // Set initial widget data
    await updateWidget(
      totalItems: 0,
      linksCount: 0,
      documentsCount: 0,
      notesCount: 0,
    );
  }
  
  /// Update the widget with latest statistics
  static Future<void> updateWidget({
    required int totalItems,
    required int linksCount,
    required int documentsCount,
    required int notesCount,
  }) async {
    try {
      // Save statistics to SharedPreferences for widget
      await HomeWidget.saveWidgetData<int>('widget_total_items', totalItems);
      await HomeWidget.saveWidgetData<int>('widget_links_count', linksCount);
      await HomeWidget.saveWidgetData<int>('widget_documents_count', documentsCount);
      await HomeWidget.saveWidgetData<int>('widget_notes_count', notesCount);
      
      // Save last updated timestamp
      final now = DateFormat('HH:mm').format(DateTime.now());
      await HomeWidget.saveWidgetData<String>('widget_last_updated', now);
      
      // Trigger widget update
      await HomeWidget.updateWidget(
        name: _widgetName,
        androidName: 'StatsWidgetProvider',
      );
    } catch (e) {
      debugPrint('Error updating widget: $e');
    }
  }
}
