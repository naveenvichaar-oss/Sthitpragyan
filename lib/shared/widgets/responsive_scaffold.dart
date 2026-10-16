import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/haptic_service.dart';
import '../../features/cognition_vault/presentation/screens/cognition_vault_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/journal/presentation/screens/journal_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/sos/presentation/screens/sos_modal_sheet.dart';

/// ResponsiveScaffold provides adaptive layout for both Mobile and Tablet screens.
/// Features zero clutter, instant tab response (<50ms), and pure dark zinc aesthetics.
class ResponsiveScaffold extends StatefulWidget {
  const ResponsiveScaffold({super.key});

  @override
  State<ResponsiveScaffold> createState() => _ResponsiveScaffoldState();
}

class _ResponsiveScaffoldState extends State<ResponsiveScaffold> {
  int _currentIndex = 0;
  final GlobalKey<DashboardScreenState> _dashboardKey =
      GlobalKey<DashboardScreenState>();

  void _onTabSelected(int index) {
    if (index != _currentIndex) {
      HapticService.selectionClick();
      setState(() {
        _currentIndex = index;
      });
      if (index == 0) {
        _dashboardKey.currentState?.refreshData();
      }
    }
  }

  void _navigateToJournal() {
    _onTabSelected(1);
  }

  void _handleDebriefSaved() {
    _dashboardKey.currentState?.refreshData();
  }

  void _openSOSShieldModal() {
    SOSModalSheet.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isTablet = width >= AppDimens.tabletBreakpoint;

    final screens = [
      DashboardScreen(
        key: _dashboardKey,
        onNavigateToJournal: _navigateToJournal,
        onNavigateToVault: () => _onTabSelected(2),
        onNavigateToSettings: () => _onTabSelected(3),
      ),
      JournalScreen(onEntrySaved: _handleDebriefSaved),
      const CognitionVaultScreen(),
      const SettingsScreen(),
    ];

    if (isTablet) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            // Tablet Left Navigation Rail
            NavigationRail(
              backgroundColor: AppColors.surface,
              selectedIndex: _currentIndex,
              onDestinationSelected: _onTabSelected,
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 20),
                child: Column(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.shieldPrimary,
                          width: 1.5,
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.shield_rounded,
                          color: AppColors.shieldPrimary,
                          size: 22,
                        ),
                        tooltip: 'SOS Emergency Equanimity',
                        onPressed: _openSOSShieldModal,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'SOS',
                      style: AppTextStyles.labelBadge.copyWith(
                        fontSize: 9,
                        color: AppColors.roseDanger,
                      ),
                    ),
                  ],
                ),
              ),
              selectedIconTheme: const IconThemeData(
                color: AppColors.shieldPrimary,
              ),
              unselectedIconTheme: const IconThemeData(
                color: AppColors.textMuted,
              ),
              selectedLabelTextStyle: AppTextStyles.labelBadge.copyWith(
                color: AppColors.shieldPrimary,
                fontSize: 10,
              ),
              unselectedLabelTextStyle: AppTextStyles.labelBadge.copyWith(
                color: AppColors.textMuted,
                fontSize: 10,
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard_rounded),
                  label: Text('DASHBOARD'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.edit_note_outlined),
                  selectedIcon: Icon(Icons.edit_note_rounded),
                  label: Text('DEBRIEF'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.psychology_outlined),
                  selectedIcon: Icon(Icons.psychology_rounded),
                  label: Text('VAULT'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.tune_outlined),
                  selectedIcon: Icon(Icons.tune_rounded),
                  label: Text('SETTINGS'),
                ),
              ],
            ),
            const VerticalDivider(width: 1, color: AppColors.borderSubtle),
            // Centered responsive body
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 860),
                  child: IndexedStack(index: _currentIndex, children: screens),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Mobile Phone Layout
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.borderSubtle, width: 1.0),
          ),
        ),
        child: SafeArea(
          child: NavigationBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            height: 64,
            selectedIndex: _currentIndex,
            onDestinationSelected: _onTabSelected,
            indicatorColor: AppColors.surfaceElevated,
            destinations: const [
              NavigationDestination(
                icon: Icon(
                  Icons.dashboard_outlined,
                  color: AppColors.textMuted,
                ),
                selectedIcon: Icon(
                  Icons.dashboard_rounded,
                  color: AppColors.shieldPrimary,
                ),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.edit_note_outlined,
                  color: AppColors.textMuted,
                ),
                selectedIcon: Icon(
                  Icons.edit_note_rounded,
                  color: AppColors.shieldPrimary,
                ),
                label: 'Debrief',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.psychology_outlined,
                  color: AppColors.textMuted,
                ),
                selectedIcon: Icon(
                  Icons.psychology_rounded,
                  color: AppColors.shieldPrimary,
                ),
                label: 'Vault',
              ),
              NavigationDestination(
                icon: Icon(Icons.tune_outlined, color: AppColors.textMuted),
                selectedIcon: Icon(
                  Icons.tune_rounded,
                  color: AppColors.shieldPrimary,
                ),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
