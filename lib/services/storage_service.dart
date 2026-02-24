import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/card_item.dart';

class StorageService {
  final _storage = const FlutterSecureStorage();
  static const _cardsKey = 'saved_cards';

  Future<void> saveCard(CardItem card) async {
    final cards = await getCards();
    final index = cards.indexWhere((c) => c.id == card.id);
    if (index >= 0) {
      cards[index] = card;
    } else {
      cards.add(card);
    }
    await _saveAll(cards);
  }

  Future<List<CardItem>> getCards() async {
    final String? cardsStr = await _storage.read(key: _cardsKey);
    if (cardsStr == null || cardsStr.isEmpty) return [];

    final List<dynamic> decoded = jsonDecode(cardsStr);
    return decoded.map((e) => CardItem.fromJson(e)).toList();
  }

  Future<CardItem?> getCardById(String id) async {
    final cards = await getCards();
    try {
      return cards.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteCard(String id) async {
    final cards = await getCards();
    cards.removeWhere((c) => c.id == id);
    await _saveAll(cards);
  }

  Future<void> _saveAll(List<CardItem> cards) async {
    final String encoded = jsonEncode(cards.map((c) => c.toJson()).toList());
    await _storage.write(key: _cardsKey, value: encoded);
  }
}
