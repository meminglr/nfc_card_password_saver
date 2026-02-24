import 'package:flutter/foundation.dart';
import '../models/card_item.dart';
import '../services/storage_service.dart';
import '../services/nfc_service.dart';

class CardProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  final NfcService _nfcService = NfcService();

  List<CardItem> _cards = [];
  bool _isLoading = true;
  String? _error;

  List<CardItem> get cards => _cards;
  bool get isLoading => _isLoading;
  String? get error => _error;

  CardProvider() {
    loadCards();
  }

  Future<void> loadCards() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cards = await _storageService.getCards();
    } catch (e) {
      _error = "Kartlar yüklenemedi: $e";
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveCard(String id, String name, String password) async {
    final newItem = CardItem(id: id, name: name, password: password);
    await _storageService.saveCard(newItem);
    await loadCards();
  }

  Future<void> deleteCard(String id) async {
    await _storageService.deleteCard(id);
    await loadCards();
  }

  Future<void> startNfcSession({
    required Function(String id) onDiscovered,
    required Function(String error) onError,
  }) async {
    await _nfcService.startSession(
      onDiscovered: onDiscovered,
      onError: onError,
    );
  }

  Future<void> stopNfcSession() async {
    await _nfcService.stopSession();
  }
}
