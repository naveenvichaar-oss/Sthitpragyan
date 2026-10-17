import 'package:flutter_test/flutter_test.dart';
import 'package:sthitaprajna/features/sharing/presentation/widgets/incoming_share_modal_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ShareDestination Tests', () {
    test('ShareDestination provides accurate display names and badge labels', () {
      expect(ShareDestination.cognitionVault.displayName, 'Cognition Vault');
      expect(ShareDestination.cognitionVault.badgeLabel, 'COGNITION VAULT');

      expect(ShareDestination.joyReservoir.displayName, 'Joy Reservoir');
      expect(ShareDestination.joyReservoir.badgeLabel, 'JOY RESERVOIR');

      expect(ShareDestination.recoveryReference.displayName, 'Recovery Reference');
      expect(ShareDestination.recoveryReference.badgeLabel, 'RECOVERY REFERENCE');
    });

    test('ShareDestination has distinct soothing accent colors', () {
      expect(ShareDestination.cognitionVault.accentColor, isNotNull);
      expect(ShareDestination.joyReservoir.accentColor, isNotNull);
      expect(ShareDestination.recoveryReference.accentColor, isNotNull);
    });
  });
}
