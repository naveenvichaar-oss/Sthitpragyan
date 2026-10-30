import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/wisdom_entry.dart';

/// WisdomVaultService loads, parses, and in-memory caches `assets/data/wisdom_vault.json`
/// providing instant, offline-first, zero-latency access across the app.
class WisdomVaultService {
  static final WisdomVaultService _instance = WisdomVaultService._internal();
  factory WisdomVaultService() => _instance;
  WisdomVaultService._internal();

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  List<WisdomEntry> _entries = [];
  List<WisdomEntry> get entries => List.unmodifiable(_entries);

  /// Initializes the service by reading offline JSON asset
  Future<void> init() async {
    if (_isLoaded) return;

    try {
      final jsonString =
          await rootBundle.loadString('assets/data/wisdom_vault.json');
      final dynamic decoded = json.decode(jsonString);

      if (decoded is List) {
        _entries = decoded
            .map((item) => WisdomEntry.fromJson(item as Map<String, dynamic>))
            .toList();
        _isLoaded = true;
        debugPrint(
          '[WisdomVaultService] Loaded ${_entries.length} wisdom entries offline.',
        );
      }
    } catch (e, stack) {
      debugPrint('[WisdomVaultService] Error loading wisdom vault asset: $e\n$stack');
      // If error occurs, fallback to minimal in-memory entries so app never fails
      _entries = _fallbackEntries();
      _isLoaded = true;
    }
  }

  List<WisdomEntry> getAllEntries() => _entries;

  List<WisdomEntry> getEntriesByCategory(String category) {
    if (category.isEmpty || category.toLowerCase() == 'all') return _entries;
    return _entries
        .where((e) => e.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  List<WisdomEntry> getEmergencyPerspectives() {
    return _entries.where((e) => e.isEmergencyPerspective).toList();
  }

  WisdomEntry? getById(String id) {
    try {
      return _entries.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Returns a rotating wisdom entry based on the current calendar day
  WisdomEntry getDailyWisdom([int? indexOverride]) {
    if (_entries.isEmpty) {
      return _fallbackEntries().first;
    }
    if (indexOverride != null && indexOverride >= 0) {
      return _entries[indexOverride % _entries.length];
    }
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    return _entries[dayOfYear % _entries.length];
  }

  /// Searches wisdom entries by text query across title, source, translation, takeaway, and tags
  List<WisdomEntry> search(String query, {String? category}) {
    var pool = _entries;
    if (category != null && category.isNotEmpty && category.toLowerCase() != 'all') {
      pool = pool
          .where((e) => e.category.toLowerCase() == category.toLowerCase())
          .toList();
    }

    if (query.trim().isEmpty) return pool;

    final q = query.trim().toLowerCase();
    return pool.where((e) {
      final inTitle = e.title.toLowerCase().contains(q);
      final inSource = e.source.toLowerCase().contains(q);
      final inOriginal = e.originalText.toLowerCase().contains(q);
      final inTranslation = e.translation.toLowerCase().contains(q);
      final inTakeaway = e.executiveTakeaway.toLowerCase().contains(q);
      final inTags = e.tags.any((t) => t.toLowerCase().contains(q));
      return inTitle || inSource || inOriginal || inTranslation || inTakeaway || inTags;
    }).toList();
  }

  static List<WisdomEntry> _fallbackEntries() {
    return const [
      WisdomEntry(
        id: 'fallback_1',
        category: 'gita',
        categoryName: 'Gita & Sthitaprajna',
        title: 'Equanimity in Turmoil',
        titleHi: 'दुःखेष्वनुद्विग्नमनाः (विपत्ति में स्थिरता)',
        source: 'Bhagavad Gita 2.56',
        sourceHi: 'श्रीमद्भगवद्गीता 2.56',
        originalText:
            'दुःखेष्वनुद्विग्नमनाः सुखेषु विगतस्पृहः।\nवीतरागभयक्रोधः स्थितधीर्मुनि रुच्यते॥',
        romanizedText:
            'duḥkheṣv anudvigna-manāḥ sukheṣu vigata-spṛhaḥ |\nvīta-rāga-bhaya-krodhaḥ sthita-dhīr munir ucyate ||',
        translation:
            'One whose mind is undisturbed in distress, who does not crave worldly pleasure, and who is free from attachment, fear, and anger, is called a sage of steady intellect.',
        translationHi:
            'जिसका मन दुखों की प्राप्ति पर उद्वेग रहित रहता है, जो सुखों की प्राप्ति में सर्वथा निष्पृह है, तथा जिसके राग, भय और क्रोध नष्ट हो चुके हैं, ऐसा मुनि स्थिरबुद्धि (स्थितप्रज्ञ) कहलाता है।',
        executiveTakeaway:
            'When deadlines implode and toxic stakeholders posture, maintain a flat pulse. Distress cannot pierce an intellect that has systematically excised the need for approval, dread of conflict, and retaliatory impulse.',
        executiveTakeawayHi:
            'जब कार्य का दबाव चरम पर हो या परिस्थितियाँ प्रतिकूल हों, तब अपनी मानसिक धड़कन शांत रखें। संकट उस बुद्धि को विचलित नहीं कर सकता जिसने अनुमोदन की अपेक्षा, टकराव के भय और प्रतिशोध की भावना को समूल त्याग दिया है।',
        tags: ['Equanimity', 'Emotional Flatline', 'Crisis Composure'],
        isEmergencyPerspective: true,
      ),
      WisdomEntry(
        id: 'fallback_2',
        category: 'western_stoicism',
        categoryName: 'Western Stoicism & Classics',
        title: 'Neutralizing Insults & Public Put-Downs',
        titleHi: 'अपमान व प्रहार का निष्प्रभावीकरण',
        source: 'Epictetus • Enchiridion 20',
        sourceHi: 'एपिक्टेटस • एनकिरीडियन 20',
        originalText:
            'Remember that what insults you is not the person who abuses you, but your judgment that these things are insulting.',
        translation:
            'Remember that what insults you is not the person who abuses you, but your judgment that these things are insulting.',
        translationHi:
            'स्मरण रखें कि जो आपको आहत करता है वह अपमान करने वाला व्यक्ति नहीं, बल्कि आपकी यह धारणा है कि आपका अपमान हुआ है।',
        executiveTakeaway:
            'Do not consent to being insulted. Without your mental permission, external words are harmless vibrations.',
        executiveTakeawayHi:
            'अपमान को अपनी आंतरिक स्वीकृति कभी न दें। आपकी मानसिक अनुमति के बिना बाहरी शब्द केवल हानिरहित कंपन हैं।',
        tags: ['Insults', 'Frame Control'],
        isEmergencyPerspective: true,
      ),
    ];
  }
}
