import 'package:flutter/foundation.dart';
import '../models/card_item.dart';
import '../services/storage_service.dart';
import '../services/nfc_service.dart';

enum SortOption { aToZ, zToA, custom }

class CardProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  final NfcService _nfcService = NfcService();

  List<CardItem> _cards = [];
  bool _isLoading = true;
  String? _error;

  // Filtering and Sorting State
  String _searchQuery = '';
  SortOption _sortOption = SortOption.custom;
  int? _filterColorCode;

  List<CardItem> get cards => _cards;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get searchQuery => _searchQuery;
  SortOption get sortOption => _sortOption;
  int? get filterColorCode => _filterColorCode;

  List<CardItem> get filteredAndSortedCards {
    List<CardItem> result = List.from(_cards);

    // Apply Search Filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((card) {
        final matchesName = card.name.toLowerCase().contains(query);
        final matchesDesc =
            card.description?.toLowerCase().contains(query) ?? false;
        return matchesName || matchesDesc;
      }).toList();
    }

    // Apply Color Filter
    if (_filterColorCode != null) {
      result = result
          .where((card) => card.colorCode == _filterColorCode)
          .toList();
    }

    // Apply Sort
    switch (_sortOption) {
      case SortOption.aToZ:
        result.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        break;
      case SortOption.zToA:
        result.sort(
          (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()),
        );
        break;
      case SortOption.custom:
        result.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
        break;
    }

    return result;
  }

  CardProvider() {
    loadCards();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSortOption(SortOption option) {
    _sortOption = option;
    notifyListeners();
  }

  void setFilterColorCode(int? colorCode) {
    _filterColorCode = colorCode;
    notifyListeners();
  }

  Future<void> reorderCards(int oldIndex, int newIndex) async {
    // If we're not using custom sort or have active filters, reordering should be disabled in the UI.
    // However, if it happens, we reorder the raw `_cards` list based on the user's drag.
    // Since we are filtering/sorting, drag operations are only permitted on the filteredAndSortedCards list.

    final displayedCards = filteredAndSortedCards;
    if (oldIndex < 0 ||
        oldIndex >= displayedCards.length ||
        newIndex < 0 ||
        newIndex > displayedCards.length) {
      return;
    }

    if (_sortOption != SortOption.custom) {
      _sortOption = SortOption.custom;
    }

    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final item = displayedCards.removeAt(oldIndex);
    displayedCards.insert(newIndex, item);

    final List<CardItem> cardsToSave = [];

    // Now update orderIndex for all cards matching the new displayed order
    for (int i = 0; i < displayedCards.length; i++) {
      final card = displayedCards[i];
      if (card.orderIndex == i) continue; // No change needed

      final updatedCard = CardItem(
        id: card.id,
        name: card.name,
        password: card.password,
        description: card.description,
        colorCode: card.colorCode,
        orderIndex: i, // Give them consecutive order indices
      );

      // Update in memory `_cards` list
      final originalIndex = _cards.indexWhere((c) => c.id == card.id);
      if (originalIndex != -1) {
        _cards[originalIndex] = updatedCard;
      }

      cardsToSave.add(updatedCard);
    }

    // 1. Notify listeners IMMEDIATELY so the UI doesn't stutter or jump
    notifyListeners();

    // 2. Perform slow disk I/O operations asynchronously in the background
    for (final updatedCard in cardsToSave) {
      await _storageService.saveCard(updatedCard);
    }
  }

  Future<void> loadCards() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cards = await _storageService.getCards();

      // Ensure all cards have a valid orderIndex (for backward compatibility)
      // For now, let's just make sure mock data has ordering
      if (_cards.isEmpty) {
        final mockCards = [
          CardItem(
            id: 'mock_1',
            name: 'Banka Kartı',
            password: 'pwd_bank_123',
            description: 'Maaş hesabım',
            colorCode: 0xFF1976D2, // Blue
            orderIndex: 0,
          ),
          CardItem(
            id: 'mock_2',
            name: 'Spor Salonu',
            password: 'pwd_gym_456',
            description: 'Üyelik No: 5123',
            colorCode: 0xFFE53935, // Red
            orderIndex: 1,
          ),
          CardItem(
            id: 'mock_3',
            name: 'Ofis Girişi',
            password: 'pwd_office_789',
            description: 'Plaza 4. Kat',
            colorCode: 0xFF00897B, // Teal
            orderIndex: 2,
          ),
          CardItem(
            id: 'mock_4',
            name: 'Okul Kimliği',
            password: 'pwd_school_321',
            description: 'Öğrenci İşleri',
            colorCode: 0xFF8E24AA, // Purple
            orderIndex: 3,
          ),
          CardItem(
            id: 'mock_5',
            name: 'Netflix',
            password: 'pwd_netflix_654',
            description: 'Ortak Hesap',
            colorCode: 0xFFF4511E, // Deep Orange
            orderIndex: 4,
          ),
        ];

        for (var card in mockCards) {
          await _storageService.saveCard(card);
        }

        _cards = mockCards;
      } else {
        // Fix legacy order indices
        bool hasDuplicates = false;
        final indices = _cards.map((e) => e.orderIndex).toSet();
        if (indices.length < _cards.length) hasDuplicates = true;

        if (hasDuplicates) {
          for (int i = 0; i < _cards.length; i++) {
            final c = _cards[i];
            final updated = CardItem(
              id: c.id,
              name: c.name,
              password: c.password,
              description: c.description,
              colorCode: c.colorCode,
              orderIndex: i,
            );
            _cards[i] = updated;
            await _storageService.saveCard(updated);
          }
        }
      }

      // Initial sort
      _cards.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
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
    int? colorCode,
  }) async {
    // If creating a new card, put it at the end
    int newOrderIndex = 0;
    final existingIndex = _cards.indexWhere((c) => c.id == id);
    if (existingIndex != -1) {
      newOrderIndex = _cards[existingIndex].orderIndex;
    } else {
      newOrderIndex = _cards.isEmpty
          ? 0
          : _cards.map((c) => c.orderIndex).reduce((a, b) => a > b ? a : b) + 1;
    }

    final newItem = CardItem(
      id: id,
      name: name,
      password: password,
      description: description,
      colorCode: colorCode,
      orderIndex: newOrderIndex,
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
