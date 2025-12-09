import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:go_router/go_router.dart';

/// Manages the Quick Add home screen widget
class HomeWidgetManager {
  static const String _widgetName = 'QuickAddWidget';
  
  /// Initialize the home widget and set up listeners
  static Future<void> initialize(BuildContext context) async {
    // Set initial widget data
    await updateWidget();
    
    // Listen for widget interactions
    HomeWidget.widgetClicked.listen((Uri? uri) {
      if (uri != null) {
        _handleWidgetAction(context, uri);
      }
    });
  }
  
  /// Update the widget with latest data
  static Future<void> updateWidget() async {
    try {
      await HomeWidget.saveWidgetData<String>('app_name', 'LinkNest');
      await HomeWidget.updateWidget(
        name: _widgetName,
        androidName: 'QuickAddWidgetProvider',
      );
    } catch (e) {
      debugPrint('Error updating widget: $e');
    }
  }
  
  /// Handle actions from widget button taps
  static void _handleWidgetAction(BuildContext context, Uri uri) {
    final action = uri.host;
    
    switch (action) {
      case 'add_link':
        context.push('/links/add');
        break;
      case 'add_document':
        context.push('/docs/add');
        break;
      case 'add_note':
        context.push('/notes/add');
        break;
      default:
        debugPrint('Unknown widget action: $action');
    }
  }
  
  /// Set up background update callback (if needed in future)
  static Future<void> registerBackgroundCallback() async {
    await HomeWidget.registerBackgroundCallback(_backgroundCallback);
  }
  
  @pragma('vm:entry-point')
  static Future<void> _backgroundCallback(Uri? uri) async {
    // Background tasks if needed
    await updateWidget();
  }
}
