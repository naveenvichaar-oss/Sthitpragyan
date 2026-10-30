import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/database/hive_storage.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/locale_controller.dart';
import '../../../../core/utils/date_helpers.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../../../shared/widgets/voice_dictation_button.dart';
import '../../../character_ledger/presentation/screens/character_ledger_screen.dart';
import '../../../execution_trigger/presentation/screens/execution_trigger_screen.dart';
import '../../data/models/journal_models.dart';
import '../../data/models/reflection_entry.dart';
import '../../data/repositories/journal_repository.dart';
import '../../data/services/media_vault_service.dart';
import '../widgets/audio_memo_recorder_modal.dart';
import '../widgets/media_recordings_vault_view.dart';
import '../widgets/reflection_timeline_view.dart';
import '../widgets/save_to_sthitaprajna_view.dart';
import '../widgets/video_reflection_drill_modal.dart';

/// JournalScreen represents Pillar 3: संज्ञान / Cognition
/// Unified Authoring & Journaling Workspace featuring 4 universal categories:
/// 1. दैनिक व्यवहार समीक्षा (Daily Review & Reflection)
/// 2. 1:3 इनपुट-आउटपुट (1:3 Input-Output Logger)
/// 3. व्यक्तिगत डायरी व उद्गार (Personal Journal / Freeform Thoughts)
/// 4. सामग्री संचयन (Save to Sthitaprajna / Vault Ingest)
class JournalScreen extends StatefulWidget {
  final VoidCallback? onEntrySaved;

  const JournalScreen({super.key, this.onEntrySaved});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final JournalRepository _repository = JournalRepository();
  final HiveStorage _storage = HiveStorage();

  // Top View Segment: 0 = Authoring (लेखन), 1 = Dynamic Timeline (इतिहास), 2 = Media Vault (मीडिया वॉल्ट)
  int _activeSegment = 0;

  // Selected Authoring Category
  ReflectionCategory _selectedCategory = ReflectionCategory.dailyReview;

  // Controllers for Daily Review
  final TextEditingController _outputController = TextEditingController();
  final TextEditingController _provocationController = TextEditingController();

  // Controllers for Freeform Reflections (Personal Journal, Planning, Self-Talk)
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  // Controllers for 1:3 Input-Output Logger
  final TextEditingController _sourceTitleController = TextEditingController();
  final TextEditingController _takeaway1Controller = TextEditingController();
  final TextEditingController _takeaway2Controller = TextEditingController();
  final TextEditingController _takeaway3Controller = TextEditingController();

  // Daily Review Metrics
  int _reactionScore = 4;
  bool _boundaryMaintained = true;

  // Multimodal Attachments
  String? _audioMemoPath;
  String? _videoReflectionPath;
  AudioPlayer? _audioMemoPlayer;
  bool _isPlayingAudioMemo = false;

  Future<void> _toggleAudioMemoPlayback() async {
    final path = _audioMemoPath;
    if (path == null) return;
    HapticService.selectionClick();

    _audioMemoPlayer ??= AudioPlayer();

    if (_isPlayingAudioMemo) {
      await _audioMemoPlayer!.stop();
      if (mounted) setState(() => _isPlayingAudioMemo = false);
    } else {
      _audioMemoPlayer!.onPlayerComplete.listen((_) {
        if (mounted) setState(() => _isPlayingAudioMemo = false);
      });
      await _audioMemoPlayer!.play(DeviceFileSource(path));
      if (mounted) setState(() => _isPlayingAudioMemo = true);
    }
  }

  bool _isSaving = false;
  String? _editingReflectionId;
  List<DailyJournalEntry> _historicalEntries = [];
  DailyJournalEntry? _todayEntry;
  List<ReflectionEntry> _reflections = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _historicalEntries = _repository.getAllEntries();
    _todayEntry = _repository.getTodayEntry();
    _reflections = _storage.getAllReflections();

    // Auto-sync historical daily journal entries into reflections if not already present
    _syncDailyEntriesToReflections();

    if (_todayEntry != null && _selectedCategory == ReflectionCategory.dailyReview) {
      _reactionScore = _todayEntry!.reactionControlScore;
      _boundaryMaintained = _todayEntry!.boundaryMaintained;
      _outputController.text = _todayEntry!.coreOutputSummary;
      _provocationController.text = _todayEntry!.provocationHandled ?? '';
      _audioMemoPath = _todayEntry!.audioMemoPath;
      _videoReflectionPath = _todayEntry!.videoReflectionPath;
    }
    setState(() {});
  }

  void _syncDailyEntriesToReflections() {
    final isHindi = LocaleController.instance.isHindi;
    final existingIds = _reflections.map((r) => r.id).toSet();
    bool updated = false;

    for (final entry in _historicalEntries) {
      if (!existingIds.contains(entry.id)) {
        final reflection = ReflectionEntry(
          id: entry.id,
          title: isHindi
              ? 'दैनिक व्यवहार समीक्षा • ${entry.entryDate}'
              : 'Daily Review • ${entry.entryDate}',
          content: entry.coreOutputSummary,
          category: ReflectionCategory.dailyReview,
          createdAt: entry.createdAt,
          audioMemoPath: entry.audioMemoPath,
          videoReflectionPath: entry.videoReflectionPath,
          reactionScore: entry.reactionControlScore,
          boundaryMaintained: entry.boundaryMaintained,
          distractionAvoided: entry.provocationHandled,
          tags: const ['समीक्षा', 'समत्व'],
        );
        _storage.saveReflection(reflection);
        _reflections.add(reflection);
        updated = true;
      }
    }

    if (updated) {
      _reflections.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
  }

  @override
  void dispose() {
    _audioMemoPlayer?.dispose();
    _outputController.dispose();
    _provocationController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    _sourceTitleController.dispose();
    _takeaway1Controller.dispose();
    _takeaway2Controller.dispose();
    _takeaway3Controller.dispose();
    super.dispose();
  }

  String _getReactionScoreLabel(int score) {
    return context.loc.reactionScoreLabel(score);
  }

  Color _getReactionColor(int score) {
    switch (score) {
      case 5:
        return AppColors.emeraldSuccess;
      case 4:
        return AppColors.shieldPrimary;
      case 3:
        return const Color(0xFF818CF8);
      case 2:
        return AppColors.amberWarning;
      case 1:
        return AppColors.roseDanger;
      default:
        return AppColors.shieldPrimary;
    }
  }

  Future<void> _handleSaveDailyReview() async {
    final text = _outputController.text.trim();
    if (text.isEmpty) {
      HapticService.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.loc.outputRequiredError,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.background,
            ),
          ),
          backgroundColor: AppColors.amberWarning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    HapticService.heavyImpact();

    final now = DateTime.now();
    final todayKey = DateHelpers.toStorageKey(now);
    final entryId = 'entry_$todayKey';

    // 1. Save to DailyJournalEntry (for legacy stats & streaks)
    final dailyEntry = DailyJournalEntry(
      id: entryId,
      entryDate: todayKey,
      createdAt: now,
      reactionControlScore: _reactionScore,
      boundaryMaintained: _boundaryMaintained,
      coreOutputSummary: text,
      provocationHandled: _provocationController.text.trim().isEmpty
          ? null
          : _provocationController.text.trim(),
      audioMemoPath: _audioMemoPath,
      videoReflectionPath: _videoReflectionPath,
    );
    await _repository.saveEntry(dailyEntry);

    // 2. Save to ReflectionEntry (for Unified Cognition Workspace)
    final reflection = ReflectionEntry(
      id: entryId,
      title: context.loc.dailyReviewDateTitle(todayKey),
      content: text,
      category: ReflectionCategory.dailyReview,
      createdAt: now,
      audioMemoPath: _audioMemoPath,
      videoReflectionPath: _videoReflectionPath,
      reactionScore: _reactionScore,
      boundaryMaintained: _boundaryMaintained,
      distractionAvoided: _provocationController.text.trim().isEmpty
          ? null
          : _provocationController.text.trim(),
      tags: const ['दैनिक समीक्षा', 'समत्व'],
    );
    await _storage.saveReflection(reflection);

    if (mounted) {
      setState(() {
        _isSaving = false;
        _todayEntry = dailyEntry;
        _historicalEntries = _repository.getAllEntries();
        _reflections = _storage.getAllReflections();
      });

      widget.onEntrySaved?.call();

      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.shield_rounded,
                color: AppColors.emeraldSuccess,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.loc.debriefSavedConfirmation(dailyEntry.compositeScore),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.background,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.textPrimary,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Future<void> _handleSaveFreeformReflection() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      HapticService.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.loc.enterReflectionPrompt,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          backgroundColor: AppColors.amberWarning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    HapticService.heavyImpact();

    final now = DateTime.now();
    final id = _editingReflectionId ?? 'reflection_${now.millisecondsSinceEpoch}';

    final rawTags = _tagsController.text.trim();
    final tags = rawTags.isEmpty
        ? <String>[]
        : rawTags
            .split(',')
            .map((t) => t.trim().replaceAll('#', ''))
            .where((t) => t.isNotEmpty)
            .toList();

    final reflection = ReflectionEntry(
      id: id,
      title: _titleController.text.trim(),
      content: content,
      category: _selectedCategory,
      createdAt: now,
      audioMemoPath: _audioMemoPath,
      videoReflectionPath: _videoReflectionPath,
      tags: tags,
    );

    await _storage.saveReflection(reflection);

    if (mounted) {
      setState(() {
        _isSaving = false;
        _reflections = _storage.getAllReflections();
        _titleController.clear();
        _contentController.clear();
        _tagsController.clear();
        _audioMemoPath = null;
        _videoReflectionPath = null;
        _editingReflectionId = null;
      });

      widget.onEntrySaved?.call();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.emeraldSuccess, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.loc.reflectionSavedSuccess,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.surfaceElevated,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _handleSaveInputOutput1to3() async {
    final source = _sourceTitleController.text.trim();
    final t1 = _takeaway1Controller.text.trim();
    final t2 = _takeaway2Controller.text.trim();
    final t3 = _takeaway3Controller.text.trim();
    final app = _contentController.text.trim();

    if (source.isEmpty && t1.isEmpty && t2.isEmpty && t3.isEmpty) {
      HapticService.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.loc.enterSourceOrTakeawayPrompt,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFFD97706),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    HapticService.selectionClick();

    final now = DateTime.now();
    final id = _editingReflectionId ?? 'ref_io_${now.millisecondsSinceEpoch}';
    final title = source.isNotEmpty
        ? '1:3 • $source'
        : context.loc.oneThreeOutputTakeaways;

    final reflection = ReflectionEntry(
      id: id,
      title: title,
      content: app,
      category: ReflectionCategory.inputOutput1to3,
      createdAt: now,
      sourceTitle: source.isNotEmpty ? source : null,
      takeaway1: t1.isNotEmpty ? t1 : null,
      takeaway2: t2.isNotEmpty ? t2 : null,
      takeaway3: t3.isNotEmpty ? t3 : null,
      audioMemoPath: _audioMemoPath,
      videoReflectionPath: _videoReflectionPath,
      tags: ['1:3', if (source.isNotEmpty) source],
    );

    await _storage.saveReflection(reflection);

    if (mounted) {
      setState(() {
        _isSaving = false;
        _reflections = _storage.getAllReflections();
        _sourceTitleController.clear();
        _takeaway1Controller.clear();
        _takeaway2Controller.clear();
        _takeaway3Controller.clear();
        _contentController.clear();
        _audioMemoPath = null;
        _videoReflectionPath = null;
        _editingReflectionId = null;
      });

      widget.onEntrySaved?.call();
      HapticService.success();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.emeraldSuccess, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.loc.oneThreeOutputSavedSuccess,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.surfaceElevated,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _handleEditReflection(ReflectionEntry entry) {
    HapticService.selectionClick();
    setState(() {
      _editingReflectionId = entry.id;
      _selectedCategory = entry.category;
      _activeSegment = 0; // Switch to Compose tab
      if (entry.category == ReflectionCategory.dailyReview) {
        _outputController.text = entry.content;
        _provocationController.text = entry.distractionAvoided ?? '';
        _reactionScore = entry.reactionScore ?? 4;
        _boundaryMaintained = entry.boundaryMaintained ?? true;
      } else if (entry.category == ReflectionCategory.inputOutput1to3) {
        _sourceTitleController.text = entry.sourceTitle ?? '';
        _takeaway1Controller.text = entry.takeaway1 ?? '';
        _takeaway2Controller.text = entry.takeaway2 ?? '';
        _takeaway3Controller.text = entry.takeaway3 ?? '';
        _contentController.text = entry.content;
      } else {
        _titleController.text = entry.title;
        _contentController.text = entry.content;
        _tagsController.text = entry.tags.join(', ');
      }
      _audioMemoPath = entry.audioMemoPath;
      _videoReflectionPath = entry.videoReflectionPath;
    });
  }

  Future<void> _handleDeleteReflection(String id) async {
    HapticService.selectionClick();
    await _storage.deleteReflection(id);
    if (id.startsWith('entry_')) {
      final dateKey = id.replaceFirst('entry_', '');
      await _repository.deleteEntry(dateKey);
    }
    _loadData();
    widget.onEntrySaved?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isHindi = context.loc.isHindi;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.space16,
            vertical: AppDimens.space16,
          ),
          children: [
            // Screen Header: Pillar 3 - संज्ञान / Cognition
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.loc.pillar3CognitionHeader,
                        style: AppTextStyles.labelBadge.copyWith(
                          color: AppColors.shieldPrimary,
                          letterSpacing: 2.0,
                          fontSize: 9.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.loc.cognitionWorkspaceTitle,
                        style: AppTextStyles.displayMedium.copyWith(fontSize: 20),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock_outline_rounded, size: 12, color: AppColors.emeraldSuccess),
                      const SizedBox(width: 4),
                      Text(
                        '100% PRIVATE',
                        style: AppTextStyles.labelBadge.copyWith(
                          color: AppColors.emeraldSuccess,
                          fontSize: 9.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              context.loc.cognitionWorkspaceSubtitle,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),

            // Top Segment Switcher: [ लेखन / COMPOSE | इतिहास / TIMELINE | मीडिया वॉल्ट / MEDIA VAULT ]
            _buildTopSegmentSwitcher(isHindi),
            const SizedBox(height: 16),

            // Segment Content Rendering
            if (_activeSegment == 0) ...[
              _buildAuthoringView(isHindi),
            ] else if (_activeSegment == 1) ...[
              ReflectionTimelineView(
                entries: _reflections,
                onDelete: _handleDeleteReflection,
                onEdit: _handleEditReflection,
              ),
            ] else ...[
              MediaRecordingsVaultView(
                onMediaChanged: _loadData,
              ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Top Segment Switcher (Compose | Timeline | Media Vault)
  // ---------------------------------------------------------------------------
  Widget _buildTopSegmentSwitcher(bool isHindi) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          _buildSegmentItem(0, context.loc.composeSegment, Icons.edit_note_rounded),
          const SizedBox(width: 4),
          _buildSegmentItem(1, context.loc.timelineSegment, Icons.timeline_rounded),
          const SizedBox(width: 4),
          _buildSegmentItem(2, context.loc.mediaVaultSegment, Icons.shield_outlined),
        ],
      ),
    );
  }

  Widget _buildSegmentItem(int index, String label, IconData icon) {
    final isSelected = _activeSegment == index;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (_activeSegment != index) {
              HapticService.selectionClick();
              setState(() => _activeSegment = index);
            }
          },
          borderRadius: BorderRadius.circular(6),
          child: Container(
            constraints: const BoxConstraints(minHeight: 44),
            padding: const EdgeInsets.symmetric(vertical: 8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.surfaceElevated : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: isSelected
                  ? Border.all(color: AppColors.shieldPrimary, width: 1.2)
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: isSelected ? AppColors.shieldPrimary : AppColors.textMuted,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppColors.shieldPrimary : AppColors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Authoring View (Category Pills + Forms)
  // ---------------------------------------------------------------------------
  Widget _buildAuthoringView(bool isHindi) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Selection Pills (Universal Pillars)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildCategoryPill(
                ReflectionCategory.dailyReview,
                context.loc.catDailyReview,
                Icons.rate_review_rounded,
                AppColors.shieldPrimary,
              ),
              const SizedBox(width: 6),
              _buildCategoryPill(
                ReflectionCategory.inputOutput1to3,
                context.loc.catInputOutput1to3,
                Icons.menu_book_rounded,
                const Color(0xFFF59E0B),
              ),
              const SizedBox(width: 6),
              _buildCategoryPill(
                ReflectionCategory.personalJournal,
                context.loc.catPersonalJournal,
                Icons.auto_stories_rounded,
                const Color(0xFF38BDF8),
              ),
              const SizedBox(width: 6),
              _buildCategoryPill(
                ReflectionCategory.saveToVault,
                context.loc.catSaveToVault,
                Icons.bookmark_add_rounded,
                const Color(0xFFF59E0B),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        if (_editingReflectionId != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.shieldPrimary.withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.edit_note_rounded, size: 16, color: AppColors.shieldPrimary),
                    const SizedBox(width: 6),
                    Text(
                      context.loc.editingReflectionBadge,
                      style: AppTextStyles.labelBadge.copyWith(
                        color: AppColors.shieldPrimary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    HapticService.selectionClick();
                    setState(() {
                      _editingReflectionId = null;
                      _titleController.clear();
                      _contentController.clear();
                      _tagsController.clear();
                      _sourceTitleController.clear();
                      _takeaway1Controller.clear();
                      _takeaway2Controller.clear();
                      _takeaway3Controller.clear();
                      _audioMemoPath = null;
                      _videoReflectionPath = null;
                    });
                  },
                  child: Text(
                    context.loc.cancelEditAction,
                    style: const TextStyle(fontSize: 11, color: AppColors.roseDanger),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],

        // Category Description Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.shieldPrimary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getCategoryDescription(isHindi),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Active Category Form
        if (_selectedCategory == ReflectionCategory.dailyReview) ...[
          _buildDailyReviewForm(isHindi),
        ] else if (_selectedCategory == ReflectionCategory.inputOutput1to3) ...[
          _buildInputOutput1to3Form(isHindi),
        ] else if (_selectedCategory == ReflectionCategory.saveToVault) ...[
          SaveToSthitaprajnaView(
            onSaved: () {
              _loadData();
              widget.onEntrySaved?.call();
            },
          ),
        ] else ...[
          _buildFreeformReflectionForm(isHindi),
        ],

        const SizedBox(height: 20),

        // Bottom Navigation to Action-Triggers & Character Ledger
        _buildExecutionAndCharacterLedgerCard(),
      ],
    );
  }

  Widget _buildCategoryPill(
    ReflectionCategory category,
    String label,
    IconData icon,
    Color activeColor,
  ) {
    final isSelected = _selectedCategory == category;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticService.selectionClick();
          setState(() {
            _selectedCategory = category;
          });
        },
        borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
        child: Container(
          constraints: const BoxConstraints(minHeight: 40),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withValues(alpha: 0.15) : AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
            border: Border.all(
              color: isSelected ? activeColor : AppColors.borderSubtle,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? activeColor : AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.labelBadge.copyWith(
                  color: isSelected ? activeColor : AppColors.textSecondary,
                  fontSize: 9.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCategoryDescription(bool isHindi) {
    switch (_selectedCategory) {
      case ReflectionCategory.dailyReview:
        return context.loc.catDailyReviewDesc;
      case ReflectionCategory.personalJournal:
        return context.loc.catPersonalJournalDesc;
      case ReflectionCategory.planning:
        return context.loc.catPlanningDesc;
      case ReflectionCategory.selfTalk:
        return context.loc.catSelfTalkDesc;
      case ReflectionCategory.inputOutput1to3:
        return context.loc.catInputOutput1to3Desc;
      case ReflectionCategory.saveToVault:
        return context.loc.catSaveToVaultDesc;
    }
  }

  // ---------------------------------------------------------------------------
  // Category Form 1: Daily Review (दैनिक व्यवहार समीक्षा)
  // ---------------------------------------------------------------------------
  Widget _buildDailyReviewForm(bool isHindi) {
    final isAlreadyLogged = _todayEntry != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Index 1: Reaction Score Slider
        Container(
          padding: const EdgeInsets.all(AppDimens.space16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
            border: Border.all(color: AppColors.borderSubtle, width: 1.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Text(
                      context.loc.index01Badge,
                      style: AppTextStyles.labelBadge.copyWith(
                        color: AppColors.shieldPrimary,
                        fontSize: 9.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.loc.index01Title,
                      style: AppTextStyles.heading.copyWith(fontSize: 14.0),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$_reactionScore / 5',
                    style: AppTextStyles.metricMedium.copyWith(
                      color: _getReactionColor(_reactionScore),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                context.loc.index01Question,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 13.0,
                ),
              ),
              const SizedBox(height: 12),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: _getReactionColor(_reactionScore),
                  thumbColor: AppColors.textPrimary,
                  overlayColor: _getReactionColor(_reactionScore).withValues(alpha: 0.2),
                ),
                child: Slider(
                  value: _reactionScore.toDouble(),
                  min: 1.0,
                  max: 5.0,
                  divisions: 4,
                  onChanged: (newValue) {
                    final rounded = newValue.round();
                    if (rounded != _reactionScore) {
                      HapticService.lightImpact();
                      setState(() => _reactionScore = rounded);
                    }
                  },
                ),
              ),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getReactionColor(_reactionScore).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: _getReactionColor(_reactionScore).withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    _getReactionScoreLabel(_reactionScore),
                    style: AppTextStyles.labelBadge.copyWith(
                      color: _getReactionColor(_reactionScore),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Index 2: Boundary Integrity Check (Yes / No)
        Container(
          padding: const EdgeInsets.all(AppDimens.space16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
            border: Border.all(color: AppColors.borderSubtle, width: 1.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Text(
                      context.loc.index02Badge,
                      style: AppTextStyles.labelBadge.copyWith(
                        color: AppColors.shieldPrimary,
                        fontSize: 9.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.loc.index02Title,
                      style: AppTextStyles.heading.copyWith(fontSize: 14.0),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: (_boundaryMaintained ? AppColors.emeraldSuccess : AppColors.roseDanger)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: (_boundaryMaintained ? AppColors.emeraldSuccess : AppColors.roseDanger)
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      _boundaryMaintained
                          ? context.loc.boundaryMaintainedBadge
                          : context.loc.boundaryCompromisedBadge,
                      style: AppTextStyles.labelBadge.copyWith(
                        color: _boundaryMaintained ? AppColors.emeraldSuccess : AppColors.roseDanger,
                        fontSize: 9.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                context.loc.index02Question,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 13.0,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (!_boundaryMaintained) {
                          HapticService.selectionClick();
                          setState(() => _boundaryMaintained = true);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _boundaryMaintained ? AppColors.emeraldMuted : AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _boundaryMaintained ? AppColors.emeraldSuccess : AppColors.borderSubtle,
                            width: _boundaryMaintained ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 15,
                              color: _boundaryMaintained ? AppColors.emeraldSuccess : AppColors.textMuted,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              context.loc.boundaryYesShort,
                              style: TextStyle(
                                fontSize: 13,
                                color: _boundaryMaintained ? AppColors.emeraldSuccess : AppColors.textSecondary,
                                fontWeight: _boundaryMaintained ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (_boundaryMaintained) {
                          HapticService.selectionClick();
                          setState(() => _boundaryMaintained = false);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: !_boundaryMaintained ? AppColors.roseMuted : AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: !_boundaryMaintained ? AppColors.roseDanger : AppColors.borderSubtle,
                            width: !_boundaryMaintained ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cancel_rounded,
                              size: 15,
                              color: !_boundaryMaintained ? AppColors.roseDanger : AppColors.textMuted,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              context.loc.boundaryNoShort,
                              style: TextStyle(
                                fontSize: 13,
                                color: !_boundaryMaintained ? AppColors.roseDanger : AppColors.textSecondary,
                                fontWeight: !_boundaryMaintained ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Index 3: Primary Task & Distraction Control
        Container(
          padding: const EdgeInsets.all(AppDimens.space16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
            border: Border.all(color: AppColors.borderSubtle, width: 1.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: const Icon(Icons.track_changes_rounded, size: 16, color: AppColors.shieldPrimary),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.loc.index03Title,
                      style: AppTextStyles.heading.copyWith(fontSize: 14.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      context.loc.index03Tag,
                      style: AppTextStyles.labelBadge.copyWith(
                        fontSize: 9.0,
                        color: AppColors.shieldPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                context.loc.index03OutputQuestion,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 13.0,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _outputController,
                maxLines: 1,
                maxLength: 140,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: context.loc.index03OutputHint,
                  hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 12.5),
                  prefixIcon: const Icon(Icons.bolt_rounded, size: 18, color: AppColors.shieldPrimary),
                  suffixIcon: VoiceDictationButton(controller: _outputController),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.loc.index03ProvocationQuestion,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 12.0),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _provocationController,
                maxLines: 1,
                maxLength: 140,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: context.loc.index03ProvocationHint,
                  hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 12.5),
                  prefixIcon: const Icon(Icons.shield_outlined, size: 16, color: AppColors.amberWarning),
                  suffixIcon: VoiceDictationButton(controller: _provocationController),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Multimodal Media Reflection (Audio Memo & 60s Video Drill)
        _buildMediaAttachmentsWidget(isHindi),
        const SizedBox(height: 20),

        // Action Button: Save / Lock Daily Audit
        SizedBox(
          width: double.infinity,
          height: AppDimens.buttonHeight,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _handleSaveDailyReview,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.textPrimary,
              foregroundColor: AppColors.background,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMedium)),
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.background),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock_outline_rounded, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        isAlreadyLogged ? context.loc.updateDayButton : context.loc.lockDayButton,
                        style: AppTextStyles.button.copyWith(color: AppColors.background, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Category Form: 1:3 Input-Output Logger (1:3 आउटपुट लॉगर)
  // ---------------------------------------------------------------------------
  Widget _buildInputOutput1to3Form(bool isHindi) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppDimens.space16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
            border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.menu_book_rounded, size: 16, color: Color(0xFFF59E0B)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.loc.oneThreeEngineHeader,
                      style: AppTextStyles.heading.copyWith(fontSize: 14.5),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '3 TAKEAWAYS',
                      style: AppTextStyles.labelBadge.copyWith(
                        fontSize: 8.5,
                        color: const Color(0xFFF59E0B),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Source Title
              Text(
                context.loc.sourceTitleLabel,
                style: AppTextStyles.labelBadge.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _sourceTitleController,
                style: AppTextStyles.heading.copyWith(fontSize: 14),
                decoration: InputDecoration(
                  hintText: context.loc.sourceTitleHint,
                  hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 12),
                  prefixIcon: const Icon(Icons.source_rounded, size: 18, color: Color(0xFFF59E0B)),
                  suffixIcon: VoiceDictationButton(controller: _sourceTitleController),
                ),
              ),
              const SizedBox(height: 16),

              // Section Header: 3 Mandatory Takeaways
              Row(
                children: [
                  const Icon(Icons.format_list_numbered_rounded, size: 14, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 6),
                  Text(
                    context.loc.threeMandatoryTakeaways,
                    style: AppTextStyles.labelBadge.copyWith(
                      color: const Color(0xFFF59E0B),
                      letterSpacing: 1.2,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Takeaway 1
              _buildTakeawayInputField(
                index: 1,
                controller: _takeaway1Controller,
                label: context.loc.takeaway1Label,
                hint: context.loc.takeaway1Hint,
              ),
              const SizedBox(height: 10),

              // Takeaway 2
              _buildTakeawayInputField(
                index: 2,
                controller: _takeaway2Controller,
                label: context.loc.takeaway2Label,
                hint: context.loc.takeaway2Hint,
              ),
              const SizedBox(height: 10),

              // Takeaway 3
              _buildTakeawayInputField(
                index: 3,
                controller: _takeaway3Controller,
                label: context.loc.takeaway3Label,
                hint: context.loc.takeaway3Hint,
              ),
              const SizedBox(height: 16),

              // Practical Application
              Text(
                context.loc.practicalApplicationLabel,
                style: AppTextStyles.labelBadge.copyWith(
                  color: const Color(0xFF10B981),
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _contentController,
                maxLines: 3,
                style: AppTextStyles.bodyMedium.copyWith(fontSize: 13, height: 1.4),
                decoration: InputDecoration(
                  hintText: context.loc.practicalApplicationHint,
                  hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 12),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 30),
                    child: Icon(Icons.bolt_rounded, size: 18, color: Color(0xFF10B981)),
                  ),
                  suffixIcon: VoiceDictationButton(controller: _contentController),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Multimodal Attachments
        _buildMediaAttachmentsWidget(isHindi),
        const SizedBox(height: 20),

        // Save Button
        SizedBox(
          width: double.infinity,
          height: AppDimens.buttonHeight,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _handleSaveInputOutput1to3,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: AppColors.background,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMedium)),
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.background),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        context.loc.saveOneThreeOutput,
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.background,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildTakeawayInputField({
    required int index,
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 18,
              height: 18,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Text(
                '$index',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF59E0B),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.labelBadge.copyWith(fontSize: 9.5, color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: 2,
          style: AppTextStyles.bodyMedium.copyWith(fontSize: 12.5),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 11.5),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            suffixIcon: VoiceDictationButton(controller: controller),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Category Form 2: Freeform Reflections (Journal, Planning, Self-Talk)
  // ---------------------------------------------------------------------------
  Widget _buildFreeformReflectionForm(bool isHindi) {
    String titleHint;
    String contentHint;
    IconData headerIcon;

    if (_selectedCategory == ReflectionCategory.personalJournal) {
      titleHint = context.loc.journalTitleOptional;
      contentHint = context.loc.journalFreeformHint;
      headerIcon = Icons.auto_stories_rounded;
    } else if (_selectedCategory == ReflectionCategory.planning) {
      titleHint = context.loc.planningObjectiveOptional;
      contentHint = context.loc.planningObjectiveHint;
      headerIcon = Icons.alt_route_rounded;
    } else {
      titleHint = context.loc.selfTalkThemeOptional;
      contentHint = context.loc.selfTalkScriptHint;
      headerIcon = Icons.record_voice_over_rounded;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppDimens.space16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Row
              TextField(
                controller: _titleController,
                style: AppTextStyles.heading.copyWith(fontSize: 15),
                decoration: InputDecoration(
                  hintText: titleHint,
                  hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
                  prefixIcon: Icon(headerIcon, size: 18, color: AppColors.shieldPrimary),
                  suffixIcon: VoiceDictationButton(controller: _titleController),
                ),
              ),
              const SizedBox(height: 12),

              // Content Area
              TextField(
                controller: _contentController,
                maxLines: 6,
                style: AppTextStyles.bodyMedium.copyWith(height: 1.45),
                decoration: InputDecoration(
                  hintText: contentHint,
                  hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 12.5),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  VoiceDictationButton(controller: _contentController),
                ],
              ),
              const SizedBox(height: 8),

              // Tags Input
              TextField(
                controller: _tagsController,
                style: AppTextStyles.bodySmall,
                decoration: InputDecoration(
                  hintText: context.loc.tagsInputHint,
                  hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 11),
                  prefixIcon: const Icon(Icons.tag_rounded, size: 16, color: AppColors.textMuted),
                  isDense: true,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Multimodal Attachments
        _buildMediaAttachmentsWidget(isHindi),
        const SizedBox(height: 20),

        // Save Button
        SizedBox(
          width: double.infinity,
          height: AppDimens.buttonHeight,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _handleSaveFreeformReflection,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.shieldPrimary,
              foregroundColor: AppColors.background,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMedium)),
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.background),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        context.loc.saveReflectionButton,
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.background,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Multimodal Media Attachments (Audio & Video)
  // ---------------------------------------------------------------------------
  Widget _buildMediaAttachmentsWidget(bool isHindi) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.space14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.perm_media_outlined, size: 16, color: AppColors.shieldPrimary),
              const SizedBox(width: 8),
              Text(
                context.loc.multimodalAttachmentsOptional,
                style: AppTextStyles.labelBadge.copyWith(
                  color: AppColors.shieldPrimary,
                  fontSize: 9.0,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Audio Memo Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _audioMemoPath != null ? AppColors.emeraldSuccess : AppColors.borderSubtle,
                width: _audioMemoPath != null ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              children: [
                if (_audioMemoPath != null)
                  IconButton(
                    icon: Icon(
                      _isPlayingAudioMemo
                          ? Icons.pause_circle_filled_rounded
                          : Icons.play_circle_fill_rounded,
                      size: 28,
                      color: _isPlayingAudioMemo
                          ? AppColors.shieldPrimary
                          : AppColors.emeraldSuccess,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: _toggleAudioMemoPlayback,
                    tooltip: _isPlayingAudioMemo
                        ? context.loc.pauseAudioAction
                        : context.loc.playAudioAction,
                  )
                else
                  const Icon(
                    Icons.mic_none_rounded,
                    size: 18,
                    color: AppColors.shieldPrimary,
                  ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _audioMemoPath != null
                            ? (_isPlayingAudioMemo
                                ? context.loc.playingAudioMemo
                                : context.loc.audioMemoAttached)
                            : context.loc.recordVoiceMemoPrompt,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: _audioMemoPath != null ? FontWeight.w700 : FontWeight.w400,
                          color: _audioMemoPath != null ? AppColors.emeraldSuccess : AppColors.textSecondary,
                        ),
                      ),
                      if (_audioMemoPath != null)
                        Text(
                          _isPlayingAudioMemo
                              ? context.loc.tapToPausePrompt
                              : context.loc.tapToListenPrompt,
                          style: TextStyle(
                            fontSize: 9.5,
                            color: _isPlayingAudioMemo ? AppColors.shieldPrimary : AppColors.textMuted,
                          ),
                        ),
                    ],
                  ),
                ),
                if (_audioMemoPath != null) ...[
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.roseDanger),
                    onPressed: () {
                      if (_isPlayingAudioMemo) {
                        _audioMemoPlayer?.stop();
                        _isPlayingAudioMemo = false;
                      }
                      setState(() => _audioMemoPath = null);
                    },
                    tooltip: context.loc.deleteAction,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
                TextButton.icon(
                  onPressed: () async {
                    if (_isPlayingAudioMemo) {
                      await _audioMemoPlayer?.stop();
                      setState(() => _isPlayingAudioMemo = false);
                    }
                    HapticService.selectionClick();
                    final res = await AudioMemoRecorderModal.show(context, existingPath: _audioMemoPath);
                    if (res != null) {
                      setState(() => _audioMemoPath = res);
                      final todayKey = DateHelpers.toStorageKey(DateTime.now());
                      await MediaVaultService().registerMedia(
                        filePath: res,
                        mediaType: 'audio',
                        parentJournalDateKey: todayKey,
                      );
                    }
                  },
                  icon: Icon(
                    _audioMemoPath != null ? Icons.tune_rounded : Icons.mic_rounded,
                    size: 14,
                    color: AppColors.shieldPrimary,
                  ),
                  label: Text(
                    _audioMemoPath != null ? context.loc.updateAction : context.loc.recordAction,
                    style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.shieldPrimary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Video Reflection Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _videoReflectionPath != null ? AppColors.emeraldSuccess : AppColors.borderSubtle,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _videoReflectionPath != null ? Icons.videocam_rounded : Icons.videocam_outlined,
                  size: 18,
                  color: _videoReflectionPath != null ? AppColors.emeraldSuccess : AppColors.shieldPrimary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _videoReflectionPath != null
                        ? context.loc.sixtySecVideoAttached
                        : context.loc.sixtySecVideoPrompt,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: _videoReflectionPath != null ? FontWeight.w600 : FontWeight.w400,
                      color: _videoReflectionPath != null ? AppColors.emeraldSuccess : AppColors.textSecondary,
                    ),
                  ),
                ),
                if (_videoReflectionPath != null) ...[
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.roseDanger),
                    onPressed: () => setState(() => _videoReflectionPath = null),
                  ),
                ],
                TextButton(
                  onPressed: () async {
                    HapticService.selectionClick();
                    final res = await VideoReflectionDrillModal.show(context, existingPath: _videoReflectionPath);
                    if (res != null) {
                      setState(() => _videoReflectionPath = res);
                      final todayKey = DateHelpers.toStorageKey(DateTime.now());
                      await MediaVaultService().registerMedia(
                        filePath: res,
                        mediaType: 'video',
                        parentJournalDateKey: todayKey,
                      );
                    }
                  },
                  child: Text(
                    _videoReflectionPath != null ? context.loc.retakeAction : context.loc.drillAction,
                    style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Action-Triggers & Virtue Journal Card (Execution Chimes & Character Ledger)
  // ---------------------------------------------------------------------------
  Widget _buildExecutionAndCharacterLedgerCard() {
    return Container(
      padding: const EdgeInsets.all(AppDimens.space14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.notifications_active_outlined,
                  size: 18,
                  color: Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.loc.executionAndCharacterLedgerHeader,
                      style: AppTextStyles.labelBadge.copyWith(
                        color: const Color(0xFF10B981),
                        fontSize: 8.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.loc.actionTriggersAndVirtueSub,
                      style: AppTextStyles.heading,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            context.loc.executionLedgerDescription,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticService.selectionClick();
                    ExecutionTriggerScreen.open(context);
                  },
                  icon: const Icon(Icons.bolt_rounded, size: 14),
                  label: Text(
                    context.loc.executionChimeButton,
                    style: const TextStyle(fontSize: 10.5),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF10B981),
                    side: const BorderSide(color: Color(0xFF10B981)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticService.selectionClick();
                    CharacterLedgerScreen.open(context);
                  },
                  icon: const Icon(Icons.anchor_rounded, size: 14),
                  label: Text(
                    context.loc.characterLedgerButton,
                    style: const TextStyle(fontSize: 10.5),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFF59E0B),
                    side: const BorderSide(color: Color(0xFFF59E0B)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
