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
  ];

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
