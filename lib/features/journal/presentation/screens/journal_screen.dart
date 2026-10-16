import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/date_helpers.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../data/models/journal_entry.dart';
import '../../data/repositories/journal_repository.dart';
import '../widgets/index_slider.dart';
import '../widgets/past_debriefs_list.dart';
import '../widgets/single_line_output_input.dart';

/// JournalScreen provides the 60-second evening debrief.
/// Built with 2 sliders and 1 single-line text input for zero-friction daily audit.
class JournalScreen extends StatefulWidget {
  final VoidCallback? onEntrySaved;

  const JournalScreen({super.key, this.onEntrySaved});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final JournalRepository _repository = JournalRepository();
  final TextEditingController _outputController = TextEditingController();

  double _reactionControl = 7.0;
  double _boundaryRetained = 8.0;
  bool _isSaving = false;
  List<JournalEntry> _historicalEntries = [];
  JournalEntry? _todayEntry;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _historicalEntries = _repository.getAllEntries();
    _todayEntry = _repository.getTodayEntry();

    if (_todayEntry != null) {
      _reactionControl = _todayEntry!.reactionControl;
      _boundaryRetained = _todayEntry!.boundaryRetained;
      _outputController.text = _todayEntry!.coreOutput;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _outputController.dispose();
    super.dispose();
  }

  Color _getReactionColor(double val) {
    if (val >= 8.0) return AppColors.emeraldSuccess;
    if (val >= 6.0) return AppColors.shieldPrimary;
    if (val >= 4.0) return AppColors.amberWarning;
    return AppColors.roseDanger;
  }

  Color _getBoundaryColor(double val) {
    if (val >= 8.0) return AppColors.emeraldSuccess;
    if (val >= 6.0) return AppColors.shieldPrimary;
    if (val >= 4.0) return AppColors.amberWarning;
    return AppColors.roseDanger;
  }

  String _getReactionStatus(double val) {
    if (val >= 9.0) return 'Absolute Sthitaprajna';
    if (val >= 7.0) return 'High Executive Poise';
    if (val >= 5.0) return 'Controlled Grounding';
    if (val >= 3.0) return 'Internal Turbulence';
    return 'Amygdala Hijacked';
  }

  String _getBoundaryStatus(double val) {
    if (val >= 9.0) return 'Impenetrable Fortress';
    if (val >= 7.0) return 'Firm Professional Pushback';
    if (val >= 5.0) return 'Contained Compromise';
    if (val >= 3.0) return 'Permeable Perimeter';
    return 'Total Boundary Breach';
  }

  Future<void> _handleSaveDebrief() async {
    final text = _outputController.text.trim();
    if (text.isEmpty) {
      HapticService.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Core Output required: Record at least one lesson or decisive win.',
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

    final entry = JournalEntry(
      id: 'entry_$todayKey',
      dateKey: todayKey,
      timestamp: now,
      reactionControl: _reactionControl,
      boundaryRetained: _boundaryRetained,
      coreOutput: text,
    );

    await _repository.saveEntry(entry);

    if (mounted) {
      setState(() {
        _isSaving = false;
        _todayEntry = entry;
        _historicalEntries = _repository.getAllEntries();
      });

      widget.onEntrySaved?.call();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Debrief committed: Equanimity Index ${entry.compositeScore}%',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.background,
            ),
          ),
          backgroundColor: AppColors.textPrimary,
          behavior: SnackBarBehavior.floating,
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
            // Screen Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EVENING AUDIT',
                      style: AppTextStyles.labelBadge.copyWith(
                        color: AppColors.shieldPrimary,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '3-INDEX DEBRIEF',
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
                    isAlreadyLogged ? 'LOGGED TODAY' : 'PENDING (60s)',
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
              '60-second psychological boundary review. Quantify composure, log one key takeaway, and detach from corporate residue.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),

            // Index 1: Reaction Control
            IndexSlider(
              indexNumber: 'INDEX 01',
              title: 'REACTION CONTROL',
              description: 'How effectively did you maintain emotional equanimity when provoked, interrupted, or challenged today?',
              value: _reactionControl,
              onChanged: (val) => setState(() => _reactionControl = val),
              statusLabel: _getReactionStatus(_reactionControl),
              statusColor: _getReactionColor(_reactionControl),
            ),
            const SizedBox(height: 16),

            // Index 2: Boundary Retained
            IndexSlider(
              indexNumber: 'INDEX 02',
              title: 'BOUNDARY RETAINED',
              description: 'How firmly did you protect your calendar, personal hours, and professional scope from artificial emergencies?',
              value: _boundaryRetained,
              onChanged: (val) => setState(() => _boundaryRetained = val),
              statusLabel: _getBoundaryStatus(_boundaryRetained),
              statusColor: _getBoundaryColor(_boundaryRetained),
            ),
            const SizedBox(height: 16),

            // Index 3: Core Output (Single-line)
            SingleLineOutputInput(
              controller: _outputController,
              onChanged: (text) => setState(() {}),
            ),
            const SizedBox(height: 20),

            // Submit / Update Button
            SizedBox(
              width: double.infinity,
              height: AppDimens.buttonHeight,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _handleSaveDebrief,
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
                          const Icon(Icons.check_circle_rounded, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            isAlreadyLogged
                                ? 'UPDATE TODAY\'S DEBRIEF'
                                : 'COMMIT EQUANIMITY AUDIT',
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

            // Historical Debriefs Log
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
