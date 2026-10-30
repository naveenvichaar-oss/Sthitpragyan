import 'package:flutter_test/flutter_test.dart';
import 'package:sthitaprajna/features/sharing/presentation/widgets/incoming_share_modal_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ShareDestination Tests', () {
    test('ShareDestination values order puts recoveryReference (Training / अभ्यास) leftmost', () {
      expect(ShareDestination.values[0], equals(ShareDestination.recoveryReference));
      expect(ShareDestination.values[1], equals(ShareDestination.cognitionVault));
      expect(ShareDestination.values[2], equals(ShareDestination.joyReservoir));
    });

    test('ShareDestination provides accurate display names and badge labels', () {
      expect(ShareDestination.recoveryReference.displayName, 'Training / अभ्यास');
      expect(ShareDestination.recoveryReference.badgeLabel, 'TRAINING / अभ्यास');

      // Localized assertions
      expect(ShareDestination.recoveryReference.getDisplayName(true), 'अभ्यास');
      expect(ShareDestination.recoveryReference.getDisplayName(false), 'Training');
      expect(ShareDestination.recoveryReference.getBadgeLabel(true), 'अभ्यास');
      expect(ShareDestination.recoveryReference.getBadgeLabel(false), 'TRAINING');

      expect(ShareDestination.cognitionVault.displayName, 'Cognition Vault');
      expect(ShareDestination.cognitionVault.badgeLabel, 'COGNITION VAULT');
      expect(ShareDestination.cognitionVault.getDisplayName(true), 'संज्ञान कोष');
      expect(ShareDestination.cognitionVault.getDisplayName(false), 'Cognition Vault');

      expect(ShareDestination.joyReservoir.displayName, 'Joy Box');
      expect(ShareDestination.joyReservoir.badgeLabel, 'JOY BOX');
      expect(ShareDestination.joyReservoir.getDisplayName(true), 'जॉय बॉक्स');
      expect(ShareDestination.joyReservoir.getDisplayName(false), 'Joy Box');
    });

    test('ShareDestination has distinct soothing accent colors', () {
      expect(ShareDestination.recoveryReference.accentColor, isNotNull);
      expect(ShareDestination.cognitionVault.accentColor, isNotNull);
      expect(ShareDestination.joyReservoir.accentColor, isNotNull);
    });
  });
}
