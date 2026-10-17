import 'package:flutter_test/flutter_test.dart';
import 'package:sthitaprajna/features/cognition_vault/data/models/local_html_tool.dart';
import 'package:sthitaprajna/features/cognition_vault/presentation/widgets/platform_html_view.dart';

void main() {
  group('LocalHtmlTool Model & Serialization Tests', () {
    final now = DateTime(2026, 10, 17, 14, 45);
    final tool = LocalHtmlTool(
      id: 'tool_test_1',
      title: 'Risk Probability Matrix',
      localFilePath: '/data/user/0/app_flutter/html_tools/matrix.html',
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
