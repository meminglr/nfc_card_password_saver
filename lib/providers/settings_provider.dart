import 'package:flutter/foundation.dart';
import '../services/settings_service.dart';

class SettingsProvider with ChangeNotifier {
  final SettingsService _settingsService;

  bool _requireNfc = true;
  bool _requireBiometrics = true;
  bool _isDarkMode = true;
  bool _isCardViewEnabled = false;
  bool _isLoading = true;

  SettingsProvider(this._settingsService) {
    _loadSettings();
  }

  bool get requireNfc => _requireNfc;
  bool get requireBiometrics => _requireBiometrics;
  bool get isDarkMode => _isDarkMode;
  bool get isCardViewEnabled => _isCardViewEnabled;
  bool get isLoading => _isLoading;

  Future<void> _loadSettings() async {
    _isLoading = true;
    notifyListeners();

    _requireNfc = await _settingsService.getRequireNfc();
    _requireBiometrics = await _settingsService.getRequireBiometrics();
    _isDarkMode = await _settingsService.getIsDarkMode();
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

  Future<void> setIsDarkMode(bool value) async {
    if (_isDarkMode == value) return;
    _isDarkMode = value;
    await _settingsService.setIsDarkMode(value);
    notifyListeners();
  }

  Future<void> setIsCardViewEnabled(bool value) async {
    if (_isCardViewEnabled == value) return;
    _isCardViewEnabled = value;
    await _settingsService.setIsCardViewEnabled(value);
    notifyListeners();
  }
}
