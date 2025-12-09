import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'LinkNest';
  static const String appVersion = '2.0.0';
  static const String appTagline = 'Your Offline Knowledge Vault';

  // Recent Items
  static const int recentItemsCount = 10;
  static const int homeRecentItemsCount = 5;

  // Tag Colors
  static const List<Color> tagColors = [
    Color(0xFF2196F3), // Blue
    Color(0xFF4CAF50), // Green
    Color(0xFFF44336), // Red
    Color(0xFFFF9800), // Orange
    Color(0xFF9C27B0), // Purple
    Color(0xFF00BCD4), // Cyan
    Color(0xFFFFEB3B), // Yellow
    Color(0xFFE91E63), // Pink
    Color(0xFF795548), // Brown
    Color(0xFF607D8B), // Blue Grey
    Color(0xFFFF5722), // Deep Orange
    Color(0xFF3F51B5), // Indigo
    Color(0xFF009688), // Teal
    Color(0xFFCDDC39), // Lime
    Color(0xFFFFC107), // Amber
  ];

  // Named tag colors with labels for display
  static const Map<String, Color> namedTagColors = {
    'Red': Color(0xFFF44336),
    'Orange': Color(0xFFFF9800),
    'Yellow': Color(0xFFFFEB3B),
    'Green': Color(0xFF4CAF50),
    'Teal': Color(0xFF009688),
    'Blue': Color(0xFF2196F3),
    'Indigo': Color(0xFF3F51B5),
    'Purple': Color(0xFF9C27B0),
    'Pink': Color(0xFFE91E63),
    'Brown': Color(0xFF795548),
    'Grey': Color(0xFF607D8B),
  };

  // Semantic tag color suggestions based on tag name
  static Color? getSuggestedColorForTag(String tagName) {
    final name = tagName.toLowerCase();
    
    // Important/Urgent
    if (name.contains('important') || name.contains('urgent') || name.contains('critical')) {
      return const Color(0xFFF44336); // Red
    }
    // Work/Business
    if (name.contains('work') || name.contains('business') || name.contains('job')) {
      return const Color(0xFF2196F3); // Blue
    }
    // Personal
    if (name.contains('personal') || name.contains('private')) {
      return const Color(0xFF9C27B0); // Purple
    }
    // Ideas/Creative
    if (name.contains('idea') || name.contains('creative') || name.contains('inspiration')) {
      return const Color(0xFFFFEB3B); // Yellow
    }
    // Learning/Education
    if (name.contains('learn') || name.contains('education') || name.contains('study') || name.contains('tutorial')) {
      return const Color(0xFF4CAF50); // Green
    }
    // Todo/Task
    if (name.contains('todo') || name.contains('task') || name.contains('action')) {
      return const Color(0xFFFF9800); // Orange
    }
    // Archive/Old
    if (name.contains('archive') || name.contains('old') || name.contains('past')) {
      return const Color(0xFF607D8B); // Grey
    }
    // Favorite/Star
    if (name.contains('favorite') || name.contains('star') || name.contains('best')) {
      return const Color(0xFFE91E63); // Pink
    }
    
    return null; // No suggestion, let user pick
  }

  // Storage
  static const String docsSubfolder = 'docs';
  static const String backupSubfolder = 'backups';

  // Export/Import
  static const String exportFileName = 'linknest_backup';
  static const String exportFileExtension = '.json';
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // File Size Limits (in bytes)
  static const int maxDocumentSize = 100 * 1024 * 1024; // 100 MB

  // Search
  static const int searchDebounceMs = 300;
  static const int minSearchLength = 2;
}
