import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/date_helpers.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../data/models/journal_models.dart';
import '../../data/repositories/journal_repository.dart';
import '../../../../shared/widgets/voice_dictation_button.dart';
import '../widgets/audio_memo_recorder_modal.dart';
import '../widgets/video_reflection_drill_modal.dart';
import '../widgets/past_debriefs_list.dart';

/// JournalScreen implements the official 60-Second Evening Debrief Mapping.
/// Title: दैनिक हिसाब (Daily Closure)
class JournalScreen extends StatefulWidget {
  final VoidCallback? onEntrySaved;

  const JournalScreen({super.key, this.onEntrySaved});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final JournalRepository _repository = JournalRepository();
  final TextEditingController _outputController = TextEditingController();
  final TextEditingController _provocationController = TextEditingController();

  // 1 to 5 Reaction Score (1 = भड़का, 5 = स्थितप्रज्ञ)
  int _reactionScore = 4;

  // Boundary Integrity Check (Yes / No)
  bool _boundaryMaintained = true;

  bool _isSaving = false;
  List<DailyJournalEntry> _historicalEntries = [];
  DailyJournalEntry? _todayEntry;
  String? _audioMemoPath;
  String? _videoReflectionPath;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _historicalEntries = _repository.getAllEntries();
    _todayEntry = _repository.getTodayEntry();

    if (_todayEntry != null) {
      _reactionScore = _todayEntry!.reactionControlScore;
      _boundaryMaintained = _todayEntry!.boundaryMaintained;
      _outputController.text = _todayEntry!.coreOutputSummary;
      _provocationController.text = _todayEntry!.provocationHandled ?? '';
      _audioMemoPath = _todayEntry!.audioMemoPath;
      _videoReflectionPath = _todayEntry!.videoReflectionPath;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _outputController.dispose();
    _provocationController.dispose();
    super.dispose();
  }

  String _getReactionScoreLabel(int score) {
    switch (score) {
      case 1:
        return '1: भड़का (Lost Control)';
      case 2:
        return '2: तनाव में बोला (Under Strain)';
      case 3:
        return '3: न्यूट्रल रहा (Neutral)';
      case 4:
        return '4: पूर्ण नियंत्रण (High Poise)';
      case 5:
        return '5: स्थितप्रज्ञ (Absolute Stoic)';
      default:
        return '3: न्यूट्रल रहा';
    }
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

  Future<void> _handleLockDay() async {
    final text = _outputController.text.trim();
    if (text.isEmpty) {
      HapticService.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'आउटपुट अनिवार्य है: आज का कोई एक ठोस deliverable या सीख दर्ज करें।',
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

    final entry = DailyJournalEntry(
      id: 'entry_$todayKey',
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

    await _repository.saveEntry(entry);

    if (mounted) {
      setState(() {
        _isSaving = false;
        _todayEntry = entry;
        _historicalEntries = _repository.getAllEntries();
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
                  'आज का हिसाब पूरा हुआ। तनाव यहीं विसर्जित है। (Equanimity: ${entry.compositeScore}%)',
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

  Future<void> _handleDelete(String dateKey) async {
    await _repository.deleteEntry(dateKey);
    _loadData();
    widget.onEntrySaved?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isAlreadyLogged = _todayEntry != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.space16,
            vertical: AppDimens.space16,
          ),
          children: [
            // Screen Header: "दैनिक हिसाब (Daily Closure)"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '60-SECOND EVENING LOG',
                      style: AppTextStyles.labelBadge.copyWith(
                        color: AppColors.shieldPrimary,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'दैनिक हिसाब (Daily Closure)',
                      style: AppTextStyles.displayMedium,
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isAlreadyLogged
                        ? AppColors.emeraldMuted
                        : AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                    border: Border.all(
                      color: isAlreadyLogged
                          ? AppColors.emeraldSuccess
                          : AppColors.borderSubtle,
                    ),
                  ),
                  child: Text(
                    isAlreadyLogged ? 'हिसाब बंद (LOCKED)' : 'लंबित (PENDING)',
                    style: AppTextStyles.labelBadge.copyWith(
                      color: isAlreadyLogged
                          ? AppColors.emeraldSuccess
                          : AppColors.amberWarning,
                      fontSize: 9.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '60 सेकंड में मानसिक शटडाउन। उकसावे पर चित्त की स्थिरता, मर्यादा की जाँच और आज का ठोस आउटपुट दर्ज करें।',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),

            // -------------------------------------------------------------
            // Index 1: Reaction Score Slider
            // Label: "आज उकसावे पर चित्त कितना स्थिर रहा?"
            // -------------------------------------------------------------
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.borderSubtle),
                            ),
                            child: Text(
                              'INDEX 01',
                              style: AppTextStyles.labelBadge.copyWith(
                                color: AppColors.shieldPrimary,
                                fontSize: 9.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'REACTION SCORE',
                            style: AppTextStyles.heading.copyWith(
                              fontSize: 14.5,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '$_reactionScore / 5',
                        style: AppTextStyles.metricMedium.copyWith(
                          color: _getReactionColor(_reactionScore),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'आज उकसावे पर चित्त कितना स्थिर रहा?',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                      fontSize: 13.0,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Slider from 1 to 5
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: _getReactionColor(_reactionScore),
                      thumbColor: AppColors.textPrimary,
                      overlayColor: _getReactionColor(_reactionScore)
                          .withOpacity(0.2),
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

                  // Dynamic Value Indicator
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getReactionColor(_reactionScore)
                            .withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: _getReactionColor(_reactionScore)
                              .withOpacity(0.5),
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

            // -------------------------------------------------------------
            // Index 2: Boundary Integrity Check (Yes / No Toggle)
            // Label: "क्या आज बिना सफाई दिए 'ना' कहने की मर्यादा बची रही?"
            // -------------------------------------------------------------
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.borderSubtle),
                            ),
                            child: Text(
                              'INDEX 02',
                              style: AppTextStyles.labelBadge.copyWith(
                                color: AppColors.shieldPrimary,
                                fontSize: 9.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'BOUNDARY INTEGRITY',
                            style: AppTextStyles.heading.copyWith(
                              fontSize: 14.5,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _boundaryMaintained ? 'मर्यादा सुरक्षित' : 'सीमा खंडित',
                        style: AppTextStyles.labelBadge.copyWith(
                          color: _boundaryMaintained
                              ? AppColors.emeraldSuccess
                              : AppColors.roseDanger,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'क्या आज बिना सफाई दिए \'ना\' कहने की मर्यादा बची रही?',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                      fontSize: 13.0,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Slider 2: Boundary Integrity Slider (1 to 5)
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: _boundaryMaintained
                          ? AppColors.emeraldSuccess
                          : AppColors.roseDanger,
                      thumbColor: AppColors.textPrimary,
                      overlayColor:
                          (_boundaryMaintained
                                  ? AppColors.emeraldSuccess
                                  : AppColors.roseDanger)
                              .withOpacity(0.2),
                    ),
                    child: Slider(
                      value: _boundaryMaintained ? 5.0 : 1.0,
                      min: 1.0,
                      max: 5.0,
                      divisions: 4,
                      onChanged: (newValue) {
                        final val = newValue >= 3.0;
                        if (val != _boundaryMaintained) {
                          HapticService.lightImpact();
                          setState(() => _boundaryMaintained = val);
                        }
                      },
                    ),
                  ),

                  // Interactive Toggle Pills [हाँ (Yes) / नहीं (No)]
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
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _boundaryMaintained
                                  ? AppColors.emeraldMuted
                                  : AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _boundaryMaintained
                                    ? AppColors.emeraldSuccess
                                    : AppColors.borderSubtle,
                                width: _boundaryMaintained ? 1.5 : 1.0,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 16,
                                  color: _boundaryMaintained
                                      ? AppColors.emeraldSuccess
                                      : AppColors.textMuted,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'हाँ (YES • मर्यादा बची)',
                                  style: AppTextStyles.button.copyWith(
                                    fontSize: 12,
                                    color: _boundaryMaintained
                                        ? AppColors.emeraldSuccess
                                        : AppColors.textSecondary,
                                    fontWeight: _boundaryMaintained
                                        ? FontWeight.w700
                                        : FontWeight.w400,
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
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: !_boundaryMaintained
                                  ? AppColors.roseMuted
                                  : AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: !_boundaryMaintained
                                    ? AppColors.roseDanger
                                    : AppColors.borderSubtle,
                                width: !_boundaryMaintained ? 1.5 : 1.0,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.cancel_rounded,
                                  size: 16,
                                  color: !_boundaryMaintained
                                      ? AppColors.roseDanger
                                      : AppColors.textMuted,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'नहीं (NO • समझौता हुआ)',
                                  style: AppTextStyles.button.copyWith(
                                    fontSize: 12,
                                    color: !_boundaryMaintained
                                        ? AppColors.roseDanger
                                        : AppColors.textSecondary,
                                    fontWeight: !_boundaryMaintained
                                        ? FontWeight.w700
                                        : FontWeight.w400,
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

            // -------------------------------------------------------------
            // Index 3: Core Solid Output (Single-Line)
            // Label: "आज का सबसे ठोस, मौलिक (Zero-AI) आउटपुट:"
            // Placeholder: "उदा. कॉर्पोरेट टैक्स पर 800 शब्दों का एक्सक्लूसिव विश्लेषण"
            // -------------------------------------------------------------
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.borderSubtle),
                            ),
                            child: Text(
                              'INDEX 03',
                              style: AppTextStyles.labelBadge.copyWith(
                                color: AppColors.shieldPrimary,
                                fontSize: 9.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'CORE SOLID OUTPUT',
                            style: AppTextStyles.heading.copyWith(
                              fontSize: 14.5,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'ZERO-AI • SINGLE-LINE',
                        style: AppTextStyles.labelBadge.copyWith(
                          fontSize: 9.0,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'आज का सबसे ठोस, मौलिक (Zero-AI) आउटपुट:',
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
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'उदा. कॉर्पोरेट टैक्स पर 800 शब्दों का एक्सक्लूसिव विश्लेषण',
                      hintStyle: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 12.5,
                      ),
                      counterStyle: AppTextStyles.metricSmall.copyWith(
                        fontSize: 10,
                      ),
                      prefixIcon: const Icon(
                        Icons.bolt_rounded,
                        size: 18,
                        color: AppColors.shieldPrimary,
                      ),
                      suffixIcon: VoiceDictationButton(controller: _outputController),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Optional Strategic Reflection
                  Text(
                    'उकसावे का समाधान / रणनीतिक सीख (Optional 1-liner):',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _provocationController,
                    maxLines: 1,
                    maxLength: 140,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                      hintText: 'उदा. मीटिंग में 4 सेकंड पॉज देकर बात संभाली',
                      hintStyle: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 12.5,
                      ),
                      counterStyle: AppTextStyles.metricSmall.copyWith(
                        fontSize: 10,
                      ),
                      prefixIcon: const Icon(
                        Icons.shield_outlined,
                        size: 16,
                        color: AppColors.amberWarning,
                      ),
                      suffixIcon: VoiceDictationButton(controller: _provocationController),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // -------------------------------------------------------------
            // Media Reflection: Audio Memo & 60s Video Composure Review
            // -------------------------------------------------------------
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.borderSubtle),
                            ),
                            child: Text(
                              'MEDIA AUDIT',
                              style: AppTextStyles.labelBadge.copyWith(
                                color: AppColors.shieldPrimary,
                                fontSize: 9.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'REFLECTIVE MEDIA (OPTIONAL)',
                            style: AppTextStyles.heading.copyWith(fontSize: 14.0),
                          ),
                        ],
                      ),
                      Text(
                        '100% ON-DEVICE',
                        style: AppTextStyles.labelBadge.copyWith(
                          fontSize: 9.0,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Capture a discreet verbal audio memo or a 60-second front-camera composure review.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12.0,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Option 1: Quick Audio Memo
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _audioMemoPath != null
                            ? AppColors.emeraldSuccess.withValues(alpha: 0.4)
                            : AppColors.borderSubtle,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _audioMemoPath != null
                                ? AppColors.emeraldSuccess.withValues(alpha: 0.15)
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            _audioMemoPath != null
                                ? Icons.mic_rounded
                                : Icons.mic_none_rounded,
                            size: 18,
                            color: _audioMemoPath != null
                                ? AppColors.emeraldSuccess
                                : AppColors.shieldPrimary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _audioMemoPath != null
                                    ? 'VERBAL MEMO ATTACHED'
                                    : 'QUICK AUDIO MEMO',
                                style: AppTextStyles.labelBadge.copyWith(
                                  color: _audioMemoPath != null
                                      ? AppColors.emeraldSuccess
                                      : AppColors.textPrimary,
                                  fontSize: 9.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _audioMemoPath != null
                                    ? 'Local audio note saved with audit'
                                    : 'Record discrete spoken reflections',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_audioMemoPath != null) ...[
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded,
                                size: 18, color: AppColors.roseDanger),
                            tooltip: 'Remove audio memo',
                            onPressed: () {
                              HapticService.lightImpact();
                              setState(() => _audioMemoPath = null);
                            },
                          ),
                          const SizedBox(width: 4),
                        ],
                        OutlinedButton(
                          onPressed: () async {
                            HapticService.selectionClick();
                            final result = await AudioMemoRecorderModal.show(
                              context,
                              existingPath: _audioMemoPath,
                            );
                            if (result != null) {
                              setState(() => _audioMemoPath = result);
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _audioMemoPath != null
                                ? AppColors.emeraldSuccess
                                : AppColors.textPrimary,
                            side: BorderSide(
                              color: _audioMemoPath != null
                                  ? AppColors.emeraldSuccess
                                  : AppColors.borderMedium,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                          child: Text(
                            _audioMemoPath != null ? 'UPDATE' : 'RECORD',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Option 2: 60-Second Video Composure Review
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _videoReflectionPath != null
                            ? AppColors.emeraldSuccess.withValues(alpha: 0.4)
                            : AppColors.borderSubtle,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _videoReflectionPath != null
                                ? AppColors.emeraldSuccess.withValues(alpha: 0.15)
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            _videoReflectionPath != null
                                ? Icons.videocam_rounded
                                : Icons.videocam_outlined,
                            size: 18,
                            color: _videoReflectionPath != null
                                ? AppColors.emeraldSuccess
                                : AppColors.shieldPrimary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _videoReflectionPath != null
                                    ? 'COMPOSURE DRILL ATTACHED'
                                    : '60-SECOND COMPOSURE DRILL',
                                style: AppTextStyles.labelBadge.copyWith(
                                  color: _videoReflectionPath != null
                                      ? AppColors.emeraldSuccess
                                      : AppColors.textPrimary,
                                  fontSize: 9.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _videoReflectionPath != null
                                    ? 'Front-lens posture review recorded'
                                    : 'Review jaw poise and physical calmness',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_videoReflectionPath != null) ...[
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded,
                                size: 18, color: AppColors.roseDanger),
                            tooltip: 'Remove video reflection',
                            onPressed: () {
                              HapticService.lightImpact();
                              setState(() => _videoReflectionPath = null);
                            },
                          ),
                          const SizedBox(width: 4),
                        ],
                        OutlinedButton(
                          onPressed: () async {
                            HapticService.selectionClick();
                            final result =
                                await VideoReflectionDrillModal.show(
                              context,
                              existingPath: _videoReflectionPath,
                            );
                            if (result != null) {
                              setState(() => _videoReflectionPath = result);
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _videoReflectionPath != null
                                ? AppColors.emeraldSuccess
                                : AppColors.textPrimary,
                            side: BorderSide(
                              color: _videoReflectionPath != null
                                  ? AppColors.emeraldSuccess
                                  : AppColors.borderMedium,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                          child: Text(
                            _videoReflectionPath != null ? 'RETAKE' : 'REVIEW',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // -------------------------------------------------------------
            // Action Button: "हिसाब बंद करें (Lock Day)"
            // -------------------------------------------------------------
            SizedBox(
              width: double.infinity,
              height: AppDimens.buttonHeight,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _handleLockDay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textPrimary,
                  foregroundColor: AppColors.background,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.background,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lock_outline_rounded, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            isAlreadyLogged
                                ? 'हिसाब अपडेट करें (Update Lock)'
                                : 'हिसाब बंद करें (Lock Day)',
                            style: AppTextStyles.button.copyWith(
                              color: AppColors.background,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 32),

            // Historical Audit Logs
            PastDebriefsList(
              entries: _historicalEntries,
              onDelete: _handleDelete,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
