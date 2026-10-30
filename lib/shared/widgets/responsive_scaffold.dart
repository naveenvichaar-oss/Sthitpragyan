import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/haptic_service.dart';
import '../../features/cognition_vault/presentation/screens/cognition_vault_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/journal/presentation/screens/journal_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/sharing/services/sharing_intent_service.dart';
import '../../features/mukti/presentation/screens/mukti_hub_screen.dart';
import '../../features/sos/presentation/screens/sos_screen.dart';

/// ResponsiveScaffold provides adaptive layout for both Mobile and Tablet screens.
/// Features 4 strictly ordered tabs with Tab 1 (ठहराव / SOS) promoted as the primary first tab on app launch.
///
/// Order of Navigation:
/// - Tab 1: ठहराव / SOS (Immediate Neural Brake)
/// - Tab 2: प्रारंभ / Dashboard (Daily Routine & Execution)
/// - Tab 3: कोष / Vault (Knowledge, Courses, HTML Tools)
/// - Tab 4: संज्ञान / Cognition (Self-Audit & Journal)
class ResponsiveScaffold extends StatefulWidget {
  const ResponsiveScaffold({super.key});

  @override
  State<ResponsiveScaffold> createState() => _ResponsiveScaffoldState();
}

class _ResponsiveScaffoldState extends State<ResponsiveScaffold> {
  // Tab 0 is now ठहराव / SOS (First Tab on launch)
  int _currentIndex = 0;
  final GlobalKey<DashboardScreenState> _dashboardKey =
      GlobalKey<DashboardScreenState>();
  final GlobalKey<CognitionVaultScreenState> _vaultKey =
      GlobalKey<CognitionVaultScreenState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SharingIntentService().init(context);
    });
  }

  @override
  void dispose() {
    SharingIntentService().dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    if (index != _currentIndex) {
      HapticService.selectionClick();
      setState(() {
        _currentIndex = index;
      });
      // When switching to Dashboard (Tab 1), refresh metrics and triggers
      if (index == 1) {
        _dashboardKey.currentState?.refreshData();
      }
    }
  }

  void _navigateToSos() {
    _onTabSelected(0);
  }

  void _navigateToCognition() {
    _onTabSelected(3);
  }

  void _navigateToVaultSegment(int segmentIndex) {
    _onTabSelected(2);
    if (_vaultKey.currentState != null) {
      _vaultKey.currentState!.switchToSegment(segmentIndex);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _vaultKey.currentState?.switchToSegment(segmentIndex);
      });
    }
  }

  void _handleDebriefSaved() {
    _dashboardKey.currentState?.refreshData();
  }

  void _openSettings() {
    HapticService.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isTablet = width >= AppDimens.tabletBreakpoint;

    // 4 Ordered Tabs:
    // Index 0: ठहराव / SOS (First Tab — Immediate Somatic Neural Brake)
    // Index 1: प्रारंभ / Dashboard (Daily Routine & Execution Engine)
    // Index 2: कोष / Vault (Knowledge, Courses, HTML Tools)
    // Index 3: संज्ञान / Cognition (Self-Audit & Journal)
    final screens = [
      const SOSScreen(),
      DashboardScreen(
        key: _dashboardKey,
        onNavigateToJournal: _navigateToCognition,
        onNavigateToVault: () => _onTabSelected(2),
        onNavigateToVaultSegment: _navigateToVaultSegment,
        onNavigateToSettings: _openSettings,
        onNavigateToSos: _navigateToSos,
      ),
      CognitionVaultScreen(key: _vaultKey),
      JournalScreen(onEntrySaved: _handleDebriefSaved),
      const MuktiHubScreen(),
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
                          color: AppColors.borderSubtle,
                          width: 1.5,
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.settings_outlined,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        tooltip: 'Settings / सेटिंग्स',
                        onPressed: _openSettings,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.loc.brandMarker,
                      style: AppTextStyles.labelBadge.copyWith(
                        fontSize: 8.5,
                        letterSpacing: 1.5,
                        color: AppColors.textMuted,
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
              destinations: [
                NavigationRailDestination(
                  icon: const Icon(Icons.shield_outlined),
                  selectedIcon: const Icon(Icons.shield_rounded, color: AppColors.roseDanger),
                  label: Text(context.loc.navSos.toUpperCase()),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.dashboard_outlined),
                  selectedIcon: const Icon(Icons.dashboard_rounded),
                  label: Text(context.loc.navDashboard.toUpperCase()),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.auto_stories_outlined),
                  selectedIcon: const Icon(Icons.auto_stories_rounded),
                  label: Text(context.loc.navVault.toUpperCase()),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.psychology_outlined),
                  selectedIcon: const Icon(Icons.psychology_rounded),
                  label: Text(context.loc.navCognition.toUpperCase()),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.self_improvement_outlined),
                  selectedIcon: const Icon(Icons.self_improvement_rounded,
                      color: AppColors.emeraldSuccess),
                  label: Text(context.loc.navMukti.toUpperCase()),
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

    // Mobile Phone Layout (4 Bottom Tabs)
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
            destinations: [
              NavigationDestination(
                icon: const Icon(
                  Icons.shield_outlined,
                  color: AppColors.textMuted,
                ),
                selectedIcon: const Icon(
                  Icons.shield_rounded,
                  color: AppColors.roseDanger,
                ),
                label: context.loc.navSos,
              ),
              NavigationDestination(
                icon: const Icon(
                  Icons.dashboard_outlined,
                  color: AppColors.textMuted,
                ),
                selectedIcon: const Icon(
                  Icons.dashboard_rounded,
                  color: AppColors.shieldPrimary,
                ),
                label: context.loc.navDashboard,
              ),
              NavigationDestination(
                icon: const Icon(
                  Icons.auto_stories_outlined,
                  color: AppColors.textMuted,
                ),
                selectedIcon: const Icon(
                  Icons.auto_stories_rounded,
                  color: AppColors.shieldPrimary,
                ),
                label: context.loc.navVault,
              ),
              NavigationDestination(
                icon: const Icon(
                  Icons.psychology_outlined,
                  color: AppColors.textMuted,
                ),
                selectedIcon: const Icon(
                  Icons.psychology_rounded,
                  color: AppColors.shieldPrimary,
                ),
                label: context.loc.navCognition,
              ),
              NavigationDestination(
                icon: const Icon(
                  Icons.self_improvement_outlined,
                  color: AppColors.textMuted,
                ),
                selectedIcon: const Icon(
                  Icons.self_improvement_rounded,
                  color: AppColors.emeraldSuccess,
                ),
                label: context.loc.navMukti,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
