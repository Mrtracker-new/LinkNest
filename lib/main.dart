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
    String? route;
    
    debugPrint('Widget clicked with URI: $uri');
    
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
      // Delay navigation to ensure router is ready
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
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
