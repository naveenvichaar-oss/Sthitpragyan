import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:sthitaprajna/core/database/hive_storage.dart';
import 'package:sthitaprajna/core/localization/app_localizations.dart';
import 'package:sthitaprajna/features/cognition_vault/data/models/local_html_tool.dart';
import 'package:sthitaprajna/features/cognition_vault/data/services/html_tool_storage_service.dart';
import 'package:sthitaprajna/features/cognition_vault/presentation/widgets/platform_html_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('sthitaprajna_html_tests_');

    const MethodChannel channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return tempDir.path;
    });

    Hive.init(tempDir.path);
    await HiveStorage().init();
  });

  tearDownAll(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('LocalHtmlTool Model & Serialization Tests', () {
    final now = DateTime(2026, 10, 17, 14, 45);
    final tool = LocalHtmlTool(
      id: 'tool_test_1',
      title: 'Risk Probability Matrix',
      localFilePath: '/data/user/0/app_flutter/app_html_tools/matrix.html',
      htmlContent: '<html><body><h1>Risk Matrix</h1></body></html>',
      addedDate: now,
      category: 'Decision Matrix',
      fileName: 'matrix.html',
      description: 'Calculates downside vulnerability and financial contingency.',
      fileSizeBytes: 1024,
    );

    test('Serializes toMap and fromMap bidirectionally', () {
      final map = tool.toMap();
      final reconstructed = LocalHtmlTool.fromMap(map);

      expect(reconstructed.id, equals(tool.id));
      expect(reconstructed.title, equals(tool.title));
      expect(reconstructed.localFilePath, equals(tool.localFilePath));
      expect(reconstructed.htmlContent, equals(tool.htmlContent));
      expect(reconstructed.addedDate, equals(now));
      expect(reconstructed.category, equals(tool.category));
      expect(reconstructed.fileName, equals(tool.fileName));
      expect(reconstructed.description, equals(tool.description));
      expect(reconstructed.fileSizeBytes, equals(1024));
    });

    test('copyWith enables immutable updates', () {
      final updated = tool.copyWith(
        title: 'Renamed Matrix',
        category: 'Custom Calculator',
      );

      expect(updated.title, equals('Renamed Matrix'));
      expect(updated.category, equals('Custom Calculator'));
      expect(updated.id, equals(tool.id));
      expect(updated.localFilePath, equals(tool.localFilePath));
    });

    test('copyWith updates htmlContent seamlessly', () {
      final updated = tool.copyWith(htmlContent: '<html><body>Updated</body></html>');
      expect(updated.htmlContent, equals('<html><body>Updated</body></html>'));
      expect(updated.title, equals(tool.title));
    });

    test('starterDashboard generates valid interactive executive HTML tool', () {
      final starter = LocalHtmlTool.starterDashboard();

      expect(starter.id, equals('tool_starter_decision_matrix'));
      expect(starter.title, equals('Executive Decision & Stillness Matrix'));
      expect(starter.category, equals('Decision Matrix'));
      expect(starter.htmlContent, isNotNull);
      expect(starter.htmlContent!, contains('<!DOCTYPE html>'));
      expect(starter.htmlContent!, contains('calmSlider'));
      expect(starter.htmlContent!, contains('Premeditatio Malorum'));
      expect(starter.htmlContent!, contains('localStorage'));
      expect(starter.fileSizeBytes! > 0, isTrue);
    });
  });

  group('HtmlToolStorageService Sanitization & Safe Overwrite Tests', () {
    final service = HtmlToolStorageService();

    test('sanitizeFileName strips traversals, special characters, and enforces .html', () {
      expect(service.sanitizeFileName('matrix.html'), equals('matrix.html'));
      expect(service.sanitizeFileName('Executive Decision (v2).htm'), equals('Executive_Decision_v2.html'));
      expect(service.sanitizeFileName('../../../sneaky/tool.html'), equals('tool.html'));
      expect(service.sanitizeFileName('C:\\Downloads\\Stress_Calculator.HTML'), equals('Stress_Calculator.html'));
      expect(service.sanitizeFileName('   '), equals('custom_html_tool.html'));
    });

    test('importOrOverwriteTool creates new tool and safely overwrites duplicates without redundant cards', () async {
      const originalName = 'executive_calculator.html';
      const initialHtml = '<html><body><h1>Version 1.0</h1></body></html>';
      final initialBytes = utf8.encode(initialHtml);

      // 1. Initial Import (New Tool)
      final importResult = await service.importOrOverwriteTool(
        originalFileName: originalName,
        bytes: initialBytes,
        title: 'Executive Calculator',
        category: 'Calculator',
        description: 'First version of calculator',
      );

      expect(importResult.isOverwrite, isFalse);
      expect(importResult.tool.title, equals('Executive Calculator'));
      expect(importResult.tool.fileName, equals('executive_calculator.html'));
      expect(importResult.tool.htmlContent, equals(initialHtml));

      final toolsAfterFirst = HiveStorage().getAllHtmlTools();
      final matchingFirst = toolsAfterFirst.where((t) => t.fileName == 'executive_calculator.html').toList();
      expect(matchingFirst.length, equals(1));
      final originalId = matchingFirst.first.id;

      // 2. Overwrite Import (Same file name, updated content)
      const updatedHtml = '<html><body><h1>Version 2.0 - Overwritten</h1></body></html>';
      final updatedBytes = utf8.encode(updatedHtml);

      final overwriteResult = await service.importOrOverwriteTool(
        originalFileName: originalName,
        bytes: updatedBytes,
        title: 'Executive Calculator 2.0',
        category: 'Calculator',
        description: 'Updated without duplicate card',
      );

      expect(overwriteResult.isOverwrite, isTrue);
      expect(overwriteResult.tool.id, equals(originalId));
      expect(overwriteResult.tool.title, equals('Executive Calculator 2.0'));
      expect(overwriteResult.tool.htmlContent, equals(updatedHtml));

      // De-duplication check: Must still be exactly ONE entry in Hive, not two
      final toolsAfterSecond = HiveStorage().getAllHtmlTools();
      final matchingSecond = toolsAfterSecond.where((t) => t.fileName == 'executive_calculator.html').toList();
      expect(matchingSecond.length, equals(1));

      // 3. Deletion test: Removes from Hive and cleans sandbox
      await service.deleteTool(overwriteResult.tool);
      final toolsAfterDelete = HiveStorage().getAllHtmlTools();
      expect(toolsAfterDelete.any((t) => t.id == originalId), isFalse);
    });
  });

  group('Bilingual Localization for HTML Tools Tests', () {
    test('English localizations contain all new HTML tool getters', () {
      final loc = AppLocalizations(const Locale('en'));
      expect(loc.htmlToolsTitle, 'Personal HTML Tools & Dashboards');
      expect(loc.importHtmlToolTitle, 'Import & Embed HTML Tool');
      expect(loc.safeOverwriteMode, 'SAFE OVERWRITE ACTIVE');
      expect(loc.safeOverwriteNotice, contains('without duplicate cards'));
      expect(loc.deleteToolTitle, 'Delete Tool?');
      expect(loc.deleteAction, 'Delete');
      expect(loc.launchAction, 'LAUNCH');
    });

    test('Hindi localizations contain high-register Devanagari getters', () {
      final loc = AppLocalizations(const Locale('hi'));
      expect(loc.htmlToolsTitle, contains('HTML'));
      expect(loc.importHtmlToolTitle, contains('आयात'));
      expect(loc.safeOverwriteMode, 'सुरक्षित अधिलेखन सक्रिय');
      expect(loc.safeOverwriteNotice, contains('बिना डुप्लिकेट'));
      expect(loc.deleteToolTitle, 'टूल हटाएं?');
      expect(loc.deleteAction, 'हटाएं');
      expect(loc.launchAction, 'चलाएं');
    });
  });

  group('PlatformHtmlView Stub & Cross-Platform Tests', () {
    test('buildPlatformHtmlView builds without throwing on non-web environment', () {
      final widget = buildPlatformHtmlView(
        viewKey: 'test_key',
        htmlContent: '<h1>Hello</h1>',
      );
      expect(widget, isNotNull);
    });

    test('openPlatformHtmlExternal handles empty or missing files gracefully', () async {
      expect(
        () => openPlatformHtmlExternal(htmlContent: '', localFilePath: ''),
        returnsNormally,
      );
    });
  });
}
