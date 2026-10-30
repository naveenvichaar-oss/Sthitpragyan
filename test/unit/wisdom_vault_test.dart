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

    test('WisdomEntry parses localized maps and returns localized getters', () {
      final json = {
        'id': 'gita_2_56',
        'category': 'gita',
        'categoryName': 'Gita & Sthitaprajna',
        'title': {
          'en': 'Equanimity in Turmoil',
          'hi': 'दुःखेष्वनुद्विग्नमनाः (विपत्ति में स्थिरता)',
        },
        'subtitle': {
          'en': 'Bhagavad Gita 2.56',
          'hi': 'श्रीमद्भगवद्गीता 2.56',
        },
        'source': 'Bhagavad Gita 2.56',
        'shlokaText':
            'दुःखेष्वनुद्विग्नमनाः सुखेषु विगतस्पृहः।\nवीतरागभयक्रोधः स्थितधीर्मुनि रुच्यते॥',
        'originalText':
            'दुःखेष्वनुद्विग्नमनाः सुखेषु विगतस्पृहः।\nवीतरागभयक्रोधः स्थितधीर्मुनि रुच्यते॥',
        'translation': {
          'en': 'One whose mind is undisturbed in distress...',
          'hi': 'जिसका मन दुखों की प्राप्ति पर उद्वेग रहित रहता है...',
        },
        'executiveTakeaway': {
          'en': 'When deadlines implode and toxic stakeholders posture...',
          'hi': 'जब कार्य का दबाव चरम पर हो या परिस्थितियाँ प्रतिकूल हों...',
        },
        'tags': ['Equanimity', 'Crisis Composure'],
        'isEmergencyPerspective': true,
      };

      final entry = WisdomEntry.fromJson(json);
      expect(entry.id, 'gita_2_56');
      expect(entry.getTitle(false), 'Equanimity in Turmoil');
      expect(entry.getTitle(true), 'दुःखेष्वनुद्विग्नमनाः (विपत्ति में स्थिरता)');
      expect(entry.getSubtitle(false), 'Bhagavad Gita 2.56');
      expect(entry.getSubtitle(true), 'श्रीमद्भगवद्गीता 2.56');
      expect(entry.shlokaText, contains('स्थितधीर्मुनि रुच्यते॥'));
      expect(entry.shlokaText, isNot(contains('Nichols')));
      expect(entry.getTranslation(true), startsWith('जिसका मन'));
      expect(entry.getExecutiveTakeaway(true), startsWith('जब कार्य का दबाव'));
      expect(entry.isEmergencyPerspective, true);
    });
  });

  group('ResourceLink & ResourceMediaType Tests', () {
    test('ResourceMediaType parses case-insensitively and maps correctly', () {
      expect(ResourceMediaType.fromString('youtube'), ResourceMediaType.youTube);
      expect(ResourceMediaType.fromString('DrivePDF'), ResourceMediaType.drivePdf);
      expect(ResourceMediaType.fromString('googlekeep'), ResourceMediaType.googleKeep);
      expect(ResourceMediaType.fromString('substack'), ResourceMediaType.substack);
      expect(ResourceMediaType.fromString('socialmedia'), ResourceMediaType.socialMedia);
      expect(ResourceMediaType.fromString('social'), ResourceMediaType.socialMedia);
      expect(ResourceMediaType.fromString('unknown'), ResourceMediaType.webLink);

      expect(ResourceMediaType.youTube.badgeLabel, 'YOUTUBE');
      expect(ResourceMediaType.drivePdf.badgeLabel, 'DRIVE PDF');
      expect(ResourceMediaType.googleKeep.badgeLabel, 'KEEP NOTE');
      expect(ResourceMediaType.substack.badgeLabel, 'SUBSTACK');
      expect(ResourceMediaType.socialMedia.badgeLabel, 'SOCIAL');
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
      expect(gitaBreakdown.url, equals('https://gitaseva.org/'));
      expect(gitaBreakdown.mediaType, ResourceMediaType.webLink);
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

    test('detectMediaTypeFromUrl accurately detects YouTube, Drive, Keep, Substack, and Social Media', () {
      expect(
        ResourceLink.detectMediaTypeFromUrl('https://www.youtube.com/watch?v=ha7dSOotgsaA&list=PL123'),
        ResourceMediaType.youTube,
      );
      expect(
        ResourceLink.detectMediaTypeFromUrl('https://youtu.be/ha7dSOotgsaA'),
        ResourceMediaType.youTube,
      );
      expect(
        ResourceLink.detectMediaTypeFromUrl('https://m.youtube.com/watch?v=xyz'),
        ResourceMediaType.youTube,
      );
      expect(
        ResourceLink.detectMediaTypeFromUrl('https://drive.google.com/file/d/test/view'),
        ResourceMediaType.drivePdf,
      );
      expect(
        ResourceLink.detectMediaTypeFromUrl('https://docs.google.com/document/d/test/edit'),
        ResourceMediaType.drivePdf,
      );
      expect(
        ResourceLink.detectMediaTypeFromUrl('https://keep.google.com/#NOTE/123'),
        ResourceMediaType.googleKeep,
      );
      expect(
        ResourceLink.detectMediaTypeFromUrl('https://thestoic.substack.com/p/detachment'),
        ResourceMediaType.substack,
      );
      expect(
        ResourceLink.detectMediaTypeFromUrl('https://x.com/naval/status/123456'),
        ResourceMediaType.socialMedia,
      );
      expect(
        ResourceLink.detectMediaTypeFromUrl('https://twitter.com/naval/status/123456'),
        ResourceMediaType.socialMedia,
      );
      expect(
        ResourceLink.detectMediaTypeFromUrl('https://www.linkedin.com/posts/executive-stoicism'),
        ResourceMediaType.socialMedia,
      );
      expect(
        ResourceLink.detectMediaTypeFromUrl('https://classics.mit.edu/Antoninus/meditations.html'),
        ResourceMediaType.webLink,
      );
    });

    test('effectiveMediaType and fromMap automatically upgrades YouTube, Substack, and Social links saved as WebLink', () {
      final legacySavedMap = {
        'id': 'res_user_yt_1',
        'title': 'Exercises for Mastering the Laws of Human Nature',
        'category': 'Psychology & Models',
        'mediaType': 'WebLink', // user saved without manually changing chip
        'url': 'https://www.youtube.com/watch?v=ha7dSOotgsaA&list=PL456',
        'isUserAdded': true,
        'notes': 'Detachment practice',
        'createdAt': DateTime(2026, 10, 17).toIso8601String(),
      };

      final link = ResourceLink.fromMap(legacySavedMap);
      // fromMap auto-detects and upgrades mediaType
      expect(link.mediaType, ResourceMediaType.youTube);
      expect(link.effectiveMediaType, ResourceMediaType.youTube);

      // Serializing back writes 'YouTube'
      final upgradedMap = link.toMap();
      expect(upgradedMap['mediaType'], 'YouTube');

      // Substack auto-upgrade
      final substackMap = {
        'id': 'res_user_sub_1',
        'title': 'The Daily Stoic Letter',
        'category': 'Western Stoicism',
        'mediaType': 'WebLink',
        'url': 'https://ryanholiday.substack.com/p/stillness-rules',
        'isUserAdded': true,
        'createdAt': DateTime(2026, 10, 17).toIso8601String(),
      };
      final substackLink = ResourceLink.fromMap(substackMap);
      expect(substackLink.mediaType, ResourceMediaType.substack);
      expect(substackLink.effectiveMediaType, ResourceMediaType.substack);
      expect(substackLink.toMap()['mediaType'], 'Substack');

      // Social Media auto-upgrade
      final socialMap = {
        'id': 'res_user_soc_1',
        'title': 'Naval on Judgment',
        'category': 'Executive Protocols',
        'mediaType': 'WebLink',
        'url': 'https://x.com/naval/status/1005307921200138240',
        'isUserAdded': true,
        'createdAt': DateTime(2026, 10, 17).toIso8601String(),
      };
      final socialLink = ResourceLink.fromMap(socialMap);
      expect(socialLink.mediaType, ResourceMediaType.socialMedia);
      expect(socialLink.effectiveMediaType, ResourceMediaType.socialMedia);
      expect(socialLink.toMap()['mediaType'], 'SocialMedia');
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
