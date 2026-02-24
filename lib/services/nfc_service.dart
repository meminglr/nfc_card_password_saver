import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/nfc_manager_android.dart' as android;
import 'package:nfc_manager/nfc_manager_ios.dart' as ios;

class NfcService {
  Future<bool> isAvailable() async {
    return await NfcManager.instance.isAvailable();
  }

  Future<void> startSession({
    required Function(String id) onDiscovered,
    required Function(String error) onError,
  }) async {
    try {
      bool isAvail = await isAvailable();
      if (!isAvail) {
        onError("NFC kapatılmış veya cihazınızda desteklenmiyor.");
        return;
      }

      NfcManager.instance.startSession(
        pollingOptions: NfcPollingOption.values.toSet(),
        onDiscovered: (NfcTag tag) async {
          try {
            String? id;

            // Android Tags
            try {
              final androidTag = android.NfcTagAndroid.from(tag);
              if (androidTag != null) {
                id = _bytesToHexString(androidTag.id);
              }
            } catch (_) {}

            // iOS Tags
            if (id == null) {
              try {
                final mifare = ios.MiFareIos.from(tag);
                if (mifare != null) id ??= _bytesToHexString(mifare.identifier);
              } catch (_) {}

              try {
                final felica = ios.FeliCaIos.from(tag);
                if (felica != null) id ??= _bytesToHexString(felica.currentIDm);
              } catch (_) {}

              try {
                final iso15693 = ios.Iso15693Ios.from(tag);
                if (iso15693 != null)
                  id ??= _bytesToHexString(iso15693.identifier);
              } catch (_) {}

              try {
                final iso7816 = ios.Iso7816Ios.from(tag);
                if (iso7816 != null)
                  id ??= _bytesToHexString(iso7816.identifier);
              } catch (_) {}
            }

            if (id != null) {
              await stopSession();
              onDiscovered(id);
            } else {
              onError(
                "Kart ID okunamadı. Lütfen desteklenen bir kart deneyin.",
              );
            }
          } catch (e) {
            onError("Okuma hatası: $e");
          }
        },
      );
    } catch (e) {
      onError(e.toString());
    }
  }

  Future<void> stopSession() async {
    try {
      await NfcManager.instance.stopSession();
    } catch (_) {}
  }

  String _bytesToHexString(List<int> bytes) {
    return bytes
        .map((e) => e.toRadixString(16).padLeft(2, '0'))
        .join(':')
        .toUpperCase();
  }
}
