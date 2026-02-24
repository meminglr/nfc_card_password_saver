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

      // Tasarım geliştirmeleri için mock data eklenmesi
      if (_cards.isEmpty) {
        final mockCards = [
          CardItem(
            id: 'mock_1',
            name: 'Banka Kartı',
            password: 'pwd_bank_123',
            description: 'Maaş hesabım',
          ),
          CardItem(
            id: 'mock_2',
            name: 'Spor Salonu',
            password: 'pwd_gym_456',
            description: 'Üyelik No: 5123',
          ),
          CardItem(
            id: 'mock_3',
            name: 'Ofis Girişi',
            password: 'pwd_office_789',
            description: 'Plaza 4. Kat',
          ),
          CardItem(
            id: 'mock_4',
            name: 'Okul Kimliği',
            password: 'pwd_school_321',
            description: 'Öğrenci İşleri',
          ),
          CardItem(
            id: 'mock_5',
            name: 'Netflix',
            password: 'pwd_netflix_654',
            description: 'Ortak Hesap',
          ),
        ];

        for (var card in mockCards) {
          await _storageService.saveCard(card);
        }

        _cards = mockCards;
      }
    } catch (e) {
      _error = "Kartlar yüklenemedi: $e";
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveCard(
    String id,
    String name,
    String password, {
    String? description,
  }) async {
    final newItem = CardItem(
      id: id,
      name: name,
      password: password,
      description: description,
    );
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
