import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:linknest/presentation/providers/providers.dart';
import 'package:linknest/presentation/widgets/home_widget_data_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _appVersion = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          // Header Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primaryContainer,
                  colorScheme.secondaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 64,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  'LinkNest',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your Private Knowledge Vault',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version $_appVersion',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onPrimaryContainer.withOpacity(0.5),
                      ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).scale(),

          // Appearance Section
          _buildSectionHeader(context, 'Appearance', Icons.palette),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: const Text('Light Mode'),
                  subtitle: const Text('Bright and clean'),
                  secondary: const Icon(Icons.light_mode),
                  value: ThemeMode.light,
                  groupValue: themeMode,
                  onChanged: (value) {
                    HapticFeedback.selectionClick();
                    ref.read(themeModeProvider.notifier).state = value!;
                  },
                ),
                const Divider(height: 1),
                RadioListTile<ThemeMode>(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Easy on the eyes'),
                  secondary: const Icon(Icons.dark_mode),
                  value: ThemeMode.dark,
                  groupValue: themeMode,
                  onChanged: (value) {
                    HapticFeedback.selectionClick();
                    ref.read(themeModeProvider.notifier).state = value!;
                  },
                ),
                const Divider(height: 1),
                RadioListTile<ThemeMode>(
                  title: const Text('System'),
                  subtitle: const Text('Follow device settings'),
                  secondary: const Icon(Icons.settings_suggest),
                  value: ThemeMode.system,
                  groupValue: themeMode,
                  onChanged: (value) {
                    HapticFeedback.selectionClick();
                    ref.read(themeModeProvider.notifier).state = value!;
                  },
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 100.ms),

          // Data Management Section
          _buildSectionHeader(context, 'Data Management', Icons.storage),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.upload_file),
                  title: const Text('Export Data'),
                  subtitle: const Text('Backup your vault'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _exportData(context);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('Import Data'),
                  subtitle: const Text('Restore from backup'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _importData(context);
                  },
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 150.ms),

          // Statistics Section
          _buildSectionHeader(context, 'Information', Icons.info_outline),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: FutureBuilder(
              future: _getStorageStats(),
              builder: (context, snapshot) {
                final stats = snapshot.data ?? {'items': 0, 'size': '0 KB'};
                return Column(
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.inventory_2, color: colorScheme.primary),
                      ),
                      title: const Text('Total Items'),
                      trailing: Text(
                        '${stats['items']}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.sd_storage, color: colorScheme.secondary),
                      ),
                      title: const Text('Storage Used'),
                      trailing: Text(
                        stats['size'] as String,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.secondary,
                            ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 200.ms),

          // About Section
          _buildSectionHeader(context, 'About', Icons.app_settings_alt),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _showPrivacyInfo(context);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('Licenses'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    showLicensePage(
                      context: context,
                      applicationName: 'LinkNest',
                      applicationVersion: _appVersion,
                      applicationIcon: const Icon(Icons.lock_outline, size: 48),
                    );
                  },
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 250.ms),

          // About the Developer Section
          _buildSectionHeader(context, 'About the Developer', Icons.person),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primaryContainer,
                              colorScheme.secondaryContainer,
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.code,
                          color: colorScheme.primary,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rolan Lobo',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              'Software Engineer & Creator',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Passionate about turning ideas into smart, functional, and visually engaging digital experiences. '
                    'Constantly learning, creating, and exploring new technologies to bring fresh ideas to life.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                        ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.code_rounded),
                    title: const Text('GitHub'),
                    subtitle: const Text('Mrtracker-new'),
                    trailing: const Icon(Icons.open_in_new, size: 18),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _launchURL('https://github.com/Mrtracker-new');
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.web),
                    title: const Text('Portfolio'),
                    subtitle: const Text('rolan-rnr.netlify.app'),
                    trailing: const Icon(Icons.open_in_new, size: 18),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _launchURL('https://rolan-rnr.netlify.app/');
                    },
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 300.ms),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _getStorageStats() async {
    try {
      final stats = await ref.read(statisticsProvider.future);
      return {
        'items': stats.totalItems,
        'size': stats.formattedStorage,
      };
    } catch (e) {
      return {
        'items': 0,
        'size': '0 KB',
      };
    }
  }

  Future<void> _exportData(BuildContext context) async {
    try {
      final exportService = ref.read(exportServiceProvider);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Exporting data...'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      // Save to Downloads
      final filePath = await exportService.exportToFile();

      // Also open share dialog
      await exportService.shareExport();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved to Downloads:\n${filePath.split('/').last}'),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _importData(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) return;

      final filePath = result.files.first.path;
      if (filePath == null) return;

      final confirm = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Import Data?'),
          content: const Text(
            'This will import items from the backup file. Existing items with the same ID will be skipped.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Import'),
            ),
          ],
        ),
      );

      if (confirm != true || !context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Importing data...'),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );

      final exportService = ref.read(exportServiceProvider);
      final importResult = await exportService.importFromFile(filePath);

      // Refresh all providers
      ref.invalidate(allItemsProvider); // Widget service listens to this!
      ref.invalidate(linksProvider);
      ref.invalidate(docsProvider);
      ref.invalidate(notesProvider);
      ref.invalidate(tagsProvider);
      ref.invalidate(favoritesProvider);
      ref.invalidate(recentItemsProvider);
      ref.invalidate(statisticsProvider);
      
      // Manually update widget after import
      try {
        await ref.read(homeWidgetDataServiceProvider).forceUpdate();
        print('🔄 Widget manually updated after import');
      } catch (e) {
        print('⚠️ Failed to update widget after import: $e');
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(importResult.message),
            backgroundColor: importResult.success ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import failed: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showPrivacyInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.privacy_tip, size: 48),
        title: const Text('Privacy First'),
        content: const Text(
          'LinkNest stores all your data locally on your device. '
          'Nothing is uploaded to any server. '
          'Your links, documents, and notes stay completely private and secure.',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
