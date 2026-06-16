import 'package:local_auth/local_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localAuthProvider = Provider((ref) => LocalAuthService());

class LocalAuthService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> authenticate() async {
    try {
      final canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();

      if (!canAuthenticate) {
        // If device has no biometrics, we bypass or handle accordingly
        return true; 
      }

      return await _auth.authenticate(
        localizedReason: 'Scan FaceID or Fingerprint to access trading dashboard',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }
}
