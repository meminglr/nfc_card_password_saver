import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> isBiometricAvailable() async {
    try {
      final canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final canAuthenticate =
          canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      return canAuthenticate;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> authenticate(String reason) async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        // If device has no biometrics, we fallback to true assuming they rely on device lock
        // Or we could return true to bypass, depending on strictness.
        // We will try to authenticate anyway to show Device PIN fallback.
      }

      final authenticated = await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: false,
        sensitiveTransaction: true,
        persistAcrossBackgrounding: true,
      );

      return authenticated;
    } on PlatformException catch (e) {
      if (e.code == 'NotEnrolled' ||
          e.code == 'NotAvailable' ||
          e.code == 'PasscodeNotSet') {
        // Allow pass if security is not setup on device
        return true;
      }
      return false;
    }
  }
}
