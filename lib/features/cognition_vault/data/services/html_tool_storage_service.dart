import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/database/hive_storage.dart';
import '../models/local_html_tool.dart';

/// HtmlToolStorageService orchestrates the "Import, Permanently Embed & Safe Overwrite"
/// architecture for offline executive HTML dashboards, standalone tools, and calculators.
class HtmlToolStorageService {
  static final HtmlToolStorageService _instance = HtmlToolStorageService._internal();
  factory HtmlToolStorageService() => _instance;
  HtmlToolStorageService._internal();

  static const String directoryName = 'app_html_tools';
  final HiveStorage _storage = HiveStorage();

  /// Returns the persistent app documents sandbox directory (`app_html_tools/`),
  /// creating it recursively if it does not yet exist.
  Future<Directory> getToolsDirectory() async {
    if (kIsWeb) {
      return Directory(directoryName);
    }
    final appDir = await getApplicationDocumentsDirectory();
    final toolsDir = Directory('${appDir.path}/$directoryName');
    if (!await toolsDir.exists()) {
      await toolsDir.create(recursive: true);
    }
    return toolsDir;
  }

  /// Converts any incoming raw filename into a secure, sanitized internal filename.
  /// Enforces .html extension, eliminates directory traversals and invalid characters.
  String sanitizeFileName(String rawName) {
    var clean = rawName.trim();
    if (clean.contains('/') || clean.contains(r'\')) {
      clean = clean.split(RegExp(r'[/\\]')).last;
    }

    var base = clean;
    final lower = clean.toLowerCase();
    if (lower.endsWith('.html')) {
      base = clean.substring(0, clean.length - 5);
    } else if (lower.endsWith('.htm')) {
      base = clean.substring(0, clean.length - 4);
    }

    // Replace non-alphanumeric chars with underscore
    base = base.replaceAll(RegExp(r'[^\w\-]'), '_');
    base = base.replaceAll(RegExp(r'_+'), '_');
    base = base.replaceAll(RegExp(r'^_+|_+$'), '');

    if (base.isEmpty) {
      base = 'custom_html_tool';
    }

    return '$base.html';
  }

  /// Checks if a tool with the same sanitized filename or internal file path already exists.
  Future<LocalHtmlTool?> findExistingTool(String sanitizedFileName) async {
    final tools = _storage.getAllHtmlTools();
    final lowerTarget = sanitizedFileName.toLowerCase();

    for (final t in tools) {
      if (t.fileName.toLowerCase() == lowerTarget) {
        return t;
      }
      if (t.localFilePath.toLowerCase().endsWith('/$lowerTarget') ||
          t.localFilePath.toLowerCase().endsWith(r'\' + lowerTarget)) {
        return t;
      }
    }
    return null;
  }

  /// Imports an HTML file, permanently embeds it inside `app_html_tools/`,
  /// and executes de-duplication with safe overwrite.
  Future<({LocalHtmlTool tool, bool isOverwrite})> importOrOverwriteTool({
    String? sourceFilePath,
    required String originalFileName,
    required List<int> bytes,
    required String title,
    String? category,
    String? description,
  }) async {
    final toolsDir = await getToolsDirectory();
    final sanitizedName = sanitizeFileName(originalFileName);
    final targetPath = '${toolsDir.path}/$sanitizedName';
    final targetFile = File(targetPath);

    // 1. One-Time Import & Persistent Sandbox Storage
    if (!kIsWeb) {
      if (sourceFilePath != null &&
          sourceFilePath.isNotEmpty &&
          await File(sourceFilePath).exists()) {
        // Safe overwrite: copy source directly to internal target path
        await File(sourceFilePath).copy(targetPath);
      } else {
        // Write raw bytes directly
        await targetFile.writeAsBytes(bytes, flush: true);
      }
    }

    // 2. Decode content string for fallback / inspector
    String contentString;
    try {
      contentString = utf8.decode(bytes);
    } catch (_) {
      contentString = String.fromCharCodes(bytes);
    }

    final fileSize = bytes.length;

    // 3. Safe Overwrite & De-duplication Logic
    final existing = await findExistingTool(sanitizedName);

    if (existing != null) {
      final updatedTool = existing.copyWith(
        title: title.trim().isNotEmpty ? title.trim() : existing.title,
        category: category?.trim().isNotEmpty == true
            ? category!.trim()
            : existing.category,
        description: description?.trim().isNotEmpty == true
            ? description!.trim()
            : existing.description,
        localFilePath: targetPath,
        fileName: sanitizedName,
        htmlContent: contentString,
        fileSizeBytes: fileSize,
        addedDate: DateTime.now(), // Update timestamp on safe overwrite
      );

      await _storage.saveHtmlTool(updatedTool);
      return (tool: updatedTool, isOverwrite: true);
    }

    // New File creation
    final newTool = LocalHtmlTool(
      id: 'tool_${DateTime.now().millisecondsSinceEpoch}',
      title: title.trim().isNotEmpty
          ? title.trim()
          : sanitizedName.replaceAll('.html', '').replaceAll('_', ' '),
      localFilePath: targetPath,
      htmlContent: contentString,
      addedDate: DateTime.now(),
      category: category?.trim().isNotEmpty == true
          ? category!.trim()
          : 'Personal Tool',
      fileName: sanitizedName,
      description: description?.trim().isNotEmpty == true
          ? description!.trim()
          : null,
      fileSizeBytes: fileSize,
    );

    await _storage.saveHtmlTool(newTool);
    return (tool: newTool, isOverwrite: false);
  }

  /// Deletes the HTML tool from both the internal `app_html_tools/` sandbox
  /// and the Hive database record.
  Future<void> deleteTool(LocalHtmlTool tool) async {
    if (!kIsWeb && tool.localFilePath.isNotEmpty) {
      try {
        final file = File(tool.localFilePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        debugPrint('[HtmlToolStorageService] Error deleting file: $e');
      }
    }
    await _storage.deleteHtmlTool(tool.id);
  }

  /// Ensures a tool has a physical file written inside `app_html_tools/`
  /// before loading into the WebView controller.
  Future<String> prepareFileForLoading(LocalHtmlTool tool) async {
    if (kIsWeb) return '';

    if (tool.localFilePath.isNotEmpty) {
      final file = File(tool.localFilePath);
      if (await file.exists()) {
        return tool.localFilePath;
      }
    }

    // If file is missing on disk (e.g. starter dashboard or newly migrated), re-materialize from htmlContent
    if (tool.htmlContent != null && tool.htmlContent!.isNotEmpty) {
      final toolsDir = await getToolsDirectory();
      final sanitizedName = sanitizeFileName(tool.fileName);
      final targetFile = File('${toolsDir.path}/$sanitizedName');
      await targetFile.writeAsString(tool.htmlContent!, flush: true);

      // Update Hive record with the now verified path
      final updated = tool.copyWith(
        localFilePath: targetFile.path,
        fileName: sanitizedName,
      );
      await _storage.saveHtmlTool(updated);
      return targetFile.path;
    }

    return '';
  }
}
