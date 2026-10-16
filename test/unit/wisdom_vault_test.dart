import 'package:flutter_test/flutter_test.dart';
import 'package:sthitaprajna/features/wisdom/data/models/resource_link.dart';
import 'package:sthitaprajna/features/wisdom/data/models/wisdom_entry.dart';
import 'package:sthitaprajna/features/wisdom/data/services/wisdom_vault_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WisdomEntry Tests', () {
    test('WisdomEntry parses correctly from JSON and serializes back', () {
      final json = {
        'id': 'test_gita_1',
        'category': 'gita',
        'categoryName': 'Gita & Sthitaprajna',
        'title': 'Test Shloka',
        'source': 'Bhagavad Gita 2.47',
        'originalText': 'कर्मण्येवाधिकारस्ते...',
        'translation': 'You have a right to work, never to fruits.',
        'executiveTakeaway': 'Focus completely on execution.',
        'tags': ['Action', 'Focus'],
        'isEmergencyPerspective': true,
      };

      final entry = WisdomEntry.fromJson(json);
      expect(entry.id, 'test_gita_1');
      expect(entry.category, 'gita');
      expect(entry.title, 'Test Shloka');
      expect(entry.isEmergencyPerspective, true);
      expect(entry.tags, contains('Action'));

      final serialized = entry.toJson();
      expect(serialized['id'], 'test_gita_1');
      expect(serialized['source'], 'Bhagavad Gita 2.47');
      expect(serialized['isEmergencyPerspective'], true);
    });
  });

  group('ResourceLink & ResourceMediaType Tests', () {
    test('ResourceMediaType parses case-insensitively and maps correctly', () {
      expect(ResourceMediaType.fromString('youtube'), ResourceMediaType.youTube);
      expect(ResourceMediaType.fromString('DrivePDF'), ResourceMediaType.drivePdf);
      expect(ResourceMediaType.fromString('googlekeep'), ResourceMediaType.googleKeep);
      expect(ResourceMediaType.fromString('unknown'), ResourceMediaType.webLink);

      expect(ResourceMediaType.youTube.badgeLabel, 'YOUTUBE');
      expect(ResourceMediaType.drivePdf.badgeLabel, 'DRIVE PDF');
      expect(ResourceMediaType.googleKeep.badgeLabel, 'KEEP NOTE');
      expect(ResourceMediaType.webLink.badgeLabel, 'WEB LINK');
    });

    test('Pre-seeded resources contain MIT Meditations, Enchiridion, and Gita', () {
      final preSeeded = ResourceLink.preSeededResources();
      expect(preSeeded.length, greaterThanOrEqualTo(4));

      final meditations =
          preSeeded.firstWhere((r) => r.id == 'seed_meditations_mit');
      expect(meditations.url, contains('classics.mit.edu'));
      expect(meditations.isUserAdded, false);

      final enchiridion =
          preSeeded.firstWhere((r) => r.id == 'seed_enchiridion_mit');
      expect(enchiridion.url, contains('classics.mit.edu'));

      final gitaBreakdown =
          preSeeded.firstWhere((r) => r.id == 'seed_gita_ch2_breakdown');
      expect(gitaBreakdown.mediaType, ResourceMediaType.youTube);
    });

    test('ResourceLink serialization toMap and fromMap preserves data', () {
      final original = ResourceLink(
        id: 'res_custom_1',
        title: 'Personal Executive Drive PDF',
        category: 'Personal Sanctuary',
        mediaType: ResourceMediaType.drivePdf,
        url: 'https://drive.google.com/file/d/test/view',
        isUserAdded: true,
        notes: 'Crisis decision matrix notes.',
        createdAt: DateTime(2026, 10, 17, 10, 30),
      );

      final map = original.toMap();
      final reconstituted = ResourceLink.fromMap(map);

      expect(reconstituted.id, original.id);
      expect(reconstituted.title, original.title);
      expect(reconstituted.category, original.category);
      expect(reconstituted.mediaType, ResourceMediaType.drivePdf);
      expect(reconstituted.url, original.url);
      expect(reconstituted.isUserAdded, true);
      expect(reconstituted.notes, original.notes);
    });
  });

  group('WisdomVaultService In-Memory Tests', () {
    test('Fallback entries exist if assets are unavailable', () {
      final service = WisdomVaultService();
      final daily = service.getDailyWisdom();
      expect(daily.title, isNotEmpty);
      expect(daily.source, isNotEmpty);
    });
  });
}
