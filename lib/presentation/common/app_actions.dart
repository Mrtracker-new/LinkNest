import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:linknest/domain/entities/item.dart';
import 'package:linknest/presentation/providers/providers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import 'package:open_file/open_file.dart';

class AppActions {

  static Future<void> openItem(BuildContext context, Item item) async {
    await HapticFeedback.lightImpact();
    if (item is LinkItem) {
      final uri = Uri.parse(item.url);
      try {
          if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
             throw 'Could not launch $uri';
          }
      } catch (e) {
        if (context.mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    } else if (item is DocumentItem) {
         await openDocument(context, item);
    } else if (item is NoteItem) {
      context.push('/notes/edit?id=${item.id}');
    }
  }
  
  static Future<void> openDocument(BuildContext context, DocumentItem item) async {
     try {
       // Copy to temp directory first to ensure external apps can read it
       // (Private app storage is often not accessible by default external viewers)
       final tempDir = await getTemporaryDirectory();
       final tempFile = File(p.join(tempDir.path, p.basename(item.filePath)));
       
       final originalFile = File(item.filePath);
       if (await originalFile.exists()) {
           await originalFile.copy(tempFile.path);
           
           final result = await OpenFile.open(tempFile.path);
           if (result.type != ResultType.done) {
              // Fallback to share
              if (context.mounted) {
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Opening failed (${result.message}). Trying Share...')));
                 await Share.shareXFiles([XFile(item.filePath)], text: item.title);
              }
           }
       } else {
           if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('File not found at ${item.filePath}')));
           }
       }
     } catch (e) {
        // Fallback to share on exception
        if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open directly. Sharing instead...')));
            try {
               await Share.shareXFiles([XFile(item.filePath)], text: item.title);
            } catch (shareError) {
               ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Share failed too: $shareError')));
            }
        }
     }
  }

  static Future<void> shareItem(Item item) async {
    await HapticFeedback.mediumImpact();
    if (item is LinkItem) {
      await Share.share('${item.title}\n${item.url}');
    } else if (item is NoteItem) {
      await Share.share('${item.title}\n\n${item.content}');
    } else if (item is DocumentItem) {
      // Share file path
       await Share.shareXFiles([XFile(item.filePath)], text: item.title);
    }
  }

  static Future<void> pickAndCreateDocument(BuildContext context, WidgetRef ref) async {
      try {
        final result = await FilePicker.platform.pickFiles();
        if (result != null && result.files.isNotEmpty) {
           final file = result.files.first;
           if (file.path == null) return;
           
           // Copy to app dir
           final appDir = await getApplicationDocumentsDirectory();
           final fileName = p.basename(file.path!);
           final savedPath = p.join(appDir.path, 'docs', fileName);
           
           final savedFile = await File(savedPath).create(recursive: true);
           await File(file.path!).copy(savedPath);
           
           final docItem = DocumentItem(
             id: const Uuid().v4(),
             title: fileName, 
             filePath: savedPath,
             fileType: p.extension(fileName).replaceAll('.', ''),
             fileSize: file.size,
             createdAt: DateTime.now(),
             updatedAt: DateTime.now(),
           );
           
           await ref.read(itemRepositoryProvider).createItem(docItem);
           ref.invalidate(docsProvider);
           ref.invalidate(recentItemsProvider);
           
           if (context.mounted) {
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Imported $fileName to $savedPath')));
           }
        }
      } catch (e) {
         if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
         }
      }
  }
}
