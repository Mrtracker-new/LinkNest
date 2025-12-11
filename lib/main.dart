import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linknest/core/theme/app_theme.dart';
import 'package:linknest/presentation/common/scaffold_with_nav.dart';
import 'package:linknest/presentation/feature_home/home_screen.dart';
import 'package:linknest/presentation/feature_links/links_screen.dart';
import 'package:linknest/presentation/feature_docs/docs_screen.dart';
import 'package:linknest/presentation/feature_notes/notes_screen.dart';
import 'package:linknest/presentation/feature_notes/note_editor_screen.dart';
import 'package:linknest/presentation/feature_search/search_screen.dart';
import 'package:linknest/presentation/feature_statistics/statistics_screen.dart';
import 'package:linknest/presentation/feature_tags/tags_screen.dart';
import 'package:linknest/presentation/feature_tags/tag_items_screen.dart';

import 'package:linknest/presentation/feature_settings/settings_screen.dart';
import 'package:linknest/presentation/feature_home/favorites_screen.dart';
import 'package:linknest/presentation/providers/providers.dart';
import 'package:linknest/presentation/widgets/home_widget_manager.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
     GoRoute(
      path: '/notes/edit',
      builder: (context, state) {
        final id = state.uri.queryParameters['id'];
        return NoteEditorScreen(noteId: id);
      },
    ),
    GoRoute(
      path: '/settings', // Settings route
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/favorites',
      builder: (context, state) => const FavoritesScreen(),
    ),
    GoRoute(
      path: '/statistics',
      builder: (context, state) => const StatisticsScreen(),
    ),
    GoRoute(
      path: '/tags',
      builder: (context, state) => const TagsScreen(),
    ),
    GoRoute(
      path: '/tags/:tagId',
      builder: (context, state) {
        final tagId = state.pathParameters['tagId']!;
        return TagItemsScreen(tagId: tagId);
      },
    ),
    ShellRoute(
      builder: (context, state, child) {
        return ScaffoldWithNavBar(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/links',
          builder: (context, state) => const LinksScreen(),
        ),
        GoRoute(
          path: '/docs',
          builder: (context, state) => const DocsScreen(),
        ),
        GoRoute(
          path: '/notes',
          builder: (context, state) => const NotesScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => const SearchScreen(),
    ),
  ],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const ProviderScope(child: LinkNestApp()));
}

class LinkNestApp extends ConsumerStatefulWidget {
  const LinkNestApp({super.key});

  @override
  ConsumerState<LinkNestApp> createState() => _LinkNestAppState();
}

class _LinkNestAppState extends ConsumerState<LinkNestApp> {
  StreamSubscription<Uri?>? _widgetUriSubscription;

  @override
  void initState() {
    super.initState();
    _checkForWidgetLaunch();
    _listenForWidgetClicks();
    _startUriPolling();
  }
  
  // Poll SharedPreferences for widget click URIs
  void _startUriPolling() {
    // Check every 500ms for new widget clicks
    Future.delayed(const Duration(milliseconds: 500), _checkForStoredUri);
  }
  
  Future<void> _checkForStoredUri() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedUri = prefs.getString('HomeWidget.clicked_uri');
      
      if (storedUri != null && storedUri.isNotEmpty) {
        debugPrint('Found stored URI: $storedUri');
        
        // Clear the stored URI immediately
        await prefs.remove('HomeWidget.clicked_uri');
        
        // Parse and handle the URI
        final uri = Uri.parse(storedUri);
        _handleWidgetUri(uri);
      }
    } catch (e) {
      debugPrint('Error checking stored URI: $e');
    }
    
    // Continue polling
    if (mounted) {
      Future.delayed(const Duration(milliseconds: 500), _checkForStoredUri);
    }
  }

  @override
  void dispose() {
    _widgetUriSubscription?.cancel();
    super.dispose();
  }

  // Check if app was launched from widget
  Future<void> _checkForWidgetLaunch() async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final Uri? initialUri = await HomeWidget.initiallyLaunchedFromHomeWidget();
      if (initialUri != null) {
        _handleWidgetUri(initialUri);
      }
    } catch (e) {
      debugPrint('Error checking initial widget URI: $e');
    }
  }

  // Listen for widget clicks while app is running
  void _listenForWidgetClicks() {
    _widgetUriSubscription = HomeWidget.widgetClicked.listen((uri) {
      if (uri != null) {
        _handleWidgetUri(uri);
      }
    });
  }

  // Handle the widget URI and navigate
  void _handleWidgetUri(Uri uri) {
    final path = uri.host;
    final action = uri.queryParameters['action'];
    String? route;
    
    debugPrint('=== Widget Deep Link ===');
    debugPrint('Full URI: $uri');
    debugPrint('Path: $path');
    debugPrint('Action: $action');
    
    switch (path) {
      case 'add_link':
        route = '/links';
        break;
      case 'add_document':
        route = '/docs';
        break;
      case 'add_note':
        route = '/notes/edit';
        break;
    }
    
    if (route != null) {
      // If action is show_dialog, set the pending action
      if (action == 'show_dialog' && path != 'add_note') {
        // For notes, navigation to /notes/edit already opens the editor
        ref.read(pendingWidgetActionProvider.notifier).state = path;
        debugPrint('Set pending action: $path');
      }
      
      // Longer delay to ensure router is ready, especially on cold start
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          debugPrint('Navigating to: $route');
          _router.go(route!);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'LinkNest 2.0',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
