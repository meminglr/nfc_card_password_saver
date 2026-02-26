import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _keyRequireNfc = 'require_nfc';
  static const String _keyRequireBiometrics = 'require_biometrics';
  static const String _keyThemeMode = 'theme_mode';

  static const String _keyIsCardViewEnabled = 'is_card_view_enabled';

  Future<String> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    // Default to 'system'
    return prefs.getString(_keyThemeMode) ?? 'system';
  }

  Future<void> setThemeMode(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, value);
  }

  Future<bool> getIsCardViewEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    // Default to false (List View)
    return prefs.getBool(_keyIsCardViewEnabled) ?? false;
  }

  Future<void> setIsCardViewEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsCardViewEnabled, value);
  }

  Future<bool> getRequireNfc() async {
    final prefs = await SharedPreferences.getInstance();
    // Default to true for maximum security if not set
    return prefs.getBool(_keyRequireNfc) ?? true;
  }

  Future<void> setRequireNfc(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRequireNfc, value);
  }

  Future<bool> getRequireBiometrics() async {
    final prefs = await SharedPreferences.getInstance();
    // Default to true for maximum security if not set
    return prefs.getBool(_keyRequireBiometrics) ?? true;
  }

  Future<void> setRequireBiometrics(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRequireBiometrics, value);
  }
}
