import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class SettingsProvider with ChangeNotifier {
  final SettingsService _settingsService;

  bool _requireNfc = true;
  bool _requireBiometrics = true;
  ThemeMode _themeMode = ThemeMode.system;
  bool _isCardViewEnabled = false;
  bool _isLoading = true;

  SettingsProvider(this._settingsService) {
    _loadSettings();
  }

  bool get requireNfc => _requireNfc;
  bool get requireBiometrics => _requireBiometrics;
  ThemeMode get themeMode => _themeMode;
  bool get isCardViewEnabled => _isCardViewEnabled;
  bool get isLoading => _isLoading;

  Future<void> _loadSettings() async {
    _isLoading = true;
    notifyListeners();

    _requireNfc = await _settingsService.getRequireNfc();
    _requireBiometrics = await _settingsService.getRequireBiometrics();
    final themeString = await _settingsService.getThemeMode();
    _themeMode = _parseThemeMode(themeString);
    _isCardViewEnabled = await _settingsService.getIsCardViewEnabled();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> setRequireNfc(bool value) async {
    if (_requireNfc == value) return;
    _requireNfc = value;
    await _settingsService.setRequireNfc(value);
    notifyListeners();
  }

  Future<void> setRequireBiometrics(bool value) async {
    if (_requireBiometrics == value) return;
    _requireBiometrics = value;
    await _settingsService.setRequireBiometrics(value);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode value) async {
    if (_themeMode == value) return;
    _themeMode = value;
    await _settingsService.setThemeMode(_themeModeToString(value));
    notifyListeners();
  }

  ThemeMode _parseThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }

  Future<void> setIsCardViewEnabled(bool value) async {
    if (_isCardViewEnabled == value) return;
    _isCardViewEnabled = value;
    await _settingsService.setIsCardViewEnabled(value);
    notifyListeners();
  }
}
